//
//  JsonStreamWriter.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 8/13/19.
//  Copyright © 2019 Michael Levesque. All rights reserved.
//

import Foundation

fileprivate let jsonIndent = "  "

fileprivate protocol IEnclosure {
    init(currentLevel: Int)
    var level: Int { get }
    var elementCount: Int { get }
    func canStartObject() -> Bool
    func canEndObject() -> Bool
    func canStartArray() -> Bool
    func canEndArray() -> Bool
    func canAddKey(key: String) -> Bool
    func addKey(key: String)
    func canAddValue() -> Bool
    func addToCount()
    func canAutoClose() -> Bool
    func getStartString() -> String
    func getValuePrefix(useNewLine: Bool?) -> String
    func getEndString(useNewLine: Bool?) -> String
    func getKeyString(key: String) -> String
}

fileprivate class ObjectEnclosure: IEnclosure {
    fileprivate let m_level: Int
    fileprivate var m_count: Int
    fileprivate var m_keys: Set<String>
    
    required init(currentLevel: Int) {
        m_level = currentLevel + 1
        m_count = 0
        m_keys = Set<String>()
    }
    
    var level: Int { get {return m_level} }
    var elementCount: Int { get {return m_count} }
    
    func canStartObject() -> Bool {return false}
    func canEndObject() -> Bool {return true}
    func canStartArray() -> Bool {return false}
    func canEndArray() -> Bool {return false}
    func canAddKey(key: String) -> Bool {
        // key must be valid
        guard key.range(of:"^[a-zA-Z_][a-zA-Z_0-9]*$", options: .regularExpression) != nil else {
            return false
        }
        // key must be unique
        guard !m_keys.contains(key) else {
            return false
        }
        return true
    }
    func addKey(key: String) {m_keys.insert(key)}
    func canAddValue() -> Bool {return false}
    func addToCount() {m_count += 1}
    func canAutoClose() -> Bool {return false}
    func getStartString() -> String {return "{"}
    func getValuePrefix(useNewLine: Bool?) -> String {
        let shouldAddComma = elementCount > 0
        let comma = shouldAddComma ? "," : ""
        let newLine = useNewLine ?? true
            ? "\n\(String(repeating: jsonIndent, count: level + 1))"
            : shouldAddComma ? " " : ""
        return "\(comma)\(newLine)"
    }
    func getEndString(useNewLine: Bool?) -> String {
        let prefix = useNewLine ?? (m_count > 0)
            ? "\n\(String(repeating: jsonIndent, count: level))"
            : ""
        return "\(prefix)}"
    }
    func getKeyString(key: String) -> String {return ""}
}

fileprivate class TopLevelEnclosure: ObjectEnclosure {
    override var level: Int { get {return 0} }
    override func canEndObject() -> Bool {return false}
}

fileprivate class ArrayEnclosure: IEnclosure {
    fileprivate let m_level: Int
    fileprivate var m_count: Int
    
    required init(currentLevel: Int) {
        m_level = currentLevel + 1
        m_count = 0
    }
    
    var level: Int { get {return m_level} }
    var elementCount: Int { get {return m_count} }
    
    func canStartObject() -> Bool {return true}
    func canEndObject() -> Bool {return false}
    func canStartArray() -> Bool {return true}
    func canEndArray() -> Bool {return true}
    func canAddKey(key: String) -> Bool {return false}
    func addKey(key: String) {}
    func canAddValue() -> Bool {return true}
    func addToCount() {m_count += 1}
    func canAutoClose() -> Bool {return false}
    func getStartString() -> String {return "["}
    func getValuePrefix(useNewLine: Bool?) -> String {
        let shouldAddComma = elementCount > 0
        let comma = shouldAddComma ? "," : ""
        let newLine = useNewLine ?? true
            ? "\n\(String(repeating: jsonIndent, count: level + 1))"
            : shouldAddComma ? " " : ""
        return "\(comma)\(newLine)"
    }
    func getEndString(useNewLine: Bool?) -> String {
        let prefix = useNewLine ?? (m_count > 0)
            ? "\n\(String(repeating: jsonIndent, count: level))"
            : ""
        return "\(prefix)]"
    }
    func getKeyString(key: String) -> String {return ""}
}

