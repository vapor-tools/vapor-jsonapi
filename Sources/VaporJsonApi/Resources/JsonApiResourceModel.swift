//
//  JsonApiResourceModel.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 01/05/2017.
//
//

import Vapor
import HTTP
import Fluent

public class JsonApiResourceModel: Model, JsonApiResourceRepresentable {

    // MARK: - JsonApiResourceRepresentable stubs

    public static var resourceType: JsonApiResourceType {
        return ""
    }

    public func attributes() throws -> JsonApiAttributes {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'JsonApiResourceModel' must implement attributes()")
    }

    public func parentRelationships() throws -> JsonApiParentRelationships {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'JsonApiResourceModel' must implement parentRelationships()")
    }

    public func childrenRelationships() throws -> JsonApiChildrenRelationships {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'JsonApiResourceModel' must implement childrenRelationships()")
    }

    public func siblingsRelationships() throws -> JsonApiSiblingsRelationships {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'JsonApiResourceModel' must implement siblingsRelationships()")
    }

    // MARK: - Model stubs

    public var id: Node?

    public required init(node: Node, in context: Context) throws {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'Model' must implement init(node:in context)")
    }

    public func makeNode(context: Context) throws -> Node {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'Model' must implement makeNode()")
    }

    public static func prepare(_ database: Database) throws {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'Model' must implement prepare(_:)")
    }

    public static func revert(_ database: Database) throws {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'Model' must implement revert(_:)")
    }
}
