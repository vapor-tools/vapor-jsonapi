//
//  URIExtensions.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 03/05/2017.
//
//

import URI

extension URI {

    func baseUrl() -> String {
        var portString = ""
        if let port = port, let defaultPort = defaultPort, port != defaultPort {
            portString = ":\(String(port))"
        } else if let port = port {
            portString = ":\(String(port))"
        }

        return "\(scheme)://\(hostname)\(portString)"
    }
}
