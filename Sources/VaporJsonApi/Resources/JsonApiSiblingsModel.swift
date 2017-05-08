//
//  JsonApiSiblingsModel.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 07/05/2017.
//
//

import Vapor
import Fluent

public struct JsonApiSiblingsModel<T: JsonApiResourceModel> {

    public typealias JsonApiSiblingsGetter = () throws -> Siblings<T>
    public typealias JsonApiSiblingsAdder = ([T]) throws -> ()
    public typealias JsonApiSiblingsReplacer = ([T]) throws -> ()

    public var type: JsonApiResourceModel.Type {
        return T.self
    }

    public let getter: JsonApiSiblingsGetter
    public let adder: JsonApiSiblingsAdder?
    public let replacer: JsonApiSiblingsReplacer?

    public init(getter: @escaping JsonApiSiblingsGetter, adder: JsonApiSiblingsAdder? = nil, replacer: JsonApiSiblingsReplacer? = nil) {
        self.getter = getter
        self.adder = adder
        self.replacer = replacer
    }

    public init<S: JsonApiResourceModel>(toSibling: S, localKey: String? = nil, foreignKey: String? = nil) {
        getter = {
            return try toSibling.siblings(localKey, foreignKey)
        }

        // TODO: Don't allow duplicate linkage
        self.adder = { siblings in
            for s in siblings {
                var p = Pivot<S, T>(toSibling, s)
                try p.save()
            }
        }
        self.replacer = { siblings in
            let oldSiblings: Siblings<T> = try toSibling.siblings(localKey, foreignKey)
            try oldSiblings.delete()
            for s in siblings {
                var p = Pivot<S, T>(toSibling, s)
                try p.save()
            }
        }
    }
}
