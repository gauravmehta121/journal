//
//  ScreenOneViewController.swift
//  Journal
//
//  Created by Aditya Deepak on 10/16/17.
//  Copyright © 2017 Aditya Deepak. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation
import Firebase
import GoogleSignIn
import CoreMotion

class ScreenOneViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var journalTableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stepCounter: UILabel!
    var didChangeLocation: Bool = true
    var currentLocation: CLLocation!
    var location = CLLocationManager();
    var timer: Timer!
    var isSignedIn: Bool!
    var places = [Place]()
    var selectedCell: JournalCell?
    var pedometer = CMPedometer()
    
    @IBAction func onPressSignout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance().signOut()
            isSignedIn = false
        } catch let signOutError as NSError {
            print("Error: \(signOutError)")
            return
        }
        self.performSegue(withIdentifier: "backToLogin", sender: self)
    }
    
    func getCurrentLocalDate()-> Date {
        var now = Date()
        var nowComponents = DateComponents()
        let calendar = Calendar.current
        nowComponents.year = Calendar.current.component(.year, from: now)
        nowComponents.month = Calendar.current.component(.month, from: now)
        nowComponents.day = Calendar.current.component(.day, from: now)
        nowComponents.hour = 0
        nowComponents.minute = 0
        nowComponents.second = 0
        nowComponents.timeZone = TimeZone(abbreviation: "GMT")!
        now = calendar.date(from: nowComponents)!
        return now as Date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        location.delegate = self
        requestLocationPermission()
        isSignedIn = true
        descriptionLabel.isHidden = false
        journalTableView.delegate = self
        journalTableView.dataSource = self
        
        guard let current = location.location else { return }
        
        currentLocation = current
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(ScreenOneViewController.addPlace)), userInfo: nil, repeats: didChangeLocation)
        // Do any additional setup after loading the view.
        
        if CMPedometer.isStepCountingAvailable() {
            let date = getCurrentLocalDate()
            print("date: \(date)")
            
            pedometer.startUpdates(from: date, withHandler: { (pedometerData, error) in
                if error != nil {
                    return
                }
                guard let numberOfSteps = pedometerData?.numberOfSteps else {
                    return
                }
                
                print("Steps: \(numberOfSteps)")
                DataService.instance.addSteps(steps: numberOfSteps)
                
                DispatchQueue.main.async {
                    self.stepCounter.text = numberOfSteps.stringValue
                }
                
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let userLoc = userLocation.location, currentLocation != nil else {
            return
        }
        
        let region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 1000, 2000)
        
        mapView.setRegion(region, animated: true)
        
        if currentLocation.distance(from: userLoc) > 100 || currentLocation.distance(from: userLoc) == 0 {
            currentLocation = userLoc
            didChangeLocation = true
            timer.fire()
        } else {
            didChangeLocation = false
        }
        
        getPlaces()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPlaces()
    }
    
    func requestLocationPermission() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            mapView.userTrackingMode = .follow
            mapView.showsUserLocation = true
        } else {
            location.requestAlwaysAuthorization()
            location.startUpdatingLocation()
            location.desiredAccuracy = kCLLocationAccuracyBest
            mapView.userTrackingMode = .follow
            mapView.showsUserLocation = true
        }
    }
    
    @objc func addPlace() {
        if didChangeLocation && isSignedIn {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(currentLocation) { (placemarkData, error) in
                if error != nil {
                    return
                }
                guard let placemarks = placemarkData else {
                    return
                }
                
                let placeDetails = placemarks[0]
                var name: String!
                if let placeName = placeDetails.name {
                    name = placeName
                } else if let thoroughFare = placeDetails.thoroughfare {
                    name = thoroughFare
                } else if let subLocality = placeDetails.subLocality {
                    name = subLocality
                } else {
                    name = "Unknown Location"
                }
                
                let dateFormatter = DateFormatter()
                let date = dateFormatter.string(from: Date())
                
                let placeData: [String:Any] = ["location": ["lat":self.currentLocation.coordinate.latitude, "long": self.currentLocation.coordinate.longitude], "name": name, "timestamp": date, "userDescription": "Press Edit to update entry!"]
                
                DataService.instance.addPlace(placeData: placeData)
                self.getPlaces()
                print("Worked!")
                self.descriptionLabel.isHidden = true
            }
        }
        
        didChangeLocation = false
    }
    
    func traceLocation(places: [Place]) {
        var coordinates = [CLLocationCoordinate2D]()
        for place in places {
            let location = place.location
            if let latitude = location["lat"], let longitude = location["long"] {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                coordinates.append(coordinate)
            }
        }
            
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        self.mapView.add(polyline)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(overlay: polyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4
        return renderer
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "journalCell", for: indexPath) as? JournalCell else {
            return JournalCell()
        }
        
        cell.ScreenOneVC = self
        
        cell.configureCell(place: places[indexPath.row])
        
        return cell
    }
    
    func getPlaces() {
        DataService.instance.getPlaces { (places) in
            self.places = places.reversed()
            self.journalTableView.reloadData()
            var places2 = places
            if places2.count > 2 {
                places2.removeSubrange(0..<places2.count - 2)
            }
            self.traceLocation(places: places2)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? JournalCell else {
            return
        }
        
        selectedCell = cell
    }
    
    func editPressed(cell: JournalCell) {
        selectedCell = cell
        performSegue(withIdentifier: "edit", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit", let editVC = segue.destination as? EditViewController, let userDescription = selectedCell?.place.userDescription, let place = selectedCell?.place {
            editVC.userDescription = userDescription
            editVC.place = place
        }
    }
}
