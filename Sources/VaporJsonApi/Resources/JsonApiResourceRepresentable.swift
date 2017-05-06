//
//  JsonApiResourceRepresentable.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 06/05/2017.
//
//

import Vapor
import Fluent
import URI

public protocol JsonApiResourceRepresentable {

    typealias JsonApiAttributes = [String: (getter: () throws -> NodeRepresentable?, setter: (_ value: NodeRepresentable) throws -> ())]

    typealias JsonApiParentRelationships = [String: (type: JsonApiResourceModel.Type, getter: () throws -> Parent<JsonApiResourceModel>)]

    typealias JsonApiChildrenRelationships = [String: (type: JsonApiResourceModel.Type, getter: () throws -> Children<JsonApiResourceModel>)]

    typealias JsonApiSiblingsRelationships = [String: (type: JsonApiResourceModel.Type, getter: () throws -> Siblings<JsonApiResourceModel>)]

    static var resourceType: JsonApiResourceType { get }

    func attributes() throws -> JsonApiAttributes

    /**
     * Returns all `Parent` relationships defined as a key-value list where `key` represents
     * the relationship `name` and value represents a tuple with the `type` of the
     * relationship and a getter which returns the `Parent` relationship.
     *
     * See the following link for more information about Relations in Vapor:
     * [Vapor Relations](https://vapor.github.io/documentation/fluent/relation.html)
     *
     * - returns: A dictionary which defines all `Parent` relationships for this ResourceModel.
     */
    func parentRelationships() throws -> JsonApiParentRelationships

    /**
     * Returns all `Children` relationships defined as a key-value list where `key` represents
     * the relationship `name` and value represents a tuple with the `type` of the
     * relationship and a getter which returns the `Children` relationship.
     *
     * See the following link for more information about Relations in Vapor:
     * [Vapor Relations](https://vapor.github.io/documentation/fluent/relation.html)
     *
     * - returns: A dictionary which defines all `Children` relationships for this ResourceModel.
     */
    func childrenRelationships() throws -> JsonApiChildrenRelationships

    /**
     * Returns all `Siblings` relationships defined as a key-value list where `key` represents
     * the relationship `name` and value represents a tuple with the `type` of the
     * relationship an a getter which returns the `Siblings` relationship.
     *
     * See the following link for more information about Relations in Vapor:
     * [Vapor Relations](https://vapor.github.io/documentation/fluent/relation.html)
     *
     * - returns: A dictionary which defines all `Siblings` relationships for this ResourceModel.
     */
    func siblingsRelationships() throws -> JsonApiSiblingsRelationships
}

public extension JsonApiResourceRepresentable {

    /**
     * Returns this ResourceModel represented as a JsonApiResourceObject.
     * If `baseUrl` is not nil, a links object will be generated where appropriate.
     *
     * - parameter baseUrl: The `baseUrl` for which links should be generated. Must have the following format: _scheme_://_host_:_port_ (Any `path`, `query` and `fragment` elements will be ignored.)
     */
    public func makeResourceObject(resourceModel: JsonApiResourceModel, baseUrl: URI) throws -> JsonApiResourceObject {
        guard let id = resourceModel.id?.string ?? resourceModel.id?.int?.string else {
            throw JsonApiInternalServerError(title: "Internal Server Error", detail: "A fetched model does not seem to have a valid id.")
        }
        let type = type(of: self).resourceType

        var attr = try JSON(node: [:])
        for s in try attributes() {
            if let node = try s.value.getter()?.makeNode() {
                attr[s.key] = JSON(node)
            }
        }

        let attributesObject = JsonApiAttributesObject(attributes: attr)

        var relationshipObjects = [JsonApiRelationshipObject]()

        let resourcePath = "/\(type.parse())/\(id)"

        for p in try parentRelationships() {
            relationshipObjects.append(try makeParentRelationshipObject(name: p.key, type: p.value.type, getter: p.value.getter, baseUrl: baseUrl, resourcePath: resourcePath))
        }

        for c in try childrenRelationships() {
            relationshipObjects.append(try makeChildrenRelationshipObject(name: c.key, type: c.value.type, getter: c.value.getter, baseUrl: baseUrl, resourcePath: resourcePath))
        }

        for s in try siblingsRelationships() {
            relationshipObjects.append(try makeSiblingsRelationshipObject(name: s.key, type: s.value.type, getter: s.value.getter, baseUrl: baseUrl, resourcePath: resourcePath))
        }

        let relationshipsObject = JsonApiRelationshipsObject(relationshipObjects: relationshipObjects)
        return JsonApiResourceObject(id: id, type: type, attributes: attributesObject, relationships: relationshipsObject)
    }

    public func makeResourceIdentifierObject(resourceModel: JsonApiResourceModel, meta: JsonApiMeta?) throws -> JsonApiResourceIdentifierObject {
        guard let id = resourceModel.id?.string ?? resourceModel.id?.int?.string else {
            throw JsonApiInternalServerError(title: "Internal Server Error", detail: "A fetched model does not seem to have a valid id.")
        }
        return JsonApiResourceIdentifierObject(id: id, type: type(of: self).resourceType, meta: meta)
    }

