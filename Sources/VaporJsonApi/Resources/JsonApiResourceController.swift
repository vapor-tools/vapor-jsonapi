//
//  JsonApiResourceController.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 30/04/2017.
//
//

import Vapor
import HTTP
import Fluent

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

        var resourceObjects = [JsonApiResourceObject]()
        for r in resources {
            resourceObjects.append(try r.makeResourceObject(resourceModel: r, baseUrl: req.uri))
        }

        let data = JsonApiData(resourceObjects: resourceObjects)
        let document = JsonApiDocument(data: data)

        return JsonApiResponse(status: .ok, document: document)
    }

    /**
     * The `getResource` method is responsible for get requests to a specific resource.
     *
     * Example: `/articles/5` for the article resource.
     *
     * - parameter req: The `Request` which fired this method.
     * - parameter id: The id represented as a String which is the first and only route parameter for this request.
     */
    func getResource(_ req: Request, _ id: String) throws -> ResponseRepresentable {

        guard req.fulfillsJsonApiAcceptResponsibilities() else {
            throw JsonApiNotAcceptableError(mediaType: req.acceptHeaderValue() ?? "*No Accept header*")
        }

        // let query = req.jsonApiQuery()

        guard let resource = try Resource.find(id) else {
            throw JsonApiRecordNotFoundError(id: id)
        }

        let resourceObject = try resource.makeResourceObject(resourceModel: resource, baseUrl: req.uri)

        let data = JsonApiData(resourceObject: resourceObject)
        let document = JsonApiDocument(data: data)

        return JsonApiResponse(status: .ok, document: document)
    }

    /**
     * The `postResource` method is responsible for post requests to a specific resource.
     *
     * Example: `/articles` for creating an article resource.
     *
     * - parameter req: The `Request` which fired this method.
     */
    func postResource(_ req: Request) throws -> ResponseRepresentable {

        guard req.fulfillsJsonApiAcceptResponsibilities() else {
            throw JsonApiNotAcceptableError(mediaType: req.acceptHeaderValue() ?? "*No Accept header*")
        }

        guard req.fulfillsJsonApiContentTypeResponsibilities() else {
            throw JsonApiUnsupportedMediaTypeError(mediaType: req.contentTypeHeaderValue() ?? "*No Content-Type header*")
        }

        guard let type = req.json?["type"]?.string else {
            throw JsonApiParameterMissingError(parameter: "type")
        }
        guard type == Resource.resourceType.parse() else {
            throw JsonApiTypeConflictError(type: type)
        }

        let node = req.json?["data"]?["attributes"]?.makeNode()
        var resource = try Resource(node: node)
        // TODO: Set relationships
        try resource.save()

        // Return newly saved object as jsonapi resource
        let resourceObject = try resource.makeResourceObject(resourceModel: resource, baseUrl: req.uri)

        let data = JsonApiData(resourceObject: resourceObject)
        let document = JsonApiDocument(data: data)

        return JsonApiResponse(status: .created, document: document)
    }
}
