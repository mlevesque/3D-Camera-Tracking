//
//  JsonTestValues.swift
//  Camera Tracker RecorderTests
//
//  Created by Michael Levesque on 8/13/19.
//  Copyright © 2019 Michael Levesque. All rights reserved.
//

import Foundation
@testable import Cam_Track_Rec

fileprivate let indent = "  "

enum JsonTestAction {
    case StartObject
    case EndObject
    case StartArray
    case EndArray
    case AddKey
    case AddValue
    case AddNullValue
    case CloseFile
}

struct NilEn: Encodable {}

struct TestEncodeObject: Encodable {
    let testValue1: Int
    let testValue2: Float
    let testValue3: String
    let testValue4: Double
    let testValue5: Bool
}

struct TestJsonData<T> where T: Encodable {
    let actions: [(action:JsonTestAction, value:Any?, encodeValue:T?, newLine: Bool?, shouldFail:Bool)]
    let result: String?
    let encodableNewLine: Bool?
}

let testJsonEmpty = TestJsonData<NilEn>(
    actions: [],
    result: """
    {}
    """,
    encodableNewLine: nil
)

let testJsonSingleLevelKeyValueNewLine = TestJsonData<NilEn>(
    actions: [
        (.AddKey,    "intKey",   nil, true, false),
        (.AddValue,  123,        nil, true, false),
        (.AddKey,    "boolKey",  nil, true, false),
        (.AddValue,  true,       nil, true, false),
        (.AddKey,    "stringKey",nil, true, false),
        (.AddValue,  "string",   nil, true, false),
        (.AddKey,    "floatKey", nil, true, false),
        (.AddValue,  -0.567,     nil, true, false),
        (.CloseFile, nil,        nil, true, false)
    ],
    result: """
    {
    \(indent)"intKey" :
    \(indent)123,
    \(indent)"boolKey" :
    \(indent)true,
    \(indent)"stringKey" :
    \(indent)"string",
    \(indent)"floatKey" :
    \(indent)-0.567
    }
    """,
    encodableNewLine: nil
)

let testJsonSingleLevelKeyValueNoNewLine = TestJsonData<NilEn>(
    actions: [
        (.AddKey,    "intKey",   nil, false, false),
        (.AddValue,  123,        nil, false, false),
        (.AddKey,    "boolKey",  nil, false, false),
        (.AddValue,  true,       nil, false, false),
        (.AddKey,    "stringKey",nil, false, false),
        (.AddValue,  "string",   nil, false, false),
        (.AddKey,    "floatKey", nil, false, false),
        (.AddValue,  -0.567,     nil, false, false),
        (.CloseFile, nil,        nil, false, false)
    ],
    result: """
    {\
    "intKey" : 123, \
    "boolKey" : true, \
    "stringKey" : "string", \
    "floatKey" : -0.567\
    }
    """,
    encodableNewLine: nil
)

let testJsonSingleLevelArrayNewLine = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "arrayKey", nil, true, false),
        (.StartArray,   nil,        nil, true, false),
        (.AddValue,     1,          nil, true, false),
        (.AddValue,     2,          nil, true, false),
        (.AddValue,     3,          nil, true, false),
        (.AddValue,     4,          nil, true, false),
        (.AddValue,     5,          nil, true, false),
        (.CloseFile,    nil,        nil, true, false)
    ],
    result: """
    {
    \(indent)"arrayKey" :
    \(indent)[
    \(indent)\(indent)1,
    \(indent)\(indent)2,
    \(indent)\(indent)3,
    \(indent)\(indent)4,
    \(indent)\(indent)5
    \(indent)]
    }
    """,
    encodableNewLine: nil
)

let testJsonSingleLevelArrayNoNewLine = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "arrayKey", nil, false, false),
        (.StartArray,   nil,        nil, false, false),
        (.AddValue,     1,          nil, false, false),
        (.AddValue,     2,          nil, false, false),
        (.AddValue,     3,          nil, false, false),
        (.AddValue,     4,          nil, false, false),
        (.AddValue,     5,          nil, false, false),
        (.CloseFile,    nil,        nil, false, false)
    ],
    result: """
    {"arrayKey" : [1, 2, 3, 4, 5]}
    """,
    encodableNewLine: nil
)

