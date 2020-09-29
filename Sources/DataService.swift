import Foundation
import FirebaseDatabase
import FirebaseAuth

class DataService {
    static let instance = DataService()
    
    private var _REF_DB = Database.database().reference()
    private var _REF_USERS = Database.database().reference().child("Users")
    
    var REF_DB: DatabaseReference {
        return _REF_DB
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    func createUser(userID: String, userData: [String:Any]) {
        _REF_USERS.child(userID).updateChildValues(userData)
        
    }
    
    func addPlace(placeData: [String: Any]) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        _REF_USERS.child(uid).child("Places").childByAutoId().updateChildValues(placeData)
    }
    
    func getPlaces(completion: @escaping ([Place]) -> ()) {
        var places = [Place]()
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        REF_USERS.child(uid).child("Places").queryOrdered(byChild: "timestamp").observe(.value) { (snapshot) in
            guard let snapshots = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            
            for snap in snapshots {
                guard let placeDict = snap.value as? [String:Any] else {
                    return
                }
                
                let place = Place(placeDict: placeDict, placekey: snap.key)
                places.append(place)
            }
            
            completion(places)
        }
        
    }
    
    func addSteps(steps: Any) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let stepsToFirebase = ["Steps": steps]
        
        REF_USERS.child(uid).updateChildValues(stepsToFirebase)
    }
    
    func savePlace(placeData: [String: Any], place: Place) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        REF_USERS.child(uid).child("Places").child(place.placekey).updateChildValues(placeData)
    }
}
