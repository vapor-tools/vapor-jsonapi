//
//  Droplet+VaporJsonApi.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 10/05/2017.
//
//

import Vapor
import HTTP

public extension RouteBuilder {

    public func jsonApiResource<C: JsonApiResourceController>(controller: C) {
        let resourceType = controller.resourceType.parse()
        // Get routes
        group(resourceType) { resourceType in
            resourceType.get(handler: controller.getResources)
            resourceType.get(String.parameter, handler: controller.getResource)
            resourceType.get(String.parameter, String.parameter, handler: controller.getRelatedResource)
            resourceType.get(String.parameter, "relationships", String.parameter, handler: controller.getRelationships)
        }

        // Post routes
        post(resourceType, handler: controller.postResource)

        // Patch routes
        patch(resourceType, String.parameter, handler: controller.patchResource)
    }
}
