//
//  RequestExtensions.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 01/05/2017.
//
//

import Vapor
import HTTP

extension Request {

    // TODO: The media type checking should be done as described in the RFC Guide for media types but for now
    // this is enough...
    func fulfillsJsonApiAcceptResponsibilities() -> Bool {
        guard let accept = self.headers.first(where: { (key, value) -> Bool in
            return key == HeaderKey.accept
        }) else {
            return false
        }

        let mediaTypes = accept.value.components(separatedBy: ",")
        let jsonApiMediaTypes = mediaTypes.filter { (string) -> Bool in
            return string.lowercased().contains(JsonApiConfig.mediaTypeValue.lowercased())
        }

        // If there is at least one media type which doesn't have media type parameters, return true...
        for m in jsonApiMediaTypes {
            if m.trim().lowercased() == JsonApiConfig.mediaTypeValue.trim().lowercased() {
                return true
            }
        }

        return false
    }

    // TODO: The media type checking should be done as described in the RFC Guide for media types but for now
    // this is enough...
    func fulfillsJsonApiContentTypeResponsibilities() -> Bool {
        guard let contentType = self.headers.first(where: { (key, value) -> Bool in
            return key == HeaderKey.contentType
        }) else {
            return false
        }

        // Content Type must be exactly application/vnd.api+json without media type parameters.
        return contentType.value.trim().lowercased() == JsonApiConfig.mediaTypeValue.trim().lowercased()
    }
}
