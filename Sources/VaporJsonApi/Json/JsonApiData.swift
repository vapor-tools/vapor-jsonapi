//
//  JsonApiData.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 30/04/2017.
//
//

import Vapor

public class JsonApiData: JSONRepresentable {

    public let resourceObject: JsonApiResourceObject?
    public let resourceObjects: [JsonApiResourceObject]?

    public let resourceIdentifierObject: JsonApiResourceIdentifierObject?
    public let resourceIdentifierObjects: [JsonApiResourceIdentifierObject]?

    /**
     * Initializes this `data` as a JSON `null` object for empty single-resources.
     */
    public init() {
        self.resourceObject = nil
        self.resourceObjects = nil

        self.resourceIdentifierObject = nil
        self.resourceIdentifierObjects = nil
    }

    /**
     * Initializes this `data` as a single `ResourceObject`.
     *
     * - parameter resourceObject: The `ResourceObject` which represents this data.
     */
    public init(resourceObject: JsonApiResourceObject) {
        self.resourceObject = resourceObject
        self.resourceObjects = nil

        self.resourceIdentifierObject = nil
        self.resourceIdentifierObjects = nil
    }

    /**
     * Initializes this `data` as a collection of `ResourceObject`s.
     *
     * For an empty collection simple pass an empty array to the initializer.
     * This will serialize into an empty JSON array. If you want a JSON null object to represent
     * empty single-resources, see `init()`.
     *
     * - parameter resourceObjects: The array of `ResourceObject`s which represent this data.
     */
    public init(resourceObjects: [JsonApiResourceObject]) {
        self.resourceObjects = resourceObjects
        self.resourceObject = nil

        self.resourceIdentifierObject = nil
        self.resourceIdentifierObjects = nil
    }

    /**
     * Initializes this `data` as a single `ResourceIdentifierObject`.
     *
     * - parameter resourceIdentifierObject: The `ResourceIdentifierObject` which represents this data.
     */
    public init(resourceIdentifierObject: JsonApiResourceIdentifierObject) {
        self.resourceIdentifierObject = resourceIdentifierObject
        self.resourceIdentifierObjects = nil

        self.resourceObject = nil
        self.resourceObjects = nil
    }

    /**
     * Initializes this `data` as a collection of `ResourceIdentifierObject`s.
     *
     * For an empty collection simple pass an empty array to the initializer.
     * This will serialize into an empty JSON array. If you want a JSON null object to represent
     * empty single-resources, see `init()`.
     *
     * - parameter resourceIdentifierObjects: The array of `ResourceIdentifierObject`s which represent this data.
     */
    public init(resourceIdentifierObjects: [JsonApiResourceIdentifierObject]) {
        self.resourceIdentifierObjects = resourceIdentifierObjects
        self.resourceIdentifierObject = nil

        self.resourceObject = nil
        self.resourceObjects = nil
    }

    public func makeJSON() throws -> JSON {
        let json: JSON

        if let resourceObject = resourceObject {
            json = try resourceObject.makeJSON()
        } else if let resourceObjects = resourceObjects {
            var rJsonObjects: [JSON] = []
            for r in resourceObjects {
                rJsonObjects.append(try r.makeJSON())
            }
            json = JSON(rJsonObjects)
        } else if let resourceIdentifierObject = resourceIdentifierObject {
            json = try resourceIdentifierObject.makeJSON()
        } else if let resourceIdentifierObjects = resourceIdentifierObjects {
            var rJsonIdentifiers: [JSON] = []
            for r in resourceIdentifierObjects {
                rJsonIdentifiers.append(try r.makeJSON())
            }
            json = JSON(rJsonIdentifiers)
        } else {
            json = JSON(Node(nilLiteral: ()))
        }

        return json
    }
}
