//
//  ResourceController.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 30/04/2017.
//
//

import Vapor
import HTTP

public protocol ResourceController {
    associatedtype Resource: Model

    static var resourceType: ResourceType { get }

    func getResources(_ req: Request) throws -> ResponseRepresentable
}

public extension ResourceController {

    func getResources(_ req: Request) throws -> ResponseRepresentable {

        guard req.fulfillsJsonApiAcceptResponsibilities() else {
            throw Abort.custom(status: .badRequest, message: "The Accept Header must be set!")
        }

        return "Hello"
    }
}
