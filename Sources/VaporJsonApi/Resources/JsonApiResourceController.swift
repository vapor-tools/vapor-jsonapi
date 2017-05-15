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
        let pagination = JsonApiPagedPaginator(pageCount: page.pageCount, pageSize: page.pageNumber)

        let resources = try Resource.query().limit(pagination.pageCount, withOffset: pagination.pageOffset).all()
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
     * The `getRelationships` method is responsible for get requests to a resource linkage object for a resource.
     *
     * Example: `/articles/5/relationships/author` for the author resource linkage of the article with id `5`.
     *
     * - parameter req: The `Request` which fired this method.
     * - parameter id: The id represented as a String which is the first route parameter for this request.
     * - parameter relationshipType: The relationshipType represented as a String which is the relationship name as defined in the JsonApiResourceModel.
     */
    func getRelationships(_ req: Request, _ id: String, _ relationshipType: String) throws -> ResponseRepresentable {

        guard req.fulfillsJsonApiAcceptResponsibilities() else {
            throw JsonApiNotAcceptableError(mediaType: req.acceptHeaderValue() ?? "*No Accept header*")
        }

        guard let resource = try Resource.find(id) else {
            throw JsonApiRecordNotFoundError(id: id)
        }

        let query = req.jsonApiQuery()

        if let parentModel = try resource.parentRelationships()[relationshipType] {
            if let parent = try parentModel.getter() {
                let resourceIdentifierObject = try parent.makeResourceIdentifierObject(resourceModel: parent)
                let data = JsonApiData(resourceIdentifierObject: resourceIdentifierObject)
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

            let jsonDocument = try resourceLinkageDocument(forResources: resources, baseUrl: req.uri)

            return JsonApiResponse(status: .ok, document: jsonDocument)
        } else if let siblingsCollection = try resource.siblingsRelationships()[relationshipType] {

            let page = try pageForQuery(query: query)
            let pageNumber = page.pageNumber
            let pageCount = page.pageCount

            let paginator = JsonApiPagedPaginator(pageCount: pageCount, pageSize: pageNumber)
            let resources = try siblingsCollection.getter(paginator)

            let jsonDocument = try resourceLinkageDocument(forResources: resources, baseUrl: req.uri)

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

        let bodyData = req.jsonApiJson?["data"]

        guard let type = bodyData?["type"]?.string else {
            throw JsonApiParameterMissingError(parameter: "type")
        }
        guard type == Resource.resourceType.parse() else {
            throw JsonApiTypeConflictError(type: type)
        }

        var resource: Resource
        if let node = bodyData?["attributes"]?.makeNode() {
            resource = try Resource(node: node)
        } else {
            throw JsonApiAttributesRequiredError()
        }

        // TODO: Check jsonapi document for correct to-many relationship handling
        if let relationships = bodyData?["relationships"]?.object {
            for r in relationships {
                // Get relationships
                let parents = try resource.parentRelationships()
                let children = try resource.childrenRelationships()
                let siblings = try resource.siblingsRelationships()

                if let parent = parents[r.key] {
                    guard let id = r.value.object?["id"]?.string, let type = r.value.object?["type"]?.string else {
                        throw JsonApiBadRequestError(title: "Bad Request", detail: "The relationship \(r.key) must have a type and id value.")
                    }
                    guard let p = try parent.findInModel(id) else {
                        throw JsonApiRecordNotFoundError(id: id)
                    }
                    // Check type
                    guard type == parent.resourceType.parse() else {
                        throw JsonApiTypeConflictError(type: type)
                    }

                    guard let setter = parent.setter else {
                        throw JsonApiRelationshipNotAllowedError(relationship: type)
                    }

                    try setter(p)
                } else if let _ = children[r.key] {
                    // throw JsonApiBadRequestError(title: "Setting to-many relationships not allowed", detail: "You set to-many relationships in the same step as creating a resource right now. You tried to set \(r.key) for this resource.")
                } else if let _ = siblings[r.key] {
                    // throw JsonApiBadRequestError(title: "Setting to-many relationships not allowed", detail: "You set to-many relationships in the same step as creating a resource right now. You tried to set \(r.key) for this resource.")
                } else {
                    throw JsonApiRelationshipNotAllowedError(relationship: r.key)
                }
            }
        }
        try resource.save()

        // Return newly saved object as jsonapi resource
        let resourceObject = try resource.makeResourceObject(resourceModel: resource, baseUrl: req.uri)

        let data = JsonApiData(resourceObject: resourceObject)
        let document = JsonApiDocument(data: data)

        return JsonApiResponse(status: .created, document: document)
    }

    /**
     * The `patchResource` method is responsible for patch requests to a specific resource.
     *
     * Example: `/articles/1` for editing an article resource.
     *
     * - parameter req: The `Request` which fired this method.
     * - parameter id: The id represented as a String which is the first and only route parameter for this request.
     */
    func patchResource(_ req: Request, _ id: String) throws -> ResponseRepresentable {

        guard req.fulfillsJsonApiAcceptResponsibilities() else {
            throw JsonApiNotAcceptableError(mediaType: req.acceptHeaderValue() ?? "*No Accept header*")
        }

        guard req.fulfillsJsonApiContentTypeResponsibilities() else {
            throw JsonApiUnsupportedMediaTypeError(mediaType: req.contentTypeHeaderValue() ?? "*No Content-Type header*")
        }

        let bodyData = req.jsonApiJson?["data"]

        // Check type
        guard let type = bodyData?["type"]?.string else {
            throw JsonApiParameterMissingError(parameter: "type")
        }
        guard type == Resource.resourceType.parse() else {
            throw JsonApiTypeConflictError(type: type)
        }

        // Check id
        guard let bodyId = bodyData?["id"]?.string else {
            throw JsonApiMissingKeyError()
        }
        guard bodyId == id else {
            throw JsonApiKeyNotIncludedInURLError(key: bodyId)
        }

        // Check resource
        guard var resource = try Resource.find(id) else {
            throw JsonApiRecordNotFoundError(id: id)
        }

        if let node = bodyData?["attributes"]?.makeNode() {
            try resource.update(node: node)
        }

        if let relationships = bodyData?["relationships"]?.object {
            for r in relationships {
                // Get relationships
                let parents = try resource.parentRelationships()
                let children = try resource.childrenRelationships()
                let siblings = try resource.siblingsRelationships()

                if let parent = parents[r.key] {
                    guard let id = r.value.object?["id"]?.string, let type = r.value.object?["type"]?.string else {
                        throw JsonApiBadRequestError(title: "Bad Request", detail: "The relationship \(r.key) must have a type and id value.")
                    }
                    guard let p = try parent.findInModel(id) else {
                        throw JsonApiRecordNotFoundError(id: id)
                    }
                    // Check type
                    guard type == parent.resourceType.parse() else {
                        throw JsonApiTypeConflictError(type: type)
                    }

                    guard let setter = parent.setter else {
                        throw JsonApiRelationshipNotAllowedError(relationship: type)
                    }

                    try setter(p)
                } else if let child = children[r.key] {
                    guard let childs = r.value.array else {
                        throw JsonApiBadRequestError(title: "Bad relationship object", detail: "A to-many relationship must be provided as an array in the relationships object.")
                    }
                    var resources: [JsonApiResourceModel] = []
                    for c in childs {
                        guard let id = c.object?["id"]?.string, let type = c.object?["type"]?.string else {
                            throw JsonApiBadRequestError(title: "Bad Request", detail: "The relationship \(r.key) must have a type and id value.")
                        }
                        guard let cc = try child.findInModel(id) else {
                            throw JsonApiRecordNotFoundError(id: id)
                        }
                        // Check type
                        guard type == child.resourceType.parse() else {
                            throw JsonApiTypeConflictError(type: type)
                        }

                        resources.append(cc)
                    }

                    // Check replacer
                    guard let replacer = child.replacer else {
                        throw JsonApiToManySetReplacementForbiddenError()
                    }

                    try replacer(resources)
                } else if let sibling = siblings[r.key] {
                    guard let siblings = r.value.array else {
                        throw JsonApiBadRequestError(title: "Bad relationship object", detail: "A to-many relationship must be provided as an array in the relationships object.")
                    }
                    var resources: [JsonApiResourceModel] = []
                    for s in siblings {
                        guard let id = s.object?["id"]?.string, let type = s.object?["type"]?.string else {
                            throw JsonApiBadRequestError(title: "Bad Request", detail: "The relationship \(r.key) must have a type and id value.")
                        }
                        guard let ss = try sibling.findInModel(id) else {
                            throw JsonApiRecordNotFoundError(id: id)
                        }
                        // Check type
                        guard type == sibling.resourceType.parse() else {
                            throw JsonApiTypeConflictError(type: type)
                        }

                        resources.append(ss)
                    }

                    // Check replacer
                    guard let replacer = sibling.replacer else {
                        throw JsonApiToManySetReplacementForbiddenError()
                    }
                    
                    try replacer(resources)
                } else {
                    throw JsonApiRelationshipNotAllowedError(relationship: r.key)
                }
            }
        }
        try resource.save()

        // Return newly saved object as jsonapi resource
        let resourceObject = try resource.makeResourceObject(resourceModel: resource, baseUrl: req.uri)

        let data = JsonApiData(resourceObject: resourceObject)
        let document = JsonApiDocument(data: data)

        return JsonApiResponse(status: .ok, document: document)
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

    fileprivate func resourceLinkageDocument(forResources resources: [JsonApiResourceModel], baseUrl: URI) throws -> JsonApiDocument {
        var resourceIdentifierObjects = [JsonApiResourceIdentifierObject]()
        for r in resources {
            resourceIdentifierObjects.append(try r.makeResourceIdentifierObject(resourceModel: r))
        }

        let data = JsonApiData(resourceIdentifierObjects: resourceIdentifierObjects)
        return JsonApiDocument(data: data)
    }
}
