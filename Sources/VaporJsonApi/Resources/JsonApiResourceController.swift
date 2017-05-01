//
//  JsonApiResourceController.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 30/04/2017.
//
//

import Vapor
import HTTP

public protocol JsonApiResourceController {
    associatedtype Resource: JsonApiResourceModel

    func getResources(_ req: Request) throws -> ResponseRepresentable
}

public extension JsonApiResourceController {

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

        let query = req.jsonApiQuery()

        let pageCount = query["page"]?["size"]?.string?.int ?? JsonApiConfig.defaultPageSize
        if pageCount > JsonApiConfig.maximumPageSize {
            throw JsonApiInvalidPageValueError(page: "page[size]", value: query["page"]?["size"]?.string ?? "*Nothing*")
        }
        let pageNumber = query["page"]?["number"]?.string?.int ?? 1
        if pageNumber < 1 {
            throw JsonApiInvalidPageValueError(page: "page[number]", value: query["page"]?["number"]?.string ?? "*Nothing*")
        }
        let resources = try Resource.query().limit(pageCount, withOffset: (pageNumber * pageCount) - pageCount).all()

        return "Hello"
    }
}
