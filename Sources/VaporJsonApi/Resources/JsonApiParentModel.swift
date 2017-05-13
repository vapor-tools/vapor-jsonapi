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

    public let findInModel: (_ id: NodeRepresentable) throws -> JsonApiResourceModel?
    public let resourceType: JsonApiResourceType

    public init<T: JsonApiResourceModel>(parentType: T.Type, getter: @escaping JsonApiParentGetter, setter: JsonApiParentSetter? = nil) {
        self.getter = getter
        self.setter = setter
        self.type = parentType

        self.findInModel = { id in
            return try T.find(id)
        }
        self.resourceType = T.resourceType
    }
}
