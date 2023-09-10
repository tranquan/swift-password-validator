//
//  PasswordValidatorTests.swift
//
//  Created by Kenji on 2023-09-04.
//

import XCTest
import SwiftPasswordValidator

final class PasswordValidatorTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testHasLowercase() throws {
		let validator = PasswordValidatorBuilder().hasLowercase().build()
		XCTAssertEqual(validator.validate("123").success, false)
		XCTAssertEqual(validator.validate("a").success, true)
		XCTAssertEqual(validator.validate("б").success, true)
		XCTAssertEqual(validator.validate("ABCa").success, true)
	}
	
	func testHasUppercase() throws {
		let validator = PasswordValidatorBuilder().hasUppercase().build()
		XCTAssertEqual(validator.validate("abc").success, false)
		XCTAssertEqual(validator.validate("A").success, true)
		XCTAssertEqual(validator.validate("Б").success, true)
		XCTAssertEqual(validator.validate("ABC123").success, true)
	}
	
	func testHasNumbers() throws {
		let validator = PasswordValidatorBuilder().hasNumbers().build()
		XCTAssertEqual(validator.validate("abc").success, false)
		XCTAssertEqual(validator.validate("1").success, true)
		XCTAssertEqual(validator.validate("١").success, true)
		XCTAssertEqual(validator.validate("abc9").success, true)
	}
	
	func testHasSymbols() throws {
		let validator = PasswordValidatorBuilder().hasSymbols().build()
		
		// common symbols should success
		Array("!@#$%^&*\"'+,-./\\|:;<=>?^_`~[]{}()").forEach { char in
			XCTAssertEqual(validator.validate(String(char)).success, true)
		}
		
		// latin letters and number should fail
		Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890").forEach { char in
			XCTAssertEqual(validator.validate(String(char)).success, false, "\(char) should fasle")
		}
		
		// space is considered as a symbol
		XCTAssertEqual(validator.validate(" ").success, true)
	}
	
	func testHasLength() throws {
		let lengthZero = PasswordValidatorBuilder().hasLength(0).build()
		XCTAssertEqual(lengthZero.validate("").success, true)
		XCTAssertEqual(lengthZero.validate("123").success, true)
		
		let lengthOne = PasswordValidatorBuilder().hasLength(1).build()
		XCTAssertEqual(lengthOne.validate("").success, false)
		XCTAssertEqual(lengthOne.validate("1").success, true)
		XCTAssertEqual(lengthOne.validate("12").success, true)
		
		let length20 = PasswordValidatorBuilder().hasLength(20).build()
		XCTAssertEqual(length20.validate("").success, false)
		XCTAssertEqual(length20.validate("123").success, false)
		XCTAssertEqual(length20.validate("1234567890abcdefghijk").success, true)
		XCTAssertEqual(length20.validate("1234567890123456789 ").success, true)
	}
}
