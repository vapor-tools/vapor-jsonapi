//
//  JsonApiParentModel.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 07/05/2017.
//
//

import Vapor
import Fluent

public struct JsonApiParentModel<T: JsonApiResourceModel> {

    public typealias JsonApiParentGetter = () throws -> Parent<T>
    public typealias JsonApiParentSetter = (_ parent: T) throws -> ()

    public var type: JsonApiResourceModel.Type {
        return T.self
    }

    public let getter: JsonApiParentGetter
    public let setter: JsonApiParentSetter?

    public init(getter: @escaping JsonApiParentGetter, setter: JsonApiParentSetter? = nil) {
        self.getter = getter
        self.setter = setter
    }

    public init(child: JsonApiResourceModel, parentId: Node, foreignKey: String? = nil, setter: JsonApiParentSetter? = nil) {
        getter = {
            return try child.parent(parentId, foreignKey, T.self)
        }

        self.setter = setter
    }
}