    public func makeParentRelationshipObject (
        name: String,
        type: JsonApiResourceModel.Type,
        getter: (() throws -> Parent<JsonApiResourceModel>)? = nil,
        baseUrl: URI,
        resourcePath: String,
        meta: JsonApiMeta? = nil,
        data: Bool = false
        ) throws -> JsonApiRelationshipObject {
        let links = self.relationshipLinks(name: name, baseUrl: baseUrl, resourcePath: resourcePath)

        // TDOD: Resource linkage with "nil" as data: Must also be handled
        var resourceLinkage: JsonApiResourceLinkage? = nil
        if data {
            if let parent = try getter?().get() {
                guard let parentId = parent.id?.string ?? parent.id?.int?.string else {
                    throw JsonApiInternalServerError(title: "Internal Server Error", detail: "A fetched model does not seem to have a valid id.")
                }

                resourceLinkage = JsonApiResourceLinkage(resourceIdentifierObject: JsonApiResourceIdentifierObject(id: parentId, type: type.resourceType))
            }
        }

        return JsonApiRelationshipObject(name: name, links: links, data: resourceLinkage, meta: meta)
    }

    public func makeChildrenRelationshipObject (
        name: String,
        type: JsonApiResourceModel.Type,
        getter: (() throws -> Children<JsonApiResourceModel>)? = nil,
        baseUrl: URI,
        resourcePath: String,
        meta: JsonApiMeta? = nil,
        data: Bool = false
        ) throws -> JsonApiRelationshipObject {
        let links = self.relationshipLinks(name: name, baseUrl: baseUrl, resourcePath: resourcePath)

        // TODO: Pagination
        var resourceLinkage: JsonApiResourceLinkage? = nil
        if data {
            if let children = try getter?().all() {
                var resourceIdentifierObjects = [JsonApiResourceIdentifierObject]()
                for c in children {
                    guard let id = c.id?.string ?? c.id?.int?.string else {
                        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "A fetched model does not seem to have a valid id.")
                    }
                    resourceIdentifierObjects.append(JsonApiResourceIdentifierObject(id: id, type: type.resourceType))
                }

                resourceLinkage = JsonApiResourceLinkage(resourceIdentifierObjects: resourceIdentifierObjects)
            }
        }

        return JsonApiRelationshipObject(name: name, links: links, data: resourceLinkage, meta: meta)
    }

    public func makeSiblingsRelationshipObject (
        name: String,
        type: JsonApiResourceModel.Type,
        getter: (() throws -> Siblings<JsonApiResourceModel>)? = nil,
        baseUrl: URI,
        resourcePath: String,
        meta: JsonApiMeta? = nil,
        data: Bool = false
        ) throws -> JsonApiRelationshipObject {
        let links = self.relationshipLinks(name: name, baseUrl: baseUrl, resourcePath: resourcePath)

        // TODO: Pagination
        var resourceLinkage: JsonApiResourceLinkage? = nil
        if data {
            if let siblings = try getter?().all() {
                var resourceIdentifierObjects = [JsonApiResourceIdentifierObject]()
                for s in siblings {
                    guard let id = s.id?.string ?? s.id?.int?.string else {
                        throw JsonApiInternalServerError(title: "Internal Server Error", detail: "A fetched model does not seem to have a valid id.")
                    }
                    resourceIdentifierObjects.append(JsonApiResourceIdentifierObject(id: id, type: type.resourceType))
                }

                resourceLinkage = JsonApiResourceLinkage(resourceIdentifierObjects: resourceIdentifierObjects)
            }
        }

        return JsonApiRelationshipObject(name: name, links: links, data: resourceLinkage, meta: meta)
    }
}

fileprivate extension Int {

    fileprivate var string: String {
        return String(self)
    }
}

fileprivate extension JsonApiResourceRepresentable {

    fileprivate func relationshipLinks(name: String, baseUrl: URI, resourcePath: String) -> JsonApiLinksObject {
        let selfUrl = self.relationshipSelfUrl(name: name, baseUrl: baseUrl, resourcePath: resourcePath)
        let relatedUrl = self.relationshipRelatedUrl(name: name, baseUrl: baseUrl, resourcePath: resourcePath)

        return JsonApiLinksObject(selfLink: selfUrl, relatedLink: relatedUrl)
    }

    fileprivate func relationshipSelfUrl(name: String, baseUrl: URI, resourcePath: String) -> URI {
        return URI(scheme: baseUrl.scheme, host: baseUrl.host, port: baseUrl.port, path: "\(resourcePath)/relationships/\(name)")
    }

    fileprivate func relationshipRelatedUrl(name: String, baseUrl: URI, resourcePath: String) -> URI {
        return URI(scheme: baseUrl.scheme, host: baseUrl.host, port: baseUrl.port, path: "\(resourcePath)/\(name)")
    }
}
