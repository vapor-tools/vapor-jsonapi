//
//  ResourceType.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 30/04/2017.
//
//

public protocol JsonApiResourceType {
    func parse() -> String
}

extension String: JsonApiResourceType {

    public func parse() -> String {
        return self
    }
}
