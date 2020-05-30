//
//  SemLogger.swift
//  SemaphoreExampleTests
//
//  Created by k2terada on 2017/08/18.
//  Copyright (c) 2017 k2terada. All rights reserved.
//

import Foundation

// MARK: - Global Instanse

let semLog = SemLogger()

// MARK: - SemLogger

class SemLogger {

    init() {}

    private func formatter(message: String) -> String {

        var string: String = message

        // ----------------------
        // Date
        let timestamp: String = Date().string(dateFormat: "HH:mm:ss.SSS")

        string = "\(string) [\(timestamp)]"

        // ----------------------
        // Thread
        var threadName: String = "main"
        if !Thread.isMainThread {
            if let _threadName = Thread.current.name, !_threadName.isEmpty {
                threadName = _threadName
            } else if let _queueName = String(validatingUTF8: __dispatch_queue_get_label(nil)), !_queueName.isEmpty {
                threadName = _queueName
            } else {
                threadName = Thread.current.description
            }
        }
        string += " [\(threadName)]"

        return string
    }

    func slow(_ message: String) {
        for c in message {
            print(c, separator: "", terminator: "")
            usleep(UInt32.random(in: 10...100))
        }
        print("")
    }

    func normal(_ message: String) {
        print(message)
    }

    func format(_ message: String) {
        let formattedMessage = formatter(message: message)
        print(formattedMessage)
    }
}

extension Date {
    // Date → String
    func string(dateFormat: String) -> String {
        let formatter = DateFormatter.standard
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)

    }
}

extension DateFormatter {
    // 現在タイムゾーンの標準フォーマッタ
    static let standard: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
}