let testJsonTwoLevelMixed1 = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "arrayKey", nil, true,  false),
        (.StartArray,   nil,        nil, false, false),
        (.StartObject,  nil,        nil, true,  false),
        (.EndObject,    nil,        nil, false, false),
        (.StartObject,  nil,        nil, true,  false),
        (.AddKey,       "testKey",  nil, true,  false),
        (.AddValue,     123,        nil, false, false),
        (.AddKey,       "testKey2", nil, false, false),
        (.AddValue,     456,        nil, true,  false),
        (.EndObject,    nil,        nil, true,  false),
        (.EndArray,     nil,        nil, false, false),
        (.CloseFile,    nil,        nil, true,  false)
    ],
    result: """
    {
    \(indent)"arrayKey" : [
    \(indent)\(indent){},
    \(indent)\(indent){
    \(indent)\(indent)\(indent)"testKey" : 123, "testKey2" :
    \(indent)\(indent)\(indent)456
    \(indent)\(indent)}]
    }
    """,
    encodableNewLine: nil
)

let testJsonTwoLevelMixed2 = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "objKey",   nil, nil, false),
        (.StartObject,  nil,        nil, nil, false),
        (.AddKey,       "valKey",   nil, nil, false),
        (.AddValue,     123,        nil, nil, false),
        (.EndObject,    nil,        nil, nil, false),
        (.AddKey,       "arrKey",   nil, nil, false),
        (.StartArray,   nil,        nil, nil, false),
        (.AddValue,     1,          nil, nil, false),
        (.AddValue,     2,          nil, nil, false),
        (.EndArray,     nil,        nil, nil, false),
        (.AddKey,       "objKey2",  nil, nil, false),
        (.StartObject,  nil,        nil, nil, false),
        (.EndObject,    nil,        nil, nil, false),
        (.AddKey,       "arrKey2",  nil, nil, false),
        (.StartArray,   nil,        nil, nil, false),
        (.EndArray,     nil,        nil, nil, false),
        (.CloseFile,    nil,        nil, nil, false)
    ],
    result: """
    {
    \(indent)"objKey" : {
    \(indent)\(indent)"valKey" : 123
    \(indent)},
    \(indent)"arrKey" : [
    \(indent)\(indent)1,
    \(indent)\(indent)2
    \(indent)],
    \(indent)"objKey2" : {},
    \(indent)"arrKey2" : []
    }
    """,
    encodableNewLine: nil
)

let testJsonAutoCompleteObject = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "objKey",   nil, nil, false),
        (.StartObject,  nil,        nil, nil, false)
    ],
    result: """
    {
    \(indent)"objKey" : {}
    }
    """,
    encodableNewLine: nil
)

let testJsonAutoCompleteArray = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "arrKey",   nil, nil, false),
        (.StartArray,   nil,        nil, nil, false)
    ],
    result: """
    {
    \(indent)"arrKey" : []
    }
    """,
    encodableNewLine: nil
)

let testJsonAutoCompleteKey = TestJsonData<NilEn>(
    actions: [
        (.AddKey, "key", nil, nil, false)
    ],
    result: """
    {
    \(indent)"key" : {}
    }
    """,
    encodableNewLine: nil
)

let testJsonEncodableNewLine = TestJsonData<TestEncodeObject>(
    actions: [
        (.AddKey,   "key", nil, true, false),
        (.AddValue, nil,    TestEncodeObject(
            testValue1: 123,
            testValue2: 0.12300000339746475,
            testValue3: "myString",
            testValue4: 0.123456,
            testValue5: true), true, false
        )
    ],
    result: """
    {
    \(indent)"key" :
    \(indent){
    \(indent)\(indent)"testValue1" : 123,
    \(indent)\(indent)"testValue2" : 0.12300000339746475,
    \(indent)\(indent)"testValue3" : "myString",
    \(indent)\(indent)"testValue4" : 0.123456,
    \(indent)\(indent)"testValue5" : true
    \(indent)}
    }
    """,
    encodableNewLine: true
)

