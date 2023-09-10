# SwiftPasswordValidator

Password validator in Swift, inspired from [password-validator](https://www.npmjs.com/package/password-validator)

## Example

```swift
let mediumPassword = PasswordValidatorBuilder()
	.hasLowercase()
	.hasUppercase()
	.hasNumbers()
	.build()
	
let result = mediumPassword.validate("Qwerty123")
// result.success: True

let strongPassword = PasswordValidatorBuilder()
	.hasLowercase()
	.hasUppercase()
	.hasNumbers()
	.hasLength(8)
	.build()
	
let result2 = strongPassword.validate("Qwerty123")
// result2.success: False
```
