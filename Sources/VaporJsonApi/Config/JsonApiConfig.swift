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

    public static let mediaTypeValue: String = "application/vnd.api+json"

    public static let contentType: (key: HeaderKey, value: String) = (HeaderKey.contentType, JsonApiConfig.mediaTypeValue)

    public static var defaultHeaders: [HeaderKey: String] {
        let headers: [HeaderKey: String] = [JsonApiConfig.contentType.key: JsonApiConfig.contentType.value]
        return headers
    }

    // ******* Pagination specific *******
    public static var defaultPaginator: JsonApiPaginator = JsonApiPagedPaginator()
    public static var defaultPageSize: Int = 10
    public static var maximumPageSize: Int = 20
}
