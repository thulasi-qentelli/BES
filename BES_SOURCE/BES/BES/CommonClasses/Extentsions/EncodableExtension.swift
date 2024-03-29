//
//  EncodableExtension.swift
//  NLTest
//
//  Created by Tulasi on 01/08/19.
//  Copyright © 2019 Assignment. All rights reserved.
//

import Foundation

extension Encodable {
    var dictionary: Dictionary<String, Any>? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

extension Dictionary {
    
    var urlEncodeString:String {
        
        var parmArr:[String] = []
        for (key,value) in self {
            let str = "\(key)=\(value)"
            parmArr.append(str)
        }
        return parmArr.joined(separator: "&")
    }

}
