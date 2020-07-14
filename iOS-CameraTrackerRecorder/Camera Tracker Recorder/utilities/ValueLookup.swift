//
//  ValueLookup.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/14/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import Foundation

class CachedConfigData {
    static var dictionary: NSDictionary? = nil
}

func getConfigString(withKey key: String) -> String {
    return getConfigValue(withKey: key) as? String ?? "#####"
}

func getConfigBool(withKey key: String) -> Bool {
    return getConfigValue(withKey: key) as? Bool ?? false
}

func getConfigInt(withKey key: String) -> Int {
    return getConfigValue(withKey: key) as? Int ?? 0
}

func getConfigValue(withKey key: String) -> Any? {
    if CachedConfigData.dictionary == nil {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) {
                CachedConfigData.dictionary = dict
            }
        }
    }
    return CachedConfigData.dictionary?[key]
}
