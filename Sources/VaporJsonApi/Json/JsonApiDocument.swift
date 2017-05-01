//
//  JsonApiDocument.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 01/05/2017.
//
//

import Vapor

public class JsonApiDocument: JSONRepresentable {

    public let data: JsonApiData?
    public let errors: [JsonApiErrorObject]?
    public let meta: JsonApiMeta?

    public init(data: JsonApiData, meta: JsonApiMeta? = nil) {
        self.data = data
        self.meta = meta

        self.errors = nil
    }

    public init(errors: [JsonApiErrorObject], meta: JsonApiMeta? = nil) {
        self.errors = errors
        self.meta = meta

        self.data = nil
    }

    public func makeJSON() throws -> JSON {
        var json = try JSON(node: [])

        if let data = data {
            json["data"] = try data.makeJSON()
        } else if let errors = errors {
            var jsonErrors: [JSON] = []
            for error in errors {
                jsonErrors.append(try error.makeJSON())
            }
            json["errors"] = JSON(jsonErrors)
        } else {

            // This should really *never* happens because of the unambiguous initializers but this
            // else is to calm the static type system...
            fatalError("JsonApiDocument MUST contain data XOR errors!")
        }

        if let meta = meta {
            json["meta"] = try meta.makeJSON()
        }

        return json
    }
}
