//
//  ResourceType.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 30/04/2017.
//
//

import Foundation

public protocol ResourceType {
    func parse() -> String
}

extension String: ResourceType {

    public func parse() -> String {
        return self
    }
}
