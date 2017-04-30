//
//  JsonApiConfig.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 30/04/2017.
//
//

import Vapor
import HTTP

public struct JsonApiConfig {

    public static let contentTypeValue: String = "application/vnd.api+json"
    public static let contentType: (key: HeaderKey, value: String) = (HeaderKey.contentType, JsonApiConfig.contentTypeValue)

    public static var defaultHeaders: [HeaderKey: String] {
        let headers: [HeaderKey: String] = [JsonApiConfig.contentType.key: JsonApiConfig.contentType.value]
        return headers
    }
}
