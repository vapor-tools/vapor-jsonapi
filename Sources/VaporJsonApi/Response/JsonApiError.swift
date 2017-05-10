//
//  JsonApiError.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 01/05/2017.
//
//

import Vapor
import HTTP

public protocol JsonApiError: Error {

    var status: Status { get }
    var code: String { get }
    var title: String { get }
    var detail: String { get }
}

public class JsonApiGeneralError: JsonApiError {

    public let status: Status
    public let code: String
    public let title: String
    public let detail: String

    public init(status: Status, code: String, title: String, detail: String) {
        self.status = status
        self.code = code
        self.title = title
        self.detail = detail
    }
}

public class JsonApiInternalServerError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.internalServerError, code: String(Status.internalServerError.statusCode), title: title, detail: detail)
    }

    public convenience init() {
        self.init(title: "Internal Server Error", detail: "Internal Server Error")
    }
}

public class JsonApiInvalidResourceError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(resource: String) {
        self.init(title: "Invalid resource", detail: "\(resource) is not a valid resource.")
    }
}

public class JsonApiRecordNotFoundError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.notFound, code: String(Status.notFound.statusCode), title: title, detail: detail)
    }

    public convenience init(id: String) {
        self.init(title: "Record not found", detail: "The record identified by \(id) could not be found.")
    }
}

public class JsonApiRelationshipNotFoundError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.notFound, code: String(Status.notFound.statusCode), title: title, detail: detail)
    }

    public convenience init(relationship: String) {
        self.init(title: "Relationship not found", detail: "The relationship identified by \(relationship) could not be found.")
    }
}

public class JsonApiUnsupportedMediaTypeError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.unsupportedMediaType, code: String(Status.unsupportedMediaType.statusCode), title: title, detail: detail)
    }

    public convenience init(mediaType: String) {
        let detailMessage = "All requests that create or update must use the '\(JsonApiConfig.mediaTypeValue)' Content-Type. This request specified '\(mediaType)'."
        self.init(title: "Unsupported media type", detail: detailMessage)
    }
}

public class JsonApiNotAcceptableError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.notAcceptable, code: String(Status.notAcceptable.statusCode), title: title, detail: detail)
    }

    public convenience init(mediaType: String) {
        let detailMessage = "All requests must use the '\(JsonApiConfig.mediaTypeValue)' Accept without media type parameters. This request specified '\(mediaType)'."
        self.init(title: "Not acceptable", detail: detailMessage)
    }
}

public class JsonApiHasManyRelationExistsError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(id: String) {
        self.init(title: "Relation exists", detail: "The relation to \(id) already exists.")
    }
}

public class JsonApiBadRequestError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(exception: String) {
        self.init(title: "Bad Request", detail: exception)
    }
}

public class JsonApiInvalidRequestFormatError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init() {
        self.init(title: "Bad Request", detail: "Request must be a hash")
    }
}

public class JsonApiToManySetReplacementForbiddenError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.forbidden, code: String(Status.forbidden.statusCode), title: title, detail: detail)
    }

    public convenience init() {
        self.init(title: "Complete replacement forbidden", detail: "Complete replacement forbidden for this relationship")
    }
}

public class JsonApiInvalidFiltersSyntaxError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(filters: String) {
        self.init(title: "Invalid filters syntax", detail: "\(filters) is not a valid syntax for filtering.")
    }
}

public class JsonApiFilterNotAllowedError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(filter: String) {
        self.init(title: "Filter not allowed", detail: "\(filter) is not allowed.")
    }
}

public class JsonApiInvalidFilterValueError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(filter: String, value: String) {
        self.init(title: "Invalid filter value", detail: "\(value) is not a valid value for \(filter).")
    }
}

public class JsonApiInvalidFieldValueError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(filter: String, value: String) {
        self.init(title: "Invalid field value", detail: "\(value) is not a valid value for \(filter).")
    }
}

public class JsonApiInvalidFieldFormatError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init() {
        self.init(title: "Invalid field format", detail: "Fields must specify a type.")
    }
}

public class JsonApiInvalidDataFormatError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init() {
        self.init(title: "Invalid data format", detail: "Data must be a hash.")
    }
}

public class JsonApiInvalidLinksObjectError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init() {
        self.init(title: "Invalid Links Object", detail: "Data is not a valid Links Object.")
    }
}

public class JsonApiTypeMismatchError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(type: String) {
        self.init(title: "Type Mismatch", detail: "\(type) is not a valid type for this operation.")
    }
}

public class JsonApiInvalidFieldError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(type: String, field: String) {
        self.init(title: "Invalid field", detail: "\(field) is not a valid field for \(type).")
    }
}

public class JsonApiInvalidIncludeError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(resource: String, relationship: String) {
        self.init(title: "Invalid field", detail: "\(relationship) is not a valid relationship of \(resource).")
    }
}

public class JsonApiInvalidSortCriteriaError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(resource: String, sortCriteria: String) {
        self.init(title: "Invalid sort criteria", detail: "\(sortCriteria) is not a valid sort criteria for \(resource).")
    }
}

public class JsonApiParameterNotAllowedError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(parameter: String) {
        self.init(title: "Param not allowed", detail: "\(parameter) is not allowed.")
    }
}

public class JsonApiRelationshipNotAllowedError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(relationship: String) {
        self.init(title: "Relationship not allowed", detail: "\(relationship) is not allowed.")
    }
}

public class JsonApiParameterMissingError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(parameter: String) {
        self.init(title: "Missing Parameter", detail: "The required parameter, \(parameter), is missing.")
    }
}

public class JsonApiKeyNotIncludedInURLError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(key: String) {
        self.init(title: "Key is not included in URL", detail: "The URL does not support the key \(key).")
    }
}

public class JsonApiMissingKeyError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init() {
        self.init(title: "A key is required", detail: "The resource object does not contain a key.")
    }
}

public class JsonApiRecordLockedError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.locked, code: String(Status.locked.statusCode), title: title, detail: detail)
    }

    public convenience init(message: String) {
        self.init(title: "Locked resource", detail: message)
    }
}

public class JsonApiSaveFailedError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.unprocessableEntity, code: String(Status.unprocessableEntity.statusCode), title: title, detail: detail)
    }

    public convenience init() {
        self.init(title: "Save failed or was cancelled", detail: "Save failed or was cancelled")
    }
}

public class JsonApiInvalidPageObjectError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init() {
        self.init(title: "Invalid Page Object", detail: "Invalid Page Object.")
    }
}

public class JsonApiPageParameterNotAllowedError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(parameter: String) {
        self.init(title: "Page parameter not allowed", detail: "\(parameter) is not an allowed page parameter.")
    }
}

public class JsonApiInvalidPageValueError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.badRequest, code: String(Status.badRequest.statusCode), title: title, detail: detail)
    }

    public convenience init(page: String, value: String) {
        self.init(title: "Invalid page value", detail: "\(value) is not a valid value for \(page) page parameter.")
    }
}

public class JsonApiTypeConflictError: JsonApiGeneralError {

    public init(title: String, detail: String) {
        super.init(status: Status.conflict, code: String(Status.conflict.statusCode), title: title, detail: detail)
    }

    public convenience init(type: String) {
        self.init(title: "Invalid type value", detail: "\(type) is not a valid type value.")
    }
}
