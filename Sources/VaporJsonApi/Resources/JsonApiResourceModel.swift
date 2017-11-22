//
//  JsonApiResourceModel.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 01/05/2017.
//
//

import Vapor
import HTTP
import FluentProvider

open class JsonApiResourceModel: Model, JsonApiResourceRepresentable {

    /// The storage
    public var storage: Storage = Storage()

    // MARK: - JsonApiResourceRepresentable stubs

    open class var resourceType: JsonApiResourceType {
        fatalError("Subclasses of JsonApiResourceModel MUST implement 'class var resourceType'")
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

    /**
     * Initializes all required and optional attributes from the given `row`, runs validations and
     * throws if these validations are not satisfied.
     *
     * `id` will not be available inside `row` as this initializer will only be called to create
     * new resources. Subclasses may not require an id value for this initializer.
     *
     * - parameter row: A row element where all of the attributes are stored.
     */
    public required init(row: Row) throws {}

    open func update(json: JSON) throws {
        throw JsonApiUpdateNotAllowedError()
    }

    open func makeRow() throws -> Row {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'Model' must implement makeRow()")
    }

    open class func prepare(_ database: Database) throws {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'Model' must implement prepare(_:)")
    }

    open class func revert(_ database: Database) throws {
        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "Subclasses of 'Model' must implement revert(_:)")
    }

    public static func make(for parameter: String) throws -> Self {
        let id = Identifier(parameter)
        guard let found = try find(id) else {
            throw JsonApiRecordNotFoundError(id: parameter)
        }
        return found
    }
}
