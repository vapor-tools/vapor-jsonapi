//
//  JsonApiPaginator.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 01/05/2017.
//
//

public protocol JsonApiPaginator {
    var pageCount: Int { get }
    var pageOffset: Int { get }
}

public class JsonApiPagedPaginator: JsonApiPaginator {

    public var pageCount: Int
    public var pageOffset: Int

    public init(pageCount: Int, pageSize: Int) {
        self.pageCount = pageCount
        self.pageOffset = (pageSize * pageCount) - pageCount
    }
}
