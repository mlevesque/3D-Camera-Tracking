//
//  JsonStringFormatting.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 8/15/19.
//  Copyright © 2019 Michael Levesque. All rights reserved.
//

import Foundation

func removeJsonWhitespace(jsonString: String) -> String {
    // we will be splitting up the json string by quotes
    // but not by escape quotes that may be in string values
    // This is why we do this complicated block of code
    var remainingString = jsonString
    
    // Our split array will start with an empty string that will be concatenated to
    // until we run into a proper quote and not an escape quote
    var splitString: [String] = [""]
    
    // loop until we split up the entire string
    while !remainingString.isEmpty {
        // if we can't find a quote in the remaining string, then add the rest to our split array
        guard let firstQuoteRangeIndex = remainingString.range(of: "\"")?.lowerBound else {
            splitString[splitString.count - 1] = "\(splitString.last!)\(remainingString)"
            remainingString = ""
            break
        }
        
        // determine if the quote we found is just a quote or if it is an escape quote
        let firstEscapeQuoteRangeIndex = remainingString.range(of: "\\\"")?.lowerBound
        let startOfNewToken = firstEscapeQuoteRangeIndex == nil
            || firstQuoteRangeIndex != remainingString.index(after: firstEscapeQuoteRangeIndex!)
        
        // concatenate the substring before and including the quote to the latest substring
        // in our split arary
        let s = "\(splitString.last!)\(remainingString[...firstQuoteRangeIndex])"
        splitString[splitString.count - 1] = s
        
        // update remaining string with the rest of the string after the quote
        let nextIndex = remainingString.index(after: firstQuoteRangeIndex)
        remainingString = String(remainingString[nextIndex...])
        
        // if we hit just a quote and not an escape quote, then we start a new token in the split array
        if startOfNewToken {
            splitString.append("")
        }
    }
    
    // Now that we have separated the strings within the json, we can remove whitespace
    // in the other parts
    for i in stride(from: 0, to: splitString.count, by: 2) {
        // remove whitespace
        var s = String(splitString[i].filter { !" \n\t\r".contains($0) })
        
        // restore spaces around colons to stay consistent with our chosen json formatting
        let colonSplit = s.split(separator: ":", maxSplits: Int(INT_MAX), omittingEmptySubsequences: false)
        s = colonSplit.joined(separator: " : ")
        
        // restore space after commas
        let commaSplit = s.split(separator: ",", maxSplits: Int(INT_MAX), omittingEmptySubsequences: false)
        splitString[i] = commaSplit.joined(separator: ", ")
    }
    
    // finally, return the new string
    return splitString.joined()
}

func addIndentsToJsonString(jsonString: String, indent: String, numberOfIndents: Int) -> String {
    return jsonString.split(separator: "\n")
        .joined(separator: "\n\(String(repeating: indent, count: numberOfIndents))")
}
