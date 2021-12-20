//
//  Validator.swift
//  PrimerSDK
//
//  Created by Evangelos on 20/12/21.
//

import Foundation

class Validator {
    
    static func validate(iban: String) -> Bool {
        let validator = Validator(val: iban)
        return validator.isValidIBAN
    }
    
    static func validate(cardNumber: String) -> Bool {
        let validator = Validator(val: cardNumber)
        return validator.isValidCardNumber
    }
    
    static func validate(expiryDate: String) -> Bool {
        let validator = Validator(val: expiryDate)
        return validator.isValidExpiryDate
    }
    
    static func validate(cvv: String, for cardNetwork: CardNetwork?) -> Bool {
        let validator = Validator(val: (cvv, cardNetwork))
        return validator.isValidCVV
    }
    
    static func validate(cardholderName: String) -> Bool {
        let validator = Validator(val: cardholderName)
        return validator.isValidCardholderName
    }
    
    static func validate(clientToken: String) -> Bool {
        guard let decodedClientToken = clientToken.jwtTokenPayload else { return false}
        return decodedClientToken.isValid
    }
    
    internal let val: Any
    
    init(val: Any) {
        self.val = val
    }
    
    /**
     Validates if string is a valid IBAN. Follows the principles for IBAN validation found https://en.wikipedia.org/wiki/International_Bank_Account_Number#Validating_the_IBAN
     
     - Important:
     It will only take alphanumeric characters into account.
     */
    private var isValidIBAN: Bool {
        guard let iban = val as? String else { return false }
        let tmpIBAN = iban.keepOnlyCharacters(in: CharacterSet.alphanumerics)
        return validateIBANChecksum(iban: tmpIBAN)
    }
    
    private func validateIBANChecksum(iban: String) -> Bool {
        guard iban.count >= 4 else { return false }
        
        let uppercase = iban.uppercased()
        
        // Interpret the string as a decimal integer and compute the remainder of that number on division by 97
        let symbols: [Character] = Array(uppercase)
        let swapped = symbols.dropFirst(IBAN.controlNumberStart + IBAN.controlNumberLength) + symbols.prefix(IBAN.controlNumberEnd)
        
        let mod: Int = swapped.reduce(0) { (previousMod, char) in
            // Replace each letter in the string with two digits, thereby expanding the string, where A = 10, B = 11, ..., Z = 35
            let value = Int(String(char), radix: 36)! // "0" => 0, "A" => 10, "Z" => 35
            let factor = value < 10 ? 10 : 100
            return (factor * previousMod + value) % IBAN.modulo
        }
        
        return mod == 1
    }
    
    private var isValidCardNumber: Bool {
        guard let cardNumber = val as? String else { return false }
        let clearedCardNumber = cardNumber.withoutNonNumericCharacters
        
        let cardNetwork = CardNetwork(cardNumber: clearedCardNumber)
        if let cardNumberValidation = cardNetwork.validation {
            if !cardNumberValidation.lengths.contains(clearedCardNumber.count) {
                return false
            }
        }
        
        return clearedCardNumber.count >= 13 && clearedCardNumber.count <= 19 && clearedCardNumber.isValidLuhn
    }
    
    private var isValidExpiryDate: Bool {
        guard var dateStr = val as? String else { return false }
        dateStr = dateStr.replacingOccurrences(of: "/", with: "")
        if dateStr.count != 4 {
            return false
        }
        
        if !dateStr.isNumeric {
            return false
        }
        
        guard let date = dateStr.toDate(withFormat: "MMyy") else { return false }
        return date.endOfMonth > Date()
    }
    
    private var isValidCVV: Bool {
        guard let tuple = val as? (String, CardNetwork?) else { return false }
        if let numberOfDigits = tuple.1?.validation?.code.length {
            return tuple.0.count == numberOfDigits
        }
        
        return tuple.0.count > 2 && tuple.0.count < 5
    }
    
    private var isValidCardholderName: Bool {
        guard let cardholderName = val as? String else { return false }
        if cardholderName.isEmpty { return false }
        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ '`~.-")
        return !(cardholderName.rangeOfCharacter(from: set.inverted) != nil)
    }
    
}