let testJsonEncodableNoNewLine = TestJsonData<TestEncodeObject>(
    actions: [
        (.AddKey,   "key", nil, false, false),
        (.AddValue, nil,    TestEncodeObject(
            testValue1: 123,
            testValue2: 0.12300000339746475,
            testValue3: "myString",
            testValue4: 0.123456,
            testValue5: true), false, false
        )
    ],
    result: """
    {\
    "key" : {\
    "testValue1" : 123, \
    "testValue2" : 0.12300000339746475, \
    "testValue3" : "myString", \
    "testValue4" : 0.123456, \
    "testValue5" : true\
    }
    }
    """,
    encodableNewLine: false
)

let testJsonEncodableNoNewLineEncodableOnly = TestJsonData<TestEncodeObject>(
    actions: [
        (.AddKey,   "key", nil, true, false),
        (.AddValue, nil,    TestEncodeObject(
            testValue1: 123,
            testValue2: 0.12300000339746475,
            testValue3: "myString",
            testValue4: 0.123456,
            testValue5: true), true, false
        )
    ],
    result: """
    {
    \(indent)"key" :
    \(indent){\
    "testValue1" : 123, \
    "testValue2" : 0.12300000339746475, \
    "testValue3" : "myString", \
    "testValue4" : 0.123456, \
    "testValue5" : true\
    }
    }
    """,
    encodableNewLine: false
)

let testJsonEncodableNoNewLineEncodableOnlyWithSpacesInStrings = TestJsonData<TestEncodeObject>(
    actions: [
        (.AddKey,   "key", nil, true, false),
        (.AddValue, nil,    TestEncodeObject(
            testValue1: 123,
            testValue2: 0.12300000339746475,
            testValue3: "myString\twith some\nwhitespaces",
            testValue4: 0.123456,
            testValue5: true), true, false
        )
    ],
    result: """
    {
    \(indent)"key" :
    \(indent){\
    "testValue1" : 123, \
    "testValue2" : 0.12300000339746475, \
    "testValue3" : "myString\\twith some\\nwhitespaces", \
    "testValue4" : 0.123456, \
    "testValue5" : true\
    }
    }
    """,
    encodableNewLine: false
)

let testJsonEncodableNoNewLineEncodableOnlyWithQuotesInStrings = TestJsonData<TestEncodeObject>(
    actions: [
        (.AddKey,   "key", nil, true, false),
        (.AddValue, nil,    TestEncodeObject(
            testValue1: 123,
            testValue2: 0.12300000339746475,
            testValue3: "\"myString\"\twith some\nwhitespaces\"",
            testValue4: 0.123456,
            testValue5: true), true, false
        )
    ],
    result: """
    {
    \(indent)"key" :
    \(indent){\
    "testValue1" : 123, \
    "testValue2" : 0.12300000339746475, \
    "testValue3" : "\\\"myString\\\"\\twith some\\nwhitespaces\\\"", \
    "testValue4" : 0.123456, \
    "testValue5" : true\
    }
    }
    """,
    encodableNewLine: false
)

let testJsonNullValue = TestJsonData<TestEncodeObject>(
    actions: [
        (.AddKey,       "key",      nil, nil, false),
        (.AddNullValue, nil,        nil, nil, false),
        (.CloseFile,    nil,        nil, nil, false)
    ],
    result: """
    {
    \(indent)"key" : null
    }
    """,
    encodableNewLine: false
)


let testJsonFailAddValueOnObject = TestJsonData<NilEn>(
    actions: [
        (.AddValue, "badValue", nil, nil, true),
    ],
    result: nil,
    encodableNewLine: false
)

let testJsonFailAddDoubleKeys = TestJsonData<NilEn>(
    actions: [
        (.AddKey, "key1", nil, nil, false),
        (.AddKey, "key2", nil, nil, true),
    ],
    result: nil,
    encodableNewLine: false
)

let testJsonFailEndObjectInKey = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "key1", nil, nil, false),
        (.StartObject,  nil,    nil, nil, false),
        (.AddKey,       "key2", nil, nil, false),
        (.EndObject,    nil,    nil, nil, true)
    ],
    result: nil,
    encodableNewLine: false
)

