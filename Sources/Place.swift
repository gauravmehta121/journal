import Foundation
import CoreLocation

class Place {
    private var _location: [String: CLLocationDegrees]!
    private var _name: String!
    private var _userDescription: String!
    private var _placesDict: [String: Any]!
    private var _timestamp: Date!
    private var _placekey: String!
    
    var location: [String: CLLocationDegrees] {
        return _location
    }
    
    var name: String {
        return _name
    }
    
    var userDescription: String {
        return _userDescription
    }
    
    var placesDict: [String: Any] {
        return _placesDict
    }
    
    var timestamp: Date {
        return _timestamp
    }
    
    var placekey: String {
        return _placekey
    }
    
    init(placeDict: [String: Any], placekey: String) {
        if let location = placeDict["location"] as? [String: Double]{
            _location = location
        }
        
        if let name = placeDict["name"] as? String {
            _name = name
        }
        
        if let userDescription = placeDict["userDescription"] as? String {
            _userDescription = userDescription
        }
        
        if let timestamp = placeDict["timestamp"] as? String {
            let dateFormatter = DateFormatter()
            _timestamp = dateFormatter.date(from: timestamp)
        }
        
        _placekey = placekey
        
        _placesDict = placeDict
    }
}
