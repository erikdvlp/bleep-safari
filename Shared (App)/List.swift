//
//  List.swift
//  bleep-safari (iOS)
//
//  Created by erikdvlp on 2023-02-20.
//

import Foundation

public struct List: Codable {
    var id: String
    var name: String
    var description: String?
    var values: [String]
    var isPublic: Bool
    var isRegex: Bool
    var isEncoded: Bool
    var userEnabled: Bool
}
extension List: Equatable {
    public static func == (lhs: List, rhs: List) -> Bool {
        return lhs.id == rhs.id
    }
}
extension List: Comparable {
    public static func < (lhs: List, rhs: List) -> Bool {
        return lhs.name < rhs.name
    }
}
