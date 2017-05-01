//
//  JsonApiErrorObject.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 01/05/2017.
//
//

import Foundation
import Vapor

public class JsonApiErrorObject: JSONRepresentable {

    public let links: JsonApiErrorLinks?
    public let status: String?
    public let code: String?
    public let title: String?
    public let detail: String?
    public let source: JsonApiErrorSource?
    public let meta: JsonApiMeta?

    public init(id: String? = nil,
                links: JsonApiErrorLinks? = nil,
                status: String? = nil,
                code: String? = nil,
                title: String? = nil,
                detail: String? = nil,
                source: JsonApiErrorSource? = nil,
                meta: JsonApiMeta? = nil) {
        self.links = links
        self.status = status
        self.code = code
        self.title = title
        self.detail = detail
        self.source = source
        self.meta = meta
    }

    public func makeJSON() throws -> JSON {
        var json = try JSON(node: [:])

        if let links = links {
            json["links"] = try links.makeJSON()
        }
        if let status = status {
            json["status"] = try JSON(node: status)
        }
        if let code = code {
            json["code"] = try JSON(node: code)
        }
        if let title = title {
            json["title"] = try JSON(node: title)
        }
        if let detail = detail {
            json["detail"] = try JSON(node: detail)
        }
        if let source = source {
            json["source"] = try source.makeJSON()
        }
        if let meta = meta {
            json["meta"] = try meta.makeJSON()
        }

        return json
    }
}

public class JsonApiErrorLinks: JSONRepresentable {

    public let about: URL

    public init(about: URL) {
        self.about = about
    }

    public func makeJSON() throws -> JSON {
        return try JSON(node: [
            "about": about.absoluteString
            ])
    }
}

public class JsonApiErrorSource: JSONRepresentable {

    public let pointer: String?
    public let parameter: String?

    init(pointer: String? = nil, parameter: String? = nil) {
        self.pointer = pointer
        self.parameter = parameter
    }

    public func makeJSON() throws -> JSON {
        var json = try JSON(node: [:])

        if let pointer = pointer {
            json["pointer"] = try JSON(node: pointer)
        }
        if let parameter = parameter {
            json["parameter"] = try JSON(node: parameter)
        }

        return json
    }
}
