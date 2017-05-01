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

    /**
     * The `getResources` method is responsible for get requests to the resource collection.
     *
     * Example: `/articles` for the article resource.
     *
     * - parameter req: The `Request` which fired this method.
     */
    func getResources(_ req: Request) throws -> ResponseRepresentable {

        guard req.fulfillsJsonApiAcceptResponsibilities() else {
            throw JsonApiNotAcceptableError(mediaType: req.acceptHeaderValue() ?? "*No Accept header*")
        }

        return "Hello"
    }
}
