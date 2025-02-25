//
//  Logger.swift
//  CCZU-helper
//
//  Created by rayanceking on 2/25/25.
//

import Foundation

class Logger: ObservableObject {
    private var logs: [String] = []

    func info(_ message: String) {
        let log = "INFO: \(message)"
        print(log)
        logs.append(log)
    }

    func error(_ message: Any) {
        let log = "ERROR: \(String(describing: message))"
        print(log)
        logs.append(log)
    }

    func warn(_ message: String) {
        let log = "WARN: \(message)"
        print(log)
        logs.append(log)
    }

    func getLogs() -> [String] {
        return logs
    }
}
