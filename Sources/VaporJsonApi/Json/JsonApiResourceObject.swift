//
//  JsonApiResourceObject.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 30/04/2017.
//
//

import Vapor
import URI

public class JsonApiResourceObject: JSONRepresentable {

    public let id: String
    public let type: JsonApiResourceType
    public let attributes: JsonApiAttributesObject?
    public let relationships: JsonApiRelationshipsObject?
    public let links: JsonApiLinksObject?
    public let meta: JsonApiMeta?

    /**
     * Initializes a new ResourceObject with the given values.
     *
     * - parameter id: The `id` value of this resource.
     * - parameter type: The `type` value of this resource.
     * - parameter attributes: The optional `attributes` object of this resource.
     * - parameter relationships: The optional `relationships` object of this resource.
     * - parameter links: The optional `links` object of this resource.
     * - parameter meta: The optional `meta` object of this resource.
     */
    public init(
        id: String,
        type: JsonApiResourceType,
        attributes: JsonApiAttributesObject? = nil,
        relationships: JsonApiRelationshipsObject? = nil,
        links: JsonApiLinksObject? = nil,
        meta: JsonApiMeta? = nil) {
        self.id = id
        self.type = type
        self.attributes = attributes
        self.relationships = relationships
        self.links = links
        self.meta = meta
    }

    public func makeJSON() throws -> JSON {
        var json = try JSON(node: [
            "id": Node(id),
            "type": Node(type.parse())
            ])

        if let attributes = attributes {
            json["attributes"] = try attributes.makeJSON()
        }
        if let relationships = relationships {
            json["relationships"] = try relationships.makeJSON()
        }
        if let links = links {
            json["links"] = try links.makeJSON()
        }
        if let meta = meta {
            json["meta"] = try meta.makeJSON()
        }

        return json
    }
}

public class JsonApiAttributesObject: JSONRepresentable {

    public let attributes: JSON

    /**
     * Initializes a new attributes object as described in the jsonapi documentation.
     *
     * See http://jsonapi.org/format/#document-resource-object-attributes
     *
     * `attributes` is expected to be a JSON object as described in the jsonapi documentation rather than
     * a primitive type or an array.
     *
     * - parameter attributes: A json object containing any elements which represents the attributes.
     */
    public init(attributes: JSON) {
        self.attributes = attributes
    }

    public func makeJSON() throws -> JSON {
        return attributes
    }
}

public class JsonApiRelationshipsObject: JSONRepresentable {

    public let relationshipObjects: [JsonApiRelationshipObject]

    public init(relationshipObjects: [JsonApiRelationshipObject]) {
        self.relationshipObjects = relationshipObjects
    }

    public func makeJSON() throws -> JSON {
        var json = try JSON(node: [:])

        for relationshipObject in relationshipObjects {
            json[relationshipObject.name] = try relationshipObjects.makeJSON()
        }

        return json
    }
}

public class JsonApiRelationshipObject: JSONRepresentable {

    public let name: String
    public let links: JsonApiLinksObject?
    public let data: JsonApiResourceLinkage?
    public let meta: JsonApiMeta?

    public init(name: String, links: JsonApiLinksObject, data: JsonApiResourceLinkage? = nil, meta: JsonApiMeta? = nil) {
        self.name = name
        self.links = links
        self.data = data
        self.meta = meta
    }

    public init(name: String, data: JsonApiResourceLinkage, links: JsonApiLinksObject? = nil, meta: JsonApiMeta? = nil) {
        self.name = name
        self.links = links
        self.data = data
        self.meta = meta
    }

    public init(name: String, meta: JsonApiMeta, links: JsonApiLinksObject? = nil, data: JsonApiResourceLinkage? = nil) {
        self.name = name
        self.links = links
        self.data = data
        self.meta = meta
    }

    public func makeJSON() throws -> JSON {
        var json = try JSON(node: [:])

        if let links = links {
            json["links"] = try links.makeJSON()
        }

        if let data = data {
            json["data"] = try data.makeJSON()
        }

        if let meta = meta {
            json["meta"] = try meta.makeJSON()
        }
        
        return json
    }
}

public class JsonApiLinksObject: JSONRepresentable {

    public let selfLink: URI
    public let selfMeta: JsonApiMeta?

