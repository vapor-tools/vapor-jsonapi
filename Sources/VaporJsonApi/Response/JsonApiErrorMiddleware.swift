//
//  JsonApiErrorMiddleware.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 01/05/2017.
//
//

import Vapor
import HTTP

public final class JsonApiErrorMiddleware: Middleware {

    public init() {}

    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            return try next.respond(to: request)
        } catch let e as JsonApiError {
            let error = JsonApiErrorObject(status: String(e.status.statusCode), code: e.code, title: e.title, detail: e.detail)
            let document = JsonApiDocument(errors: [error])
            let response = JsonApiResponse(status: e.status, document: document)

            return try response.makeResponse()
        }
    }
}
