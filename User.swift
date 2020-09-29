//
//  User.swift
//  Journal
//
//  Created by Aditya Deepak on 11/11/17.
//  Copyright © 2017 Aditya Deepak. All rights reserved.
//
import Foundation

class User {
    private var _email: String!
    private var _places: [Place]?
    private var _userDict: [String: Any]!
    
    init(userDict: [String: Any]) {
        if let email = userDict["email"] as? String {
            _email = email
        }
        
        if let places = userDict["Places"] as? [[String: Any]] {
            for p in places {
                guard let placeDict = p.values.first as? [String: Any] else {
                    return
                }
                
                let place = Place(placeDict: placeDict, placekey: p.keys.first!)
                _places?.append(place)
            }
        }
        
        _userDict = userDict
    }
    
    var email: String {
        return _email
    }
    
    var places: [Place] {
        guard let places = _places else {
            return [Place]()
        }
        return places
    }
    
    var userDict: [String: Any] {
        return _userDict
    }
}
