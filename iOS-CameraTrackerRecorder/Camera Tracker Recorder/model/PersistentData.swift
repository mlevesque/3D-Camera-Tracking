//
//  PersistentData.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 7/14/20.
//  Copyright © 2020 Michael Levesque. All rights reserved.
//

import Foundation

/// Add data that will persist in the app
class PersistentData : NSObject, NSCoding {
    struct PropertyKey {
        static let settings = "settings"
        static let nameData = "nameData"
    }
    
    var settings: SettingsData
    var nameData: NameData
    
    func encode(with coder: NSCoder) {
        coder.encode(settings, forKey: PropertyKey.settings)
        coder.encode(nameData, forKey: PropertyKey.nameData)
    }
    
    override convenience init() {
        self.init(settings: nil, nameData: nil)
    }
    
    init(settings: SettingsData?, nameData: NameData?) {
        self.settings = settings ?? SettingsData(useAudio: nil)
        self.nameData = nameData ?? NameData(projectName: nil, scene: nil, take: nil)
    }
    
    required convenience init?(coder: NSCoder) {
        self.init(
            settings: coder.decodeObject(forKey: PropertyKey.settings) as? SettingsData,
            nameData: coder.decodeObject(forKey: PropertyKey.nameData) as? NameData
        )
    }
}

/// Settings values.
class SettingsData : NSObject, NSCoding  {
    struct PropertyKey {
        static let useAudio = "useAudio"
    }
    
    var useAudio: Bool
    
    func encode(with coder: NSCoder) {
        coder.encode(useAudio, forKey: PropertyKey.useAudio)
    }
    
    init(useAudio: Bool?) {
        self.useAudio = useAudio ?? getConfigBool(withKey: "defaultUseAudio")
    }
    
    required convenience init(coder: NSCoder) {
        self.init(useAudio: coder.decodeBool(forKey: PropertyKey.useAudio))
    }
}

/// Recording name values.
class NameData : NSObject, NSCoding  {
    struct PropertyKey {
        static let projectName = "projectName"
        static let scene = "scene"
        static let take = "take"
    }
    
    var projectName: String
    var scene: String
    var take: Int
    
    func encode(with coder: NSCoder) {
        coder.encode(projectName, forKey: PropertyKey.projectName)
        coder.encode(scene, forKey: PropertyKey.scene)
        coder.encode(take, forKey: PropertyKey.take)
    }
    
    init(projectName: String?, scene: String?, take: Int?) {
        self.projectName = projectName ?? getConfigString(withKey: "defaultProjectName")
        self.scene = scene ?? getConfigString(withKey: "defaultScene")
        self.take = take ?? getConfigInt(withKey: "defaultTake")
    }
    
    required convenience init?(coder: NSCoder) {
        guard let projectName = coder.decodeObject(forKey: PropertyKey.projectName) as? String,
              let scene = coder.decodeObject(forKey: PropertyKey.scene) as? String,
              let take = coder.decodeObject(forKey: PropertyKey.take) as? Int else {
            return nil
        }
        self.init(projectName: projectName, scene: scene, take: take)
    }
}
