//
//  StringTests.swift
//  PrimerSDK_Tests
//
//  Created by Evangelos Pittas on 20/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//


import XCTest
@testable import PrimerSDK

class StringTests: XCTestCase {
    
    func test_fix_base64_ios_format_str() throws {
        var originalBase64Str = ""
        var fixedBsed64Str = ""

        originalBase64Str = "a"
        fixedBsed64Str = originalBase64Str.base64IOSFormat
        XCTAssert(fixedBsed64Str == "a===", "Should be converted to 'a==='")
        
        originalBase64Str = "ab"
        fixedBsed64Str = originalBase64Str.base64IOSFormat
        XCTAssert(fixedBsed64Str == "ab==", "Should be converted to 'ab=='")
        
        originalBase64Str = "abc"
        fixedBsed64Str = originalBase64Str.base64IOSFormat
        XCTAssert(fixedBsed64Str == "abc=", "Should be converted to 'abc='")
        
        originalBase64Str = "abcd"
        fixedBsed64Str = originalBase64Str.base64IOSFormat
        XCTAssert(fixedBsed64Str == "abcd", "Should be converted to 'abcd'")
        
        originalBase64Str = "a_cd"
        fixedBsed64Str = originalBase64Str.base64IOSFormat
        XCTAssert(fixedBsed64Str == "a/cd", "Should be converted to 'a/cd'")
        
        originalBase64Str = "ab-d"
        fixedBsed64Str = originalBase64Str.base64IOSFormat
        XCTAssert(fixedBsed64Str == "ab+d", "Should be converted to 'ab+d'")
        
        originalBase64Str = "a_-d"
        fixedBsed64Str = originalBase64Str.base64IOSFormat
        XCTAssert(fixedBsed64Str == "a/+d", "Should be converted to 'a/+d'")
        
        originalBase64Str = "a_-d_"
        fixedBsed64Str = originalBase64Str.base64IOSFormat
        XCTAssert(fixedBsed64Str == "a/+d/===", "Should be converted to 'a/+d/==='")
    }
    
    func test_jwt_token_decode() throws {
        let base64Str = "segment0.eyJleHAiOjE2MzQ4MDc2NjQsImFjY2Vzc1Rva2VuIjoiYzg2MGZmYjgtMTQ4YS00NjcyLTgzNzktZmM4YmUxOTMwYmExIiwiYW5hbHl0aWNzVXJsIjoiaHR0cHM6Ly9hbmFseXRpY3MuYXBpLnN0YWdpbmcuY29yZS5wcmltZXIuaW8vbWl4cGFuZWwiLCJpbnRlbnQiOiJQQVlfTkxfSURFQUxfUkVESVJFQ1RJT04iLCJzdGF0dXNVcmwiOiJodHRwczovL2FwaS5zdGFnaW5nLnByaW1lci5pby9yZXN1bWUtdG9rZW5zL2E5Yjk2ODYxLTAxOWUtNDMyMy04MTFmLTk3MzliOWM2YjhhMSIsInJlZGlyZWN0VXJsIjoiaHR0cHM6Ly9hcGkucGF5Lm5sL2NvbnRyb2xsZXJzL3BheW1lbnRzL2lzc3Vlci5waHA_b3JkZXJJZD0xNjAxMzQ1Nzc1WDY5OGVhJmVudHJhbmNlQ29kZT0xMTU2ZjJiMjBmY2YwMTJlZTdjZjFiYTVhNmY4ZmQ0YzA1OTI1MTUwJnByb2ZpbGVJRD02MTMmbGFuZz1OTCJ9.segment2"
        
        XCTAssert(base64Str.jwtTokenPayload != nil, "Should be able to decode base64 with _ chars")
    }
    