fileprivate class KeyEnclosure: IEnclosure {
    fileprivate let m_level: Int
    
    required init(currentLevel: Int) {
        m_level = currentLevel
    }
    
    var elementCount: Int { get {return 0} }
    var level: Int { get {return m_level} }
    
    func canStartObject() -> Bool {return true}
    func canEndObject() -> Bool {return false}
    func canStartArray() -> Bool {return true}
    func canEndArray() -> Bool {return false}
    func canAddKey(key: String) -> Bool {return false}
    func addKey(key: String) {}
    func canAddValue() -> Bool {return true}
    func addToCount() {}
    func canAutoClose() -> Bool {return true}
    func getStartString() -> String {return ""}
    func getValuePrefix(useNewLine: Bool?) -> String {
        let newLine = useNewLine ?? false
            ? "\n\(String(repeating: jsonIndent, count: level + 1))"
            : " "
        return "\(newLine)"
    }
    func getEndString(useNewLine: Bool?) -> String {
        if let nl = useNewLine, nl {
            let tabs = String(repeating: jsonIndent, count: level)
            return "\n\(tabs){\n\(tabs)}"
        }
        else {
            return " {}"
        }
    }
    func getKeyString(key: String) -> String {return "\"\(key)\" :"}
}

enum JsonStreamWriterError: Error {
    case InitError(String)
}

class JsonStreamWriter {
    private let m_fileHandle: FileHandle
    private var m_enclosureStack: [IEnclosure]
    private var m_level: Int
    
    init(url: URL) throws {
        do {
            try m_fileHandle = FileHandle(forWritingTo: url)
        }
        catch {
            throw JsonStreamWriterError.InitError("Can't initialize File Handle")
        }
        m_enclosureStack = []
        m_level = 0
        
        // start with open bracket
        startTopLevel()
    }
    
    deinit {
        closeFile()
    }
    
    func startObject(newLine: Bool? = nil) -> Bool {
        guard m_enclosureStack.last?.canStartObject() == true else {
            return false
        }
        startEnclosure(ObjectEnclosure(currentLevel: m_enclosureStack.last!.level), newLine: newLine)
        return true
    }
    
    func endObject(newLine: Bool? = nil) -> Bool {
        guard m_enclosureStack.last?.canEndObject() == true else {
            return false
        }
        endEnclosure(newLine: newLine)
        return true
    }
    
    func startArray(newLine: Bool? = nil) -> Bool {
        guard m_enclosureStack.last?.canStartArray() == true else {
            return false
        }
        startEnclosure(ArrayEnclosure(currentLevel: m_enclosureStack.last!.level), newLine: newLine)
        return true
    }
    
    func endArray(newLine: Bool? = nil) -> Bool {
        guard m_enclosureStack.last?.canEndArray() == true else {
            return false
        }
        endEnclosure(newLine: newLine)
        return true
    }
    
    func addKey(_ key: String, newLine: Bool? = nil) -> Bool {
        guard m_enclosureStack.last?.canAddKey(key: key) == true else {
            return false
        }
        
        // create enclosure
        let enclosure = KeyEnclosure(currentLevel: m_enclosureStack.last!.level)
        
        // write
        let prefix = m_enclosureStack.last!.getValuePrefix(useNewLine: newLine)
        let keyEntry = enclosure.getKeyString(key: key)
        m_fileHandle.write("\(prefix)\(keyEntry)".data(using: .utf8)!)
        
        // add key to set
        m_enclosureStack.last!.addKey(key: key)
        
        // add to stack
        m_enclosureStack.append(enclosure)
        return true
    }
    
    func addNullValue(newLine: Bool? = nil) -> Bool {
        return addValueInternal("null", newLine: newLine)
    }
    
