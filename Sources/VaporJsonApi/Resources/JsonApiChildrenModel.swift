//
//  JsonApiChildrenModel.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 07/05/2017.
//
//

import Vapor
import Fluent

public struct JsonApiChildrenModel {

    public typealias JsonApiChildrenGetter = (_ paginator: JsonApiPaginator) throws -> [JsonApiResourceModel]
    public typealias JsonApiChildrenAdder = ([JsonApiResourceModel]) throws -> ()
    public typealias JsonApiChildrenReplacer = ([JsonApiResourceModel]) throws -> ()

    public var type: JsonApiResourceModel.Type

    public let getter: JsonApiChildrenGetter
    public let adder: JsonApiChildrenAdder?
    public let replacer: JsonApiChildrenReplacer?

    public let findInModel: (_ id: NodeRepresentable) throws -> JsonApiResourceModel?

    public init<T: JsonApiResourceModel>(childrenType: T.Type, getter: @escaping JsonApiChildrenGetter, adder: JsonApiChildrenAdder? = nil, replacer: JsonApiChildrenReplacer? = nil) {
        self.type = childrenType
        self.getter = getter
        self.adder = adder
        self.replacer = replacer

        self.findInModel = { id in
            return try T.find(id)
        }
    }
}
