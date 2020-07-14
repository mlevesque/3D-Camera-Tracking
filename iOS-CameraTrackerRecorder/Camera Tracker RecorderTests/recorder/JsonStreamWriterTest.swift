//
//  JsonStreamWriterTest.swift
//  Camera Tracker RecorderTests
//
//  Created by Michael Levesque on 8/13/19.
//  Copyright © 2019 Michael Levesque. All rights reserved.
//

import XCTest
@testable import Cam_Track_Rec

class JsonStreamWriterTest: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func temporaryFileURL() -> URL {
        // Create a URL for an unique file in the system's temporary directory.
        let directory = NSTemporaryDirectory()
        let filename = UUID().uuidString
        let fileURL = URL(fileURLWithPath: directory).appendingPathComponent(filename)
        
        // Add a teardown block to delete any file at `fileURL`.
        addTeardownBlock {
            do {
                let fileManager = FileManager.default
                // Check that the file exists before trying to delete it.
                if fileManager.fileExists(atPath: fileURL.path) {
                    // Perform the deletion.
                    try fileManager.removeItem(at: fileURL)
                    // Verify that the file no longer exists after the deletion.
                    XCTAssertFalse(fileManager.fileExists(atPath: fileURL.path))
                }
            } catch {
                // Treat any errors during file deletion as a test failure.
                XCTFail("Error while deleting temporary file: \(error)")
            }
        }
        
