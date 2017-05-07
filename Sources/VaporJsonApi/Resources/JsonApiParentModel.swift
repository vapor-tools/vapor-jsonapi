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
    public let setter: JsonApiParentSetter

    public init(getter: @escaping JsonApiParentGetter, setter: @escaping JsonApiParentSetter) {
        self.getter = getter
        self.setter = setter
    }

    public init<C: JsonApiResourceModel>(child: C, parentId: Node, foreignKey: String?) {
        getter = {
            return try child.parent(parentId, foreignKey, T.self)
        }

        setter = { parent in
            let p = Parent<T>(child: child, parentId: parentId, foreignKey: foreignKey)
            var par = try p.get()
            try par?.save()
        }
    }
}
