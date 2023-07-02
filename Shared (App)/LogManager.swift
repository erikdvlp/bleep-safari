//
//  LogManager.swift
//  bleep-safari
//
//  Created by erikdvlp on 2023-02-23.
//

import Foundation

class LogManager {
    let senderName: String

    init(senderName: String) {
        self.senderName = senderName
    }

    func debug(msg: String) {
        let logMessage = "Debug message in \(self.senderName): \(msg)"
        print(logMessage)
    }

    func error(msg: String) {
        let logMessage = "Error message in \(self.senderName): \(msg)"
        print(logMessage)
    }

    func shortCircuit(msg: String) {
        let logMessage = "Short circuit in \(self.senderName): \(msg)"
        print(logMessage)
    }
}
