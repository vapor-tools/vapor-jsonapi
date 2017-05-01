//
//  JsonApiResponse.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 01/05/2017.
//
//

import Vapor
import HTTP

public class JsonApiResponse: ResponseRepresentable {

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