let testJsonFailAddDuplicateKey = TestJsonData<NilEn>(
    actions: [
        (.AddKey,   "key",   nil, nil, false),
        (.AddValue, "value", nil, nil, false),
        (.AddKey,   "key",   nil, nil, true),
        (.AddValue, "value", nil, nil, true)
    ],
    result: nil,
    encodableNewLine: false
)

let testJsonFailEndArrayOnObject = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "key",  nil, nil, false),
        (.StartObject,  nil,    nil, nil, false),
        (.EndArray,     nil,    nil, nil, true),
    ],
    result: nil,
    encodableNewLine: false
)

let testJsonFailEndObjectOnArray = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "key", nil, nil, false),
        (.StartArray,   nil,   nil, nil, false),
        (.EndObject,    nil,   nil, nil, true),
    ],
    result: nil,
    encodableNewLine: false
)

let testJsonFailStartArrayOnTopLevel = TestJsonData<NilEn>(
    actions: [
        (.StartArray, nil, nil, nil, true),
    ],
    result: nil,
    encodableNewLine: false
)

let testJsonFailStartObjectOnTopLevel = TestJsonData<NilEn>(
    actions: [
        (.StartObject, nil, nil, nil, true),
    ],
    result: nil,
    encodableNewLine: false
)

let testJsonFailEndObjectTooManyTimes = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "objKey",   nil, nil, false),
        (.StartObject,  nil,        nil, nil, false),
        (.EndObject,    nil,        nil, nil, false),
        (.EndObject,    nil,        nil, nil, true),
        (.EndObject,    nil,        nil, nil, true),
    ],
    result: nil,
    encodableNewLine: false
)

let testJsonFailStartObjectAfterClosingFile = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "objKey",   nil, nil, false),
        (.StartObject,  nil,        nil, nil, false),
        (.EndObject,    nil,        nil, nil, false),
        (.CloseFile,    nil,        nil, nil, false),
        (.StartObject,  nil,        nil, nil, true),
    ],
    result: nil,
    encodableNewLine: false
)

let testJsonFailStartArrayAfterClosingFile = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "objKey",   nil, nil, false),
        (.StartObject,  nil,        nil, nil, false),
        (.EndObject,    nil,        nil, nil, false),
        (.CloseFile,    nil,        nil, nil, false),
        (.StartArray,   nil,        nil, nil, true),
    ],
    result: nil,
    encodableNewLine: false
)

let testJsonFailEndObjectAfterClosingFile = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "objKey",   nil, nil, false),
        (.StartObject,  nil,        nil, nil, false),
        (.EndObject,    nil,        nil, nil, false),
        (.CloseFile,    nil,        nil, nil, false),
        (.EndObject,    nil,        nil, nil, true),
    ],
    result: nil,
    encodableNewLine: false
)

let testJsonFailEndArrayAfterClosingFile = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "objKey",   nil, nil, false),
        (.StartObject,  nil,        nil, nil, false),
        (.EndObject,    nil,        nil, nil, false),
        (.CloseFile,    nil,        nil, nil, false),
        (.EndArray,     nil,        nil, nil, true),
    ],
    result: nil,
    encodableNewLine: false
)

let testJsonFailAddKeyAfterClosingFile = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "objKey",   nil, nil, false),
        (.StartObject,  nil,        nil, nil, false),
        (.EndObject,    nil,        nil, nil, false),
        (.CloseFile,    nil,        nil, nil, false),
        (.AddKey,       "badKey",   nil, nil, true),
    ],
    result: nil,
    encodableNewLine: false
)

let testJsonFailAddValueAfterClosingFile = TestJsonData<NilEn>(
    actions: [
        (.AddKey,       "objKey",   nil, nil, false),
        (.StartObject,  nil,        nil, nil, false),
        (.EndObject,    nil,        nil, nil, false),
        (.CloseFile,    nil,        nil, nil, false),
        (.AddValue,     "test",     nil, nil, true),
    ],
    result: nil,
    encodableNewLine: false
)
