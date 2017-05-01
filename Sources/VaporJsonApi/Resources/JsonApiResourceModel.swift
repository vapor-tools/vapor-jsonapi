//
//  JsonApiResourceModel.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 01/05/2017.
//
//

import Vapor
import HTTP

public protocol JsonApiResourceModel: Model {

    typealias JsonApiAttributes = [String: JSON?]
    typealias JsonApiRelationships = [String: JsonApiResourceModel.Type]

    var resourceType: JsonApiResourceType { get }

    func attributes() throws -> JsonApiAttributes

    func relationships() throws -> JsonApiRelationships
}

public extension JsonApiResourceModel {

    public func makeResourceObject() throws -> JsonApiResourceObject {
        guard let id = self.id?.string else {
            throw JsonApiInternalServerError(title: "Internal Server Error", detail: "A fetched model does not seem to have a valid id.")
        }
        let attributes = JsonApiAttributesObject(attributes: try JSON(node: self.attributes()))
        /*
        let relationships = JsonApiRelationshipsObject(relationshipObjects: [])
        let resourceObject = JsonApiResourceObject(id: id, type: resourceType, attributes: attributes, relationships: relationships, links: links, meta: meta)
         */

        // TODO: Finish implementing makeResourceObject
        throw JsonApiInternalServerError()
    }
}
