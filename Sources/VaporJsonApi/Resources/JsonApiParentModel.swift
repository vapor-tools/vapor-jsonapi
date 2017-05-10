//
//  JsonApiParentModel.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 07/05/2017.
//
//

import Vapor
import Fluent

public struct JsonApiParentModel {

    public typealias JsonApiParentGetter = () throws -> JsonApiResourceModel?
    public typealias JsonApiParentSetter = (_ parent: JsonApiResourceModel) throws -> ()

    public var type: JsonApiResourceModel.Type

    public let getter: JsonApiParentGetter
    public let setter: JsonApiParentSetter?

    public init(type: JsonApiResourceModel.Type, getter: @escaping JsonApiParentGetter, setter: JsonApiParentSetter? = nil) {
        self.getter = getter
        self.setter = setter
        self.type = type
    }

    public init(type: JsonApiResourceModel.Type, child: JsonApiResourceModel, parentId: Node, foreignKey: String? = nil, setter: JsonApiParentSetter? = nil) {
        getter = {
            return try child.parent(parentId, foreignKey, type).get()
        }

        self.setter = setter
        self.type = type
    }
}
