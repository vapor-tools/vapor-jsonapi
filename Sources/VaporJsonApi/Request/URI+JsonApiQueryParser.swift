//
//  URI+JsonApiQueryParser.swift
//  VaporJsonApi
//
//  Created by Koray Koska on 01/05/2017.
//
//

import HTTP
import Vapor
import URI

public extension URI {

    // TODO: Vapor 2.0 will include query dictionary parsing so this should be removed ASAP once it is released.
    // See the discussion on Github: https://github.com/vapor/vapor/issues/955
    public func jsonApiQuery() -> JSON {
        guard let query = query, var json = try? JSON(node: [:]) else {
            return JSON(Node(nilLiteral: ()))
        }

        let keyValueArray = query.components(separatedBy: "&")
        let keyValues = keyValueArray
            .map({ s in
                return s.characters.split(separator: "=", maxSplits: 1).map(String.init)
            })
            .filter({ $0.count == 2 })
            .map({ (key: $0[0], value: $0[1]) })

        for keyValue in keyValues {
            if keyValue.key.hasSuffix("[]") {
                // This value is part of an array

                let keyKey = keyValue.key.jsonApiKeySubKey()
                let topLevelKey = keyKey.topLevelKey
                let dictionaryKey = keyKey.dictionaryKey

                if let a = try? json[topLevelKey]?.makeJSON().array, var arr = a {
                    arr.append(keyValue.value)

                    let jsonArr = arr.map({ JSON(Node($0.string ?? "")) })
                    json[topLevelKey] = JSON(jsonArr)
                } else {
                    json[topLevelKey] = try? JSON([JSON(node: [dictionaryKey: keyValue.value])])
                }
            } else if keyValue.key.hasSuffix("]")
                && keyValue.key.contains("[")
                && !(Array(keyValue.key.characters).filter({ $0 == "[" }).count == 1 && keyValue.key.hasPrefix("[")) {
                // This value is part of a dictionary
                // Possible values: page[number], pa[g]e[number]. pag[e[number]
                // Impossible values: [pagenumber], page[numbe]r, page]number], page]number[

                let keyKey = keyValue.key.jsonApiKeySubKey()
                let topLevelKey = keyKey.topLevelKey
                let dictionaryKey = keyKey.dictionaryKey

                if let o = try? json[topLevelKey]?.makeJSON(), var old = o {
                    old[dictionaryKey] = JSON(Node(keyValue.value))

                    json[topLevelKey] = old
                } else {
                    json[topLevelKey] = try? JSON(node: [
                        dictionaryKey: keyValue.value
                        ])
                }
            } else {
                // This value is a simple key=value property where value will be treated as a string

                json[keyValue.key] = JSON(Node(keyValue.value))
            }
        }

        return json
    }
}

fileprivate extension String {

    func jsonApiKeySubKey() -> (topLevelKey: String, dictionaryKey: String) {
        // Generate top level key and dictionary key
        let keyArray = Array(self.characters)

        var lastOpenBracket = 0
        for i in 0 ..< keyArray.count {
            if keyArray[i] == "[" {
                lastOpenBracket = i
            }
        }

        let topLevelKey = String(keyArray[0..<lastOpenBracket])

        // We don't need the open bracket
        let startDictionaryKeyIndex = lastOpenBracket + 1
        // We don't need the last character (closed bracket)
        let endDictionaryKeyIndex = keyArray.count - 1
        let dictionaryKey = String(keyArray[startDictionaryKeyIndex..<endDictionaryKeyIndex])

        return (topLevelKey: topLevelKey, dictionaryKey: dictionaryKey)
    }
}
