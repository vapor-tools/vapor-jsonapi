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
import URI

public protocol JsonApiResourceController {
    associatedtype Resource: JsonApiResourceModel

    func getResources(_ req: Request) throws -> ResponseRepresentable
}

public extension JsonApiResourceController {

    public var resourceType: JsonApiResourceType {
        return Resource.resourceType
    }

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

        let page = try pageForQuery(query: query)
        let pageNumber = page.pageNumber
        let pageCount = page.pageCount

        let resources = try Resource.query().limit(pageCount, withOffset: (pageNumber * pageCount) - pageCount).all()
        let jsonDocument = try document(forResources: resources, baseUrl: req.uri)

        return JsonApiResponse(status: .ok, document: jsonDocument)
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
     * The `getRelatedResource` method is responsible for get requests to a relationship of a specific resource.
     *
     * Example: `/articles/5/author` for the author resource of the article with id `5`.
     *
     * - parameter req: The `Request` which fired this method.
     * - parameter id: The id represented as a String which is the first route parameter for this request.
     * - parameter relationshipType: The relationshipType represented as a String which is the relationship name as defined in the JsonApiResourceModel.
     */
    func getRelatedResource(_ req: Request, _ id: String, _ relationshipType: String) throws -> ResponseRepresentable {

        guard req.fulfillsJsonApiAcceptResponsibilities() else {
            throw JsonApiNotAcceptableError(mediaType: req.acceptHeaderValue() ?? "*No Accept header*")
        }

        guard let resource = try Resource.find(id) else {
            throw JsonApiRecordNotFoundError(id: id)
        }

        print(id)
        print(relationshipType)
        print(try resource.parentRelationships().debugDescription)
        print(try resource.parentRelationships()[relationshipType] ?? "Nothing!?")

        let query = req.jsonApiQuery()

        if let parentModel = try resource.parentRelationships()[relationshipType] {
            if let parent = try parentModel.getter() {
                let resourceObject = try parent.makeResourceObject(resourceModel: parent, baseUrl: req.uri)
                let data = JsonApiData(resourceObject: resourceObject)
                let document = JsonApiDocument(data: data)

                return JsonApiResponse(status: .ok, document: document)
            } else {
                let document = JsonApiDocument()
                return JsonApiResponse(status: .ok, document: document)
            }
        } else if let childrenCollection = try resource.childrenRelationships()[relationshipType] {

            let page = try pageForQuery(query: query)
            let pageNumber = page.pageNumber
            let pageCount = page.pageCount

            let paginator = JsonApiPagedPaginator(pageCount: pageCount, pageSize: pageNumber)
            let resources = try childrenCollection.getter(paginator)

            let jsonDocument = try document(forResources: resources, baseUrl: req.uri)

            return JsonApiResponse(status: .ok, document: jsonDocument)
        } else if let siblingsCollection = try resource.siblingsRelationships()[relationshipType] {

            let page = try pageForQuery(query: query)
            let pageNumber = page.pageNumber
            let pageCount = page.pageCount

            let paginator = JsonApiPagedPaginator(pageCount: pageCount, pageSize: pageNumber)
            let resources = try siblingsCollection.getter(paginator)

            let jsonDocument = try document(forResources: resources, baseUrl: req.uri)

            return JsonApiResponse(status: .ok, document: jsonDocument)
        }

        throw JsonApiRelationshipNotFoundError(relationship: relationshipType)
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

        guard let type = req.jsonApiJson?["type"]?.string else {
            throw JsonApiParameterMissingError(parameter: "type")
        }
        guard type == Resource.resourceType.parse() else {
            throw JsonApiTypeConflictError(type: type)
        }

        let bodyData = req.jsonApiJson?["data"]

        let node = bodyData?["attributes"]?.makeNode()
        var resource = try Resource(node: node)

        // TODO: Set relationships
        if let relationships = bodyData?["relationships"]?.object {
            for r in relationships {
                
            }
        }
        try resource.save()

        // Return newly saved object as jsonapi resource
        let resourceObject = try resource.makeResourceObject(resourceModel: resource, baseUrl: req.uri)

        let data = JsonApiData(resourceObject: resourceObject)
        let document = JsonApiDocument(data: data)

        return JsonApiResponse(status: .created, document: document)
    }
}

fileprivate extension JsonApiResourceController {

    fileprivate func pageForQuery(query: JSON) throws -> (pageCount: Int, pageNumber: Int) {
        let pageCount = query["page"]?["size"]?.string?.int ?? JsonApiConfig.defaultPageSize
        if pageCount > JsonApiConfig.maximumPageSize {
            throw JsonApiInvalidPageValueError(page: "page[size]", value: query["page"]?["size"]?.string ?? "*Nothing*")
        }
        let pageNumber = query["page"]?["number"]?.string?.int ?? 1
        if pageNumber < 1 {
            throw JsonApiInvalidPageValueError(page: "page[number]", value: query["page"]?["number"]?.string ?? "*Nothing*")
        }

        return (pageCount: pageCount, pageNumber: pageNumber)
    }

    fileprivate func document(forResources resources: [JsonApiResourceModel], baseUrl: URI) throws -> JsonApiDocument {
        var resourceObjects = [JsonApiResourceObject]()
        for r in resources {
            resourceObjects.append(try r.makeResourceObject(resourceModel: r, baseUrl: baseUrl))
        }

        let data = JsonApiData(resourceObjects: resourceObjects)
        return JsonApiDocument(data: data)
    }
}
