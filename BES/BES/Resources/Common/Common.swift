//
//  Common.swift
//  BES
//
//  Created by YPO  on 19/08/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

let networkUnavailable: String = "Network unavailable."

class Common {
    class func hasConnectivity() -> Bool {
        do {
            let reachability: Reachability = try Reachability()
            let networkStatus = reachability.connection.description.lowercased()
            
            if (networkStatus == "No Connection".lowercased() || networkStatus == "unavailable".lowercased()) {
                return false
            }
            else {
                return true
            }
        }
        catch {
            // Handle error however you please
            return false
        }
    }
}
