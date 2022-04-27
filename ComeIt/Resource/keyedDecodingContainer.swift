//
//  UnkeyedDecodingContainer.swift
//  ComeIt
//
//  Created by 안종표 on 2022/04/27.
//

import Foundation
extension UnkeyedDecodingContainer {
    mutating func decode<T>() throws -> T where T: Decodable {
        return try decode(T.self)
    }
    
    mutating func decodeArray<T>() throws -> [T] where T: Decodable {
        var list: [T] = []
        while !isAtEnd {
            list.append(try decode(T.self))
        }
        return list
    }
}
extension KeyedDecodingContainer {

    func decodeArray<T>(_ key: KeyedDecodingContainer.Key) throws -> [T] where T: Decodable {
        return try decode([T].self, forKey: key)
    }
}
//https://minsone.github.io/programming/swift-codable-and-exceptions-extension
