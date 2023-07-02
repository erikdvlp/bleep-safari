//
//  ListManager.swift
//  bleep-safari
//
//  Created by erikdvlp on 2023-02-21.
//

import Foundation

public class ListManager {

    let logMgr = LogManager(senderName: String(describing: ListManager.self))

    private let publicListDatabase = [
        "665cdce9-0139-4254-afb7-14468389c499": List(
            id: "665cdce9-0139-4254-afb7-14468389c499",
            name: "Strong profanity",
            description: "The most highly offensive language.",
            values: [
                "ZnVja1soaW5nKShlcildKg==",
                "Y3VudA==",
                "bmlnZ2Vy",
                "a2lrZVxi",
                "Y2hpbmtcYg=="
            ],
            isPublic: true,
            isRegex: true,
            isEncoded: true,
            userEnabled: true

        ),
        "a5dfb9df-e586-4f03-b3ad-64510702bb60": List(
            id: "a5dfb9df-e586-4f03-b3ad-64510702bb60",
            name: "Mild profanity",
            description: "Mildly offensive language.",
            values: [
                "c2hpdA==",
                "c2hpdHR5",
                "ZmFnZ290",
                "ZmFnXGI=",
                "cHVzc3lcYg==",
                "XGJhc3NcYg==",
                "YXNzaG9sZQ==",
                "ZGljaw==",
                "Y29ja1xi",
                "Yml0Y2g=",
                "YmFzdGFyZA==",
                "ZG91Y2hl",
                "c2x1dFxi",
                "c2x1dHR5",
                "cmV0YXJk",
                "d2hvcmU="
            ],
            isPublic: true,
            isRegex: true,
            isEncoded: true,
            userEnabled: false
        )
    ]

    // Encode lists to JSON to be able to store them in memory
    func jsonEncodeLists(targetLists: [List]) -> Data? {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(targetLists) {
            return encoded
        }
        return nil
    }

    // Decode lists from JSON when taking them out of memory
    func jsonDecodeLists(targetData: Data) -> [List]? {
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([List].self, from: targetData) {
            return decoded
        }
        return nil
    }

    func getPublicListById(id: String) -> List? {
        return self.publicListDatabase[id]
    }

    func getAllPublicLists() -> [List] {
        return self.publicListDatabase.values.sorted()
    }

    func getDefaultInstalledLists() -> [List] {
        var defaultInstalledLists: [List] = []
        if let strongProfanityList = getPublicListById(id: "665cdce9-0139-4254-afb7-14468389c499") {
            defaultInstalledLists.append(strongProfanityList)
        }
        if let mildProfanityList = getPublicListById(id: "a5dfb9df-e586-4f03-b3ad-64510702bb60") {
            defaultInstalledLists.append(mildProfanityList)
        }
        return defaultInstalledLists
    }

    func getInstalledListsFromMemory() -> [List] {
        var installedLists: [List] = []
        guard let defaults = UserDefaults(suiteName: "group.bleep-safari") else {
            self.logMgr.shortCircuit(msg: "defaults")
            return installedLists
        }
        guard let installedListsEncoded = defaults.object(forKey: "installedLists") as? Data else {
            self.logMgr.shortCircuit(msg: "installedListsEncoded")
            return installedLists
        }
        if let installedListsDecoded = self.jsonDecodeLists(targetData: installedListsEncoded) {
            installedLists = installedListsDecoded.sorted()
        }
        return installedLists
    }

    func writeInstalledListsToMemory(installedLists: [List]) {
        let sortedInstalledLists = installedLists.sorted()
        guard let defaults = UserDefaults(suiteName: "group.bleep-safari") else { self.logMgr.shortCircuit(msg: "defaults"); return }
        if let installedListsEncoded = self.jsonEncodeLists(targetLists: sortedInstalledLists) {
            defaults.set(installedListsEncoded, forKey: "installedLists")
        }
    }

    func installListToMemory(targetList: List) {
        var installedLists = self.getInstalledListsFromMemory()
        installedLists.append(targetList)
        self.writeInstalledListsToMemory(installedLists: installedLists)
    }

    func uninstallListFromMemory(targetList: List) {
        let installedLists = self.getInstalledListsFromMemory().filter { $0 != targetList }
        self.writeInstalledListsToMemory(installedLists: installedLists)
    }

    func replaceListInMemory(targetList: List) {
        var installedLists = self.getInstalledListsFromMemory()
        for index in 0...installedLists.count where installedLists[index] == targetList {
            installedLists[index] = targetList
            break
        }
        self.writeInstalledListsToMemory(installedLists: installedLists)
    }

    func userEnableDisableListInMemory(targetList: List, isEnabled: Bool) {
        var installedLists = self.getInstalledListsFromMemory()
        for index in 0...installedLists.count {
            var list = installedLists[index]
            if list == targetList {
                list.userEnabled = isEnabled
                installedLists[index] = list
                break
            }
        }
        self.writeInstalledListsToMemory(installedLists: installedLists)
    }

    // Encode word to base64
    private func encodeWord(word: String) -> String {
        let utf8Word = word.data(using: .utf8)
        // swiftlint:disable:next force_unwrapping
        let encodedWord = utf8Word!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        return encodedWord
    }

    // Combine all installed and enabled lists into a flat blacklist of words
    func compileBlacklist() -> [String: [String]] {
        let installedLists = self.getInstalledListsFromMemory()
        var blacklist = [
            "plaintext": [] as [String],
            "regex": [] as [String]
        ]
        for list in installedLists where list.userEnabled {
            for value in list.values {
                let word = list.isEncoded ? value : encodeWord(word: value)
                if list.isRegex {
                    blacklist["regex"]?.append(word)
                } else {
                    blacklist["plaintext"]?.append(word)
                }
            }
        }
        return blacklist
    }

    func getNumWordsEnabled() -> Int {
        var numWordsEnabled = 0
        let installedLists = self.getInstalledListsFromMemory()
        for list in installedLists where list.userEnabled {
            numWordsEnabled += list.values.count
        }
        return numWordsEnabled
    }

}
