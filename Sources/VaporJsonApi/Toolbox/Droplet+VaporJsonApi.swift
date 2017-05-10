//
//  Droplet+VaporJsonApi.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 10/05/2017.
//
//

import Vapor
import HTTP

public extension Droplet {

    public func jsonApiResource<C: JsonApiResourceController>(controller: C) {
        let resourceType = controller.resourceType.parse()
        // Get routes
        get(resourceType, handler: controller.getResources)
        get(resourceType, String.self, handler: controller.getResource)
        get(resourceType, String.self, String.self, handler: controller.getRelatedResource)

        // Post routes
        post(resourceType, handler: controller.postResource)
    }
}
