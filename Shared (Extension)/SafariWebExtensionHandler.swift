//
//  SafariWebExtensionHandler.swift
//  Shared (Extension)
//
//  Created by erikdvlp on 2023-02-20.
//

import Foundation
import SafariServices

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    let logMgr = LogManager(senderName: String(describing: SafariWebExtensionHandler.self))

    // Handle communication with Safari scripts
    func beginRequest(with context: NSExtensionContext) {
        guard let defaults = UserDefaults(suiteName: "group.bleep-safari") else { self.logMgr.shortCircuit(msg: "defaults"); return }
        let listMgr = ListManager()
        // swiftlint:disable:next force_cast
        let item = context.inputItems[0] as! NSExtensionItem
        let message = item.userInfo?[SFExtensionMessageKey]
        let messageDictionary = message as? [String: String]
        let response = NSExtensionItem()

        // Get config from app and return to scripts
        if messageDictionary?["message"] == "getSettings" {
            let settings = [
                "blacklist": listMgr.compileBlacklist(),
                "filterStyle": defaults.integer(forKey: "filterStyle"),
                "showFirstLetter": defaults.bool(forKey: "showFirstLetter")
            ] as [String: Any]
            response.userInfo = [ SFExtensionMessageKey: settings ]
        }

        // Update number of words filtered in app memory
        else if messageDictionary?["message"] == "wordReplaced" {
            var wordsFiltered = defaults.integer(forKey: "wordsFiltered")
            wordsFiltered += 1
            defaults.set(wordsFiltered, forKey: "wordsFiltered")
            response.userInfo = [ SFExtensionMessageKey: "OK" ]
        }

        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
}
