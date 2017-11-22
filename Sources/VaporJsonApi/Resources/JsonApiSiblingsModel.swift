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

    public typealias JsonApiSiblingsGetter = (_ paginator: JsonApiPaginator) throws -> [JsonApiResourceModel]
    public typealias JsonApiSiblingsAdder = ([JsonApiResourceModel]) throws -> ()
    public typealias JsonApiSiblingsReplacer = ([JsonApiResourceModel]) throws -> ()

    public var type: JsonApiResourceModel.Type

    public let getter: JsonApiSiblingsGetter
    public let adder: JsonApiSiblingsAdder?
    public let replacer: JsonApiSiblingsReplacer?

    public let findInModel: (_ id: NodeRepresentable) throws -> JsonApiResourceModel?
    public let resourceType: JsonApiResourceType

    public init<T: JsonApiResourceModel>(siblingType: T.Type, getter: @escaping JsonApiSiblingsGetter, adder: JsonApiSiblingsAdder? = nil, replacer: JsonApiSiblingsReplacer? = nil) {
        self.getter = getter
        self.adder = adder
        self.replacer = replacer
        self.type = siblingType

        self.findInModel = { id in
            return try T.find(id)
        }
        self.resourceType = T.resourceType
    }

    public init<S: JsonApiResourceModel, T: JsonApiResourceModel>(model: S, siblingType: T.Type, localKey: String, foreignKey: String) {
        getter = { paginator in
            let elements = try model.siblings(to: S.self, through: T.self, localIdKey: localKey, foreignIdKey: foreignKey).limit(paginator.pageCount, offset: paginator.pageOffset).all()
            return elements
        }

        // TODO: Don't allow duplicate linkage
        self.adder = { siblings in
            for s in siblings {
                if let s = s as? T {
                    let p = try Pivot<S, T>(model, s)
                    try p.save()
                }
            }
        }
        self.replacer = { siblings in
            let oldSiblings = model.siblings(to: S.self, through: T.self, localIdKey: localKey, foreignIdKey: foreignKey)
            try oldSiblings.delete()
            for s in siblings {
                if let s = s as? T {
                    let p = try Pivot<S, T>(model, s)
                    try p.save()
                }
            }
        }

        self.type = siblingType

        self.findInModel = { id in
            return try T.find(id)
        }
        self.resourceType = T.resourceType
    }
}
