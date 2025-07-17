//
//  PasswordValidator.swift
//
//  Created by Kenji on 2023-09-04.
//  Based on: https://github.com/astrideducation/npm-packages/blob/main/packages/password-validator
//

import Foundation

public struct PasswordTest {
	public let testId: String
	public let test: (_ password: String) -> Bool
	public let error: String
}

public enum DefaultPasswordTestId: String, CaseIterable {
	case hasLowercase = "hasLowercase"
	case hasUppercase = "hasUppercase"
	case hasNumbers = "hasNumbers"
	case hasSymbols = "hasSymbols"
	case hasLengthPrefix = "hasLength"
}

public struct PasswordValidatorResult {
	public let success: Bool
	public let passedTests: [String]
	public let failedTests: [String]
	public let errors: [String]
}

public struct PasswordValidator {
	let tests: [PasswordTest]
	
	public func validate(_ password: String) -> PasswordValidatorResult {
		let initialResult = PasswordValidatorResult(success: true, passedTests: [], failedTests: [], errors: [])
		let finalResult = self.tests.reduce(initialResult) { result, test in
			let passed = test.test(password)
			
			let passedTests = passed ? result.passedTests + [test.testId] : result.passedTests
			let failedTests = !passed ? result.failedTests + [test.testId] : result.failedTests
			let errors = !passed ? result.errors + [test.error] : result.errors
			
			return PasswordValidatorResult(
				success: result.success && passed,
				passedTests: passedTests,
				failedTests: failedTests,
				errors: errors
			)
		}
		return finalResult
	}
}

public class PasswordValidatorBuilder {
	private var tests: [PasswordTest] = []
	
	public init() {
		self.tests = []
	}
	
	public func build() -> PasswordValidator {
		return PasswordValidator(tests: self.tests)
	}
	
	public func hasRegex(regex: String, flags: String, testId: String, error: String) -> Self {
		self.tests.append(PasswordTest(testId: testId, test: { password in
			if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
				guard let regex = try? Regex(regex) else { return false }
				return password.contains(regex)
			} else {
				// fallback to NSRegularExpression for cross-platform compatibility
				do {
					var options: NSRegularExpression.Options = []
					if flags.contains("i") {
						options.insert(.caseInsensitive)
					}
					if flags.contains("m") {
						options.insert(.anchorsMatchLines)
					}
					if flags.contains("s") {
						options.insert(.dotMatchesLineSeparators)
					}
					
					let nsRegex = try NSRegularExpression(pattern: regex, options: options)
					let range = NSRange(location: 0, length: password.utf16.count)
					return nsRegex.firstMatch(in: password, options: [], range: range) != nil
				} catch {
					return false
				}
			}
		}, error: error))
		return self
	}
	
	public func hasLowercase(error: String? = nil) -> Self {
		return self.hasRegex(
			regex: #"^(?=.*[\p{Ll}])"#,
			flags: "u",
			testId: DefaultPasswordTestId.hasLowercase.rawValue,
			error: error ?? "The password must contain at least one lowercase letter."
		)
	}
	
	public func hasUppercase(error: String? = nil) -> Self {
		return self.hasRegex(
			regex: #"^(?=.*[\p{Lu}])"#,
			flags: "u",
			testId: DefaultPasswordTestId.hasUppercase.rawValue,
			error: error ?? "The password must contain at least one uppercase letter."
		)
	}
	
	public func hasNumbers(error: String? = nil) -> Self {
		return self.hasRegex(
			regex: #"^(?=.*[\p{N}])"#,
			flags: "u",
			testId: DefaultPasswordTestId.hasNumbers.rawValue,
			error: error ?? "The password must contain at least one number."
		)
	}
	
	public func hasSymbols(error: String? = nil) -> Self {
		return self.hasRegex(
			regex: #"^(?=.*[^a-zA-Z0-9])"#, // as long as it's not alphabet, we considered it's symbol
			flags: "",
			testId: DefaultPasswordTestId.hasSymbols.rawValue,
			error: error ?? "The password must contain at least one special symbol."
		)
	}
	
	public func hasLength(_ length: Int, error: String? = nil) -> Self {
		return self.hasRegex(
			regex: "^(?=.{\(length),})",
			flags: "",
			testId: "\(DefaultPasswordTestId.hasLengthPrefix.rawValue)\(length)",
			error: error ?? "The password must be at least \(length) characters long."
		)
	}
}
