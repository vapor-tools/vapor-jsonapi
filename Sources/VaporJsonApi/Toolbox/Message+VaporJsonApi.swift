//
//  Message+VaporJsonApi.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 10/05/2017.
//
//

import Vapor
import HTTP

public extension Message {

    public var jsonApiJson: JSON? {
        get {
            if let existing = storage["jsonApiJson"] as? JSON {
                return existing
            } else if fulfillsJsonApiContentTypeResponsibilities() {
                guard case let .data(body) = body else { return nil }
                guard let jsonApiJson = try? JSON(bytes: body) else { return nil }
                storage["jsonApiJson"] = jsonApiJson
                return jsonApiJson
            } else {
                return nil
            }
        }
        set(jsonApiJson) {
            if let data = jsonApiJson {
                if let body = try? Body(data) {
                    self.body = body
                    headers[HeaderKey.contentType] = JsonApiConfig.mediaTypeValue
                }
            }
            storage["jsonApiJson"] = json
        }
    }
}