    func addValue(_ value: Int, newLine: Bool? = nil) -> Bool {
        return addValueInternal("\(value)", newLine: newLine)
    }
    
    func addValue(_ value: Float, newLine: Bool? = nil) -> Bool {
        return addValueInternal("\(value)", newLine: newLine)
    }
    
    func addValue(_ value: Double, newLine: Bool? = nil) -> Bool {
        return addValueInternal("\(value)", newLine: newLine)
    }
    
    func addValue(_ value: Bool, newLine: Bool? = nil) -> Bool {
        return addValueInternal("\(value)", newLine: newLine)
    }
    
    func addValue(_ value: String, newLine: Bool? = nil) -> Bool {
        return addValueInternal("\"\(value)\"", newLine: newLine)
    }
    
    func addValue<T>(_ value: T, newLineEntry: Bool? = nil, newLinesInParsedObject: Bool? = nil) -> Bool where T:Encodable {
        var resultString: String
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(value)
            resultString = reformatEncodedValue(
                String(data: data, encoding: .utf8)!,
                newLine: newLinesInParsedObject
            )
        }
        catch {
            return false
        }
        
        return addValueInternal(resultString, newLine: newLineEntry)
    }
    
    func closeFile(newLine: Bool? = nil) {
        // close out levels
        while !m_enclosureStack.isEmpty {
            if let endStringData = m_enclosureStack.last?.getEndString(useNewLine: newLine).data(using: .utf8) {
                m_fileHandle.write(endStringData)
            }
            popEnclosureStack()
            m_enclosureStack.last?.addToCount()
        }
        m_fileHandle.closeFile()
    }
    
    
    private func startTopLevel() {
        let enclosure = TopLevelEnclosure(currentLevel: 0)
        m_fileHandle.write(enclosure.getStartString().data(using: .utf8)!)
        m_enclosureStack.append(enclosure)
    }
    
    private func startEnclosure(_ enclosure: IEnclosure, newLine: Bool?) {
        // write
        let prefix = m_enclosureStack.last!.getValuePrefix(useNewLine: newLine)
        m_fileHandle.write("\(prefix)\(enclosure.getStartString())".data(using: .utf8)!)
        
        // add to stack
        m_enclosureStack.append(enclosure)
    }
    
    private func endEnclosure(newLine: Bool?) {
        // write
        let s = m_enclosureStack.last!.getEndString(useNewLine: newLine)
        m_fileHandle.write(s.data(using: .utf8)!)
        
        // pop stack
        popEnclosureStack()
        
        // add to count of the now current enclosure since closing
        // the previous enclosure counts as a completed element for this
        // enclosure
        m_enclosureStack.last?.addToCount()
    }
    
    private func reformatEncodedValue(_ value: String, newLine: Bool?) -> String {
        // if we want new lines, then we need to insert the correct amount of indentations
        if newLine == nil || newLine! == true {
            // separate by new lines
            return addIndentsToJsonString(
                jsonString: value,
                indent: jsonIndent,
                numberOfIndents: (m_enclosureStack.last?.level ?? 0) + 1
            )
        }
        else {
            return removeJsonWhitespace(jsonString: value)
        }
    }
    
    private func addValueInternal(_ value: String, newLine: Bool?) -> Bool {
        guard m_enclosureStack.last?.canAddValue() == true else {
            return false
        }
        
        // write
        let prefix = m_enclosureStack.last!.getValuePrefix(useNewLine: newLine)
        m_fileHandle.write("\(prefix)\(value)".data(using: .utf8)!)
        
        // close out key enclosure if we are in one
        if m_enclosureStack.last!.canAutoClose() {
            popEnclosureStack()
        }
        
        // add to count
        m_enclosureStack.last?.addToCount()
        return true
    }
    
    private func popEnclosureStack() {
        // pop from stack
        _ = m_enclosureStack.popLast()
        
        // check if new current enclosure should be auto closed
        if m_enclosureStack.last?.canAutoClose() == true {
            popEnclosureStack()
        }
    }
}
