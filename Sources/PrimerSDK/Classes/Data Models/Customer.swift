//
//  Customer.swift
//  PrimerSDK
//
//  Created by Evangelos on 22/11/21.
//

#if canImport(UIKit)

import Foundation

@available(*, deprecated, message: "Set the customer in the client session with POST /client-session. See documentation here: https://primer.io/docs/api#tag/Client-Session")
public struct Customer: Codable {
    let firstName: String?
    let lastName: String?
    let emailAddress: String?
    let homePhoneNumber: String?
    let mobilePhoneNumber: String?
    let workPhoneNumber: String?
    var billingAddress: Address?
    
    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        emailAddress: String? = nil,
        homePhoneNumber: String? = nil,
        mobilePhoneNumber: String? = nil,
        workPhoneNumber: String? = nil,
        billingAddress: Address? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
        self.homePhoneNumber = homePhoneNumber
        self.mobilePhoneNumber = mobilePhoneNumber
        self.workPhoneNumber = workPhoneNumber
        self.billingAddress = billingAddress
    }
}

#endif
