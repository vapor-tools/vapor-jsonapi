//
//  JsonApiMeta.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 30/04/2017.
//
//

import Vapor

public class JsonApiMeta: JSONRepresentable {

    public let metaObject: JSON

    public init(metaObject: JSON) {
        self.metaObject = metaObject
    }

    public func makeJSON() throws -> JSON {
        return metaObject
    }
}
