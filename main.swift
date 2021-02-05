//
//  main.swift
//  Strings Checker
//
//  Created by Jonathan Downing on 2/4/21.
//

import Foundation

guard let enumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: FileManager.default.currentDirectoryPath), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants], errorHandler: nil) else {
    fatalError("Could not create enumerator")
}

var missingStrings: [String: [String]] = [:]

for case let url as URL in enumerator where try url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true {
    if url.pathExtension == "strings" {
        let emptyStrings = try parseEmptyStringsFile(at: url)
        if !emptyStrings.isEmpty {
            missingStrings[url.pathComponents[max(0, url.pathComponents.count - 2)], default: []].append(contentsOf: emptyStrings)
        }
    }
    if url.pathExtension == "stringsdict" {
        let emptyStrings = try parseEmptyStringsDictFile(at: url)
        if !emptyStrings.isEmpty {
            missingStrings[url.pathComponents[max(0, url.pathComponents.count - 2)], default: []].append(contentsOf: emptyStrings)
        }
    }
}

if !missingStrings.isEmpty {
    print(missingStrings)
    exit(1)
}

func parseEmptyStringsFile(at url: URL) throws -> [String] {
    let strings = try String(contentsOf: url).components(separatedBy: .newlines)
    let keyValues = strings.compactMap { string -> String? in
        var string = string
        guard string.popLast() == ";" else { return nil }
        let components = string.components(separatedBy: "=").map { $0.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "") }
        guard components.count == 2 else { return nil }
        guard !components[0].isEmpty else { return nil }
        guard components[1].isEmpty else { return nil }
        return components[0]
    }
    return keyValues
}

func parseEmptyStringsDictFile(at url: URL) throws -> [String] {
    struct StringsDictionaryValue: Decodable {
        struct Format: Decodable {
            var NSStringFormatSpecTypeKey: String
            var one: String?
            var two: String?
            var other: String?
            var many: String?
            var few: String?
        }
        var NSStringLocalizedFormatKey: String
        var format: Format
    }
    let decoder = PropertyListDecoder()
    let stringsDictionary = try decoder.decode([String: StringsDictionaryValue].self, from: Data(contentsOf: url)).filter { _, dictionary in dictionary.format.NSStringFormatSpecTypeKey == "NSStringPluralRuleType" }
    return stringsDictionary.compactMap { key, dictionary -> String? in
        guard
            dictionary.format.one?.isEmpty != true,
            dictionary.format.two?.isEmpty != true,
            dictionary.format.other?.isEmpty != true,
            dictionary.format.many?.isEmpty != true,
            dictionary.format.few?.isEmpty != true
        else {
            return key
        }
        return nil
    }
}