        // Return the temporary file URL for use in a test method.
        return fileURL
        
    }
    
    func performJsonTestFromData<T>(_ data: TestJsonData<T>) where T:Encodable {
        let url = temporaryFileURL()
        FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        
        do {
            let writer = try JsonStreamWriter(url: url)
            for action in data.actions {
                var result: Bool? = nil
                switch action.action {
                case .StartObject:
                    result = writer.startObject(newLine: action.newLine)
                case .EndObject:
                    result = writer.endObject(newLine: action.newLine)
                case .StartArray:
                    result = writer.startArray(newLine: action.newLine)
                case .EndArray:
                    result = writer.endArray(newLine: action.newLine)
                case .AddKey:
                    result = writer.addKey(action.value as! String, newLine: action.newLine)
                case .CloseFile:
                    writer.closeFile(newLine: action.newLine)
                case .AddNullValue:
                    result = writer.addNullValue(newLine: action.newLine)
                case .AddValue:
                    if action.value is String {
                        result = writer.addValue(
                            action.value as! String,
                            newLine: action.newLine
                        )
                    }
                    else if action.value is Bool {
                        result = writer.addValue(
                            action.value as! Bool,
                            newLine: action.newLine
                        )
                    }
                    else if action.value is Double {
                        result = writer.addValue(
                            action.value as! Double,
                            newLine: action.newLine
                        )
                    }
                    else if action.value is Float {
                        result = writer.addValue(
                            action.value as! Float,
                            newLine: action.newLine
                        )
                    }
                    else if action.value is Int {
                        result = writer.addValue(
                            action.value as! Int,
                            newLine: action.newLine
                        )
                    }
                    else if action.encodeValue != nil {
                        result = writer.addValue(
                            action.encodeValue,
                            newLineEntry: action.newLine,
                            newLinesInParsedObject: data.encodableNewLine
                        )
                    }
                }
                if let r = result {
                    XCTAssertEqual(r, !action.shouldFail)
                }
            }
            writer.closeFile()
        }
        catch let error {
            XCTFail("Initializing the Json Stream Writer failed: \(error)")
        }
    
        if let result = data.result {
            validateJson(url: url, compareTo: result)
        }
    }
    
    func validateJson(url: URL, compareTo: String?) {
        do {
            // read file
            let fileHandle = try FileHandle(forReadingFrom: url)
            let data = fileHandle.readDataToEndOfFile()
            
            // validate json
            let jsonObject = try JSONSerialization.jsonObject(
                with: data,
                options: JSONSerialization.ReadingOptions.mutableContainers)
            XCTAssertTrue(JSONSerialization.isValidJSONObject(jsonObject))
            
            // perform comparison test
            if let cmpTo = compareTo {
                let dataString = String(data: data, encoding: .utf8)!
                XCTAssertEqual(dataString, cmpTo)
            }
        }
        catch let error{
            XCTFail("Failed with error: \(error)")
        }
    }
    
    func testEmptyJson() {
        performJsonTestFromData(testJsonEmpty)
    }
    
    func testSingleLevelKeyValueNewLineJson() {
        performJsonTestFromData(testJsonSingleLevelKeyValueNewLine)
    }
    
    func testSingleLevelKeyValueNoNewLineJson() {
        performJsonTestFromData(testJsonSingleLevelKeyValueNoNewLine)
    }
    
    func testSingleLayerArrayNewLinesJson() {
        performJsonTestFromData(testJsonSingleLevelArrayNewLine)
    }
    
    func testSingleLayerArrayNoNewLinesJson() {
        performJsonTestFromData(testJsonSingleLevelArrayNoNewLine)
    }
    
    func testTwoLevelMixed1Json() {
        performJsonTestFromData(testJsonTwoLevelMixed1)
    }
    
    func testTwoLevelMixed2Json() {
        performJsonTestFromData(testJsonTwoLevelMixed2)
    }
    
    func testAutoCompleteObjectJson() {
        performJsonTestFromData(testJsonAutoCompleteObject)
    }
    
    func testAutoCompleteArrayJson() {
        performJsonTestFromData(testJsonAutoCompleteArray)
    }
    
    func testAutoCompleteKeyJson() {
        performJsonTestFromData(testJsonAutoCompleteKey)
    }
    
    func testEncodableNewLineJson() {
        performJsonTestFromData(testJsonEncodableNewLine)
    }
    
    func testEncodableNoNewLineJson() {
        performJsonTestFromData(testJsonEncodableNoNewLine)
    }
    
    func testEncodableNoNewLineEncodableOnlyJson() {
        performJsonTestFromData(testJsonEncodableNoNewLineEncodableOnly)
    }
    
    func testEncodableNoNewLineEncodableOnlyWithSpacesInStringsJson() {
        performJsonTestFromData(testJsonEncodableNoNewLineEncodableOnlyWithSpacesInStrings)
    }
    
    func testEncodableNoNewLineEncodableOnlyWithQuotesInStringsJson() {
        performJsonTestFromData(testJsonEncodableNoNewLineEncodableOnlyWithQuotesInStrings)
    }
    
    func testNullValueJson() {
        performJsonTestFromData(testJsonNullValue)
    }
    
    func testFailAddValueToObjectJson() {
        performJsonTestFromData(testJsonFailAddValueOnObject)
    }
    
    func testFailAddDoubleKeysJson() {
        performJsonTestFromData(testJsonFailAddDoubleKeys)
    }
    
    func testFailEndObjectInKeyJson() {
        performJsonTestFromData(testJsonFailEndObjectInKey)
    }
    
    func testFailAddDuplicateKeyJson() {
        performJsonTestFromData(testJsonFailAddDuplicateKey)
    }
    
    func testFailEndArrayOnObjectJson() {
        performJsonTestFromData(testJsonFailEndArrayOnObject)
    }
    
    func testFailEndObjectOnArrayJson() {
        performJsonTestFromData(testJsonFailEndObjectOnArray)
    }
    
    func testFailStartArrayOnTopLevelJson() {
        performJsonTestFromData(testJsonFailStartArrayOnTopLevel)
    }
    
    func testFailStartObjectOnTopLevelJson() {
        performJsonTestFromData(testJsonFailStartObjectOnTopLevel)
    }
    
    func testFailEndObjectTooManyTimesJson() {
        performJsonTestFromData(testJsonFailEndObjectTooManyTimes)
    }
    
    func testFailStartObjectAfterClosingFileJson() {
        performJsonTestFromData(testJsonFailStartObjectAfterClosingFile)
    }
    
    func testFailStartArrayAfterClosingFileJson() {
        performJsonTestFromData(testJsonFailStartArrayAfterClosingFile)
    }
    
    func testFailEndObjectAfterClosingFileJson() {
        performJsonTestFromData(testJsonFailEndObjectAfterClosingFile)
    }
    
    func testFailEndArrayAfterClosingFileJson() {
        performJsonTestFromData(testJsonFailEndArrayAfterClosingFile)
    }
    
    func testFailAddKeyAfterClosingFileJson() {
        performJsonTestFromData(testJsonFailAddKeyAfterClosingFile)
    }
    
    func testFailAddValueAfterClosingFileJson() {
        performJsonTestFromData(testJsonFailAddValueAfterClosingFile)
    }
}
