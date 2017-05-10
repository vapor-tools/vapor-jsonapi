//
//  JsonApiSiblingsModel.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 07/05/2017.
//
//

import Vapor
import Fluent

public struct JsonApiSiblingsModel {

    public typealias JsonApiSiblingsGetter = () throws -> [JsonApiResourceModel]
    public typealias JsonApiSiblingsAdder = ([JsonApiResourceModel]) throws -> ()
    public typealias JsonApiSiblingsReplacer = ([JsonApiResourceModel]) throws -> ()

    public var type: JsonApiResourceModel.Type

    public let getter: JsonApiSiblingsGetter
    public let adder: JsonApiSiblingsAdder?
    public let replacer: JsonApiSiblingsReplacer?

    public init(siblingType: JsonApiResourceModel.Type, getter: @escaping JsonApiSiblingsGetter, adder: JsonApiSiblingsAdder? = nil, replacer: JsonApiSiblingsReplacer? = nil) {
        self.getter = getter
        self.adder = adder
        self.replacer = replacer
        self.type = siblingType
    }

    public init<S: JsonApiResourceModel, T: JsonApiResourceModel>(model: S, siblingType: T.Type, localKey: String? = nil, foreignKey: String? = nil) {
        getter = {
            let elements: [S] = try model.siblings(localKey, foreignKey).all()
            return elements
        }

        // TODO: Don't allow duplicate linkage
        self.adder = { siblings in
            for s in siblings {
                var p = Pivot<S, T>(model, s)
                try p.save()
            }
        }
        self.replacer = { siblings in
            let oldSiblings: Siblings<T> = try model.siblings(localKey, foreignKey)
            try oldSiblings.delete()
            for s in siblings {
                var p = Pivot<S, T>(model, s)
                try p.save()
            }
        }

        self.type = siblingType
    }
}
