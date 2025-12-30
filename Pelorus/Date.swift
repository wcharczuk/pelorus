//
//  Date.swift
//  Pelorus
//
//  Created by Will Charczuk on 10/22/16.
//  Copyright © 2016 Will Charczuk. All rights reserved.
//

import Foundation
import SQLite

extension Date {
    static var declaredDatatype: String {
        return String.declaredDatatype
    }
    static func fromDatatypeValue(stringValue: String) -> Date {
        return SQLDateFormatter.date(from:stringValue)!
    }
    var datatypeValue: String {
        return SQLDateFormatter.string(from:self)
    }
}

let SQLDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()