    public let relatedLink: URI
    public let relatedMeta: JsonApiMeta?

    public init(selfLink: URI, selfMeta: JsonApiMeta? = nil, relatedLink: URI, relatedMeta: JsonApiMeta? = nil) {
        self.selfLink = selfLink
        self.selfMeta = selfMeta

        self.relatedLink = relatedLink
        self.relatedMeta = relatedMeta
    }

    public func makeJSON() throws -> JSON {
        let selfJson: JSON
        if let selfMeta = selfMeta {
            selfJson = try JSON(node: [
                "href": try selfLink.makeFoundationURL().absoluteString,
                "meta": selfMeta.makeJSON()
                ])
        } else {
            selfJson = try JSON(Node(selfLink.makeFoundationURL().absoluteString))
        }

        let relatedJson: JSON
        if let relatedMeta = relatedMeta {
            relatedJson = try JSON(node: [
                "href": try relatedLink.makeFoundationURL().absoluteString,
                "meta": relatedMeta.makeJSON()
                ])
        } else {
            relatedJson = try JSON(Node(relatedLink.makeFoundationURL().absoluteString))
        }

        return try JSON(node: [
            "self": selfJson,
            "related": relatedJson
            ])
    }
}

public class JsonApiResourceLinkage: JSONRepresentable {

    public let resourceIdentifierObject: JsonApiResourceIdentifierObject?
    public let resourceIdentifierObjects: [JsonApiResourceIdentifierObject]?

    /**
     * Initializes this ResourceLinkage as a JSON `null` object.
     *
     */
    public init() {
        self.resourceIdentifierObject = nil
        self.resourceIdentifierObjects = nil
    }

    /**
     * Initializes this ResourceLinkage as a to-one linkage with the given `ResourceIdentifierObject`.
     *
     * - parameter resourceIdentifierObject: The `ResourceIdentifierObject` which represents the to-one linkage.
     */
    public init(resourceIdentifierObject: JsonApiResourceIdentifierObject) {
        self.resourceIdentifierObject = resourceIdentifierObject
        self.resourceIdentifierObjects = nil
    }

    /**
     * Initializes this ResourceLinkage as a to-many linkage with the given array of `ResourceIdentifierObject`s.
     *
     * An empty array will be serialized to an empty JSON array which represents an empty to-many linkage.
     * For an empty to-one linkage see `init()`.
     *
     * - parameter resourceIdentifierObjects: The `ResourceIdentifierObject`s which represent the to-many linkage.
     */
    public init(resourceIdentifierObjects: [JsonApiResourceIdentifierObject]) {
        self.resourceIdentifierObjects = resourceIdentifierObjects
        self.resourceIdentifierObject = nil
    }

    public func makeJSON() throws -> JSON {
        let json: JSON
        if let resourceIdentifierObject = resourceIdentifierObject {
            json = try resourceIdentifierObject.makeJSON()
        } else if let resourceIdentifierObjects = resourceIdentifierObjects {
            var resourceIdentifierObjectJsons: [JSON] = []
            for r in resourceIdentifierObjects {
                resourceIdentifierObjectJsons.append(try r.makeJSON())
            }

            json = JSON(resourceIdentifierObjectJsons)
        } else {
            json = JSON(Node(nilLiteral: ()))
        }

        return json
    }
}

public class JsonApiResourceIdentifierObject: JSONRepresentable {

    public let id: String
    public let type: JsonApiResourceType
    public let meta: JsonApiMeta?

    /**
     * Initializes a new instance of `ResourceIdentifierObject` which represents a jsonapi resource identifier object.
     *
     * - parameter id: The `id` of this `ResourceIdentifierObject`.
     * - parameter type: The `type` of this `ResourceIdentifierObject`.
     * - parameter meta: An optional `meta` object to be added to the `ResourceIdentifierObject`.
     */
    public init(id: String, type: JsonApiResourceType, meta: JsonApiMeta? = nil) {
        self.id = id
        self.type = type
        self.meta = meta
    }

    public func makeJSON() throws -> JSON {
        var json = try JSON(node: [
            "id": Node(id),
            "type": Node(type.parse())
            ])
        if let meta = meta {
            json["meta"] = try meta.makeJSON()
        }

        return json
    }
}
