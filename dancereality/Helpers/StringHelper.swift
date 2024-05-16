//
//  StringHelper.swift
//  dancereality
//
//  Created by Saad Khalid on 09.09.22.
//

import Foundation

public class StringHelper {
    public static func reFormatString(valueToFormat: String) -> String {
        let subString:[String] = valueToFormat.components(separatedBy: " ")
        var newString = ""
        for string in subString {
            newString = newString + string.prefix(1).lowercased() + string.dropFirst() + " "
        }
        newString = newString.trimmingCharacters(in: .whitespacesAndNewlines)
        newString = newString.replacingOccurrences(of: " ", with: "-")
        return newString
    }
}
