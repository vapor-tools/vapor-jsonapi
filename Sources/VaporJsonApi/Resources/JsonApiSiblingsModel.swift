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
    public let adder: JsonApiSiblingsAdder
    public let replacer: JsonApiSiblingsReplacer?

    public init(getter: @escaping JsonApiSiblingsGetter, adder: @escaping JsonApiSiblingsAdder, replacer: JsonApiSiblingsReplacer? = nil) {
        self.getter = getter
        self.adder = adder
        self.replacer = replacer
    }
}
