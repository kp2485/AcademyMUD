//
//  File.swift
//  
//
//  Created by Kyle Peterson on 2/6/23.
//

import Foundation
import Crypto

struct Hasher {
    static func hash(_ str: String) -> String {
        guard let strData = str.data(using: .utf8) else {
            fatalError("Failure to convert passed string data.")
        }
        
        let hashData = SHA512.hash(data: strData)
        
        return hashData.description
    }
    
    static func verify(password: String, hashedPassword: String) -> Bool {
        hash(password) == hashedPassword
    }
}
