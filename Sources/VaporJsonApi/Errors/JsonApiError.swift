//
//  JsonApiError.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 30/04/2017.
//
//

import Vapor
import HTTP

public class JsonApiError: ResponseRepresentable {

    public let status: Status
    public let document: JsonApiDocument

    public init(status: Status, document: JsonApiDocument) {
        self.status = status
        self.document = document
    }

    public func makeResponse() throws -> Response {
        let body = try document.makeJSON().makeBody()
        let response = Response(status: status, headers: JsonApiConfig.defaultHeaders, body: body)

        return response
    }
}
