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

open class JsonApiResourceModel: Model, JsonApiResourceRepresentable {

    // MARK: - JsonApiResourceRepresentable stubs

    open class var resourceType: JsonApiResourceType {
        return ""
    }

    open func attributes() throws -> JsonApiAttributes {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'JsonApiResourceModel' must implement attributes()")
    }

    open func parentRelationships() throws -> JsonApiParentRelationships {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'JsonApiResourceModel' must implement parentRelationships()")
    }

    open func childrenRelationships() throws -> JsonApiChildrenRelationships {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'JsonApiResourceModel' must implement childrenRelationships()")
    }

    open func siblingsRelationships() throws -> JsonApiSiblingsRelationships {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'JsonApiResourceModel' must implement siblingsRelationships()")
    }

    // MARK: - Model stubs

    open var id: Node?

    public init() {}

    public required init(node: Node, in context: Context) throws {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'Model' must implement init(node:in context)")
    }

    open func makeNode(context: Context) throws -> Node {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'Model' must implement makeNode()")
    }

    open class func prepare(_ database: Database) throws {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'Model' must implement prepare(_:)")
    }

    open class func revert(_ database: Database) throws {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'Model' must implement revert(_:)")
    }
}