    func test_strip_characters() throws {
        var str = " jsK89() _\n+bdsao821^   "
        var strippedStr = str.keepOnlyCharacters(in: CharacterSet.alphanumerics)
        XCTAssert(strippedStr == "jsK89bdsao821", "'\(str)' should be converted to 'jsK89bdsao821'")
        
        str = " "
        strippedStr = str.keepOnlyCharacters(in: CharacterSet.alphanumerics)
        XCTAssert(strippedStr == "", "'\(str)' should be converted to ''")
        
        str = "-"
        strippedStr = str.keepOnlyCharacters(in: CharacterSet.alphanumerics)
        XCTAssert(strippedStr == "", "'\(str)' should be converted to ''")
        
        str = " -"
        strippedStr = str.keepOnlyCharacters(in: CharacterSet.alphanumerics)
        XCTAssert(strippedStr == "", "'\(str)' should be converted to ''")
        
        str = " -1"
        strippedStr = str.keepOnlyCharacters(in: CharacterSet.alphanumerics)
        XCTAssert(strippedStr == "1", "'\(str)' should be converted to '1'")
        
        str = "1"
        strippedStr = str.keepOnlyCharacters(in: CharacterSet.alphanumerics)
        XCTAssert(strippedStr == "1", "'\(str)' should be converted to '1'")
        
        str = "a"
        strippedStr = str.keepOnlyCharacters(in: CharacterSet.alphanumerics)
        XCTAssert(strippedStr == "a", "'\(str)' should be converted to 'a'")
    }

    func test_is_valid_iban() throws {
        var validIban = "NL10INGB6686956546"
        XCTAssert(validIban.isValidIBAN, "'\(validIban)' should be valid")

        validIban = "GB97BARC20038467693594"
        XCTAssert(validIban.isValidIBAN, "'\(validIban)' should be valid")

        validIban = "FR2530003000401478933878E80"
        XCTAssert(validIban.isValidIBAN, "'\(validIban)' should be valid")

        validIban = "DE70500105174453316465"
        XCTAssert(validIban.isValidIBAN, "'\(validIban)' should be valid")

        validIban = "EE371212446149126837"
        XCTAssert(validIban.isValidIBAN, "'\(validIban)' should be valid")

        validIban = "FI8088315212931538"
        XCTAssert(validIban.isValidIBAN, "'\(validIban)' should be valid")

        validIban = "SE9126778385485249588712"
        XCTAssert(validIban.isValidIBAN, "'\(validIban)' should be valid")

        validIban = "ES4531905521837434874245"
        XCTAssert(validIban.isValidIBAN, "'\(validIban)' should be valid")

        validIban = "BA021028997791294137"
        XCTAssert(validIban.isValidIBAN, "'\(validIban)' should be valid")
        
        var invalidIban = "NL10INGB6686956547"
        XCTAssert(!invalidIban.isValidIBAN, "'\(invalidIban)' should not be valid")
        
        invalidIban = "GB97BARC20038467693595"
        XCTAssert(!invalidIban.isValidIBAN, "'\(invalidIban)' should not be valid")
        
        invalidIban = "FR2530003000401478933878E81"
        XCTAssert(!invalidIban.isValidIBAN, "'\(invalidIban)' should not be valid")
        
        invalidIban = "DE70500105174453316466"
        XCTAssert(!invalidIban.isValidIBAN, "'\(invalidIban)' should not be valid")
        
        invalidIban = "EE371212446149126838"
        XCTAssert(!invalidIban.isValidIBAN, "'\(invalidIban)' should not be valid")
        
        invalidIban = "FI8088315212931539"
        XCTAssert(!invalidIban.isValidIBAN, "'\(invalidIban)' should not be valid")
        
        invalidIban = "SE9126778385485249588713"
        XCTAssert(!invalidIban.isValidIBAN, "'\(invalidIban)' should not be valid")
        
        invalidIban = "ES4531905521837434874246"
        XCTAssert(!invalidIban.isValidIBAN, "'\(invalidIban)' should not be valid")
        
        invalidIban = "BA021028997791294138"
        XCTAssert(!invalidIban.isValidIBAN, "'\(invalidIban)' should not be valid")
    }
}
