//
//  JsonApiChildrenModel.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 07/05/2017.
//
//

import Vapor
import Fluent

public struct JsonApiChildrenModel<T: JsonApiResourceModel> {

    public typealias JsonApiChildrenGetter = () throws -> Children<T>
    public typealias JsonApiChildrenAdder = ([T]) throws -> ()
    public typealias JsonApiChildrenReplacer = ([T]) throws -> ()

    public var type: JsonApiResourceModel.Type {
        return T.self
    }

    public let getter: JsonApiChildrenGetter
    public let adder: JsonApiChildrenAdder
    public let replacer: JsonApiChildrenReplacer?

    public init(getter: @escaping JsonApiChildrenGetter, adder: @escaping JsonApiChildrenAdder, replacer: JsonApiChildrenReplacer? = nil) {
        self.getter = getter
        self.adder = adder
        self.replacer = replacer
    }
}
