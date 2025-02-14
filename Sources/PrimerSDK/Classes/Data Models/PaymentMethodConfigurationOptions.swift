//
//  PaymentMethodConfigurationOptions.swift
//  PrimerSDK
//
//  Created by Evangelos on 28/12/21.
//

#if canImport(UIKit)

import Foundation

protocol PaymentMethodOptions: Codable { }

extension PaymentMethodOptions { }

struct ApayaOptions: PaymentMethodOptions {
    let merchantAccountId: String
}

struct PayPalOptions: PaymentMethodOptions {
    let clientId: String
}

struct CardOptions: PaymentMethodOptions {
    let threeDSecureEnabled: Bool
    let threeDSecureToken: String?
    let threeDSecureInitUrl: String?
    let threeDSecureProvider: String
    let processorConfigId: String?
}

struct AsyncPaymentMethodOptions: PaymentMethodOptions {
    
    let paymentMethodType: PaymentMethodConfigType
    let paymentMethodConfigId: String
    let type: String = "OFF_SESSION_PAYMENT"
    let sessionInfo: SessionInfo?
    
    private enum CodingKeys : String, CodingKey {
        case type, paymentMethodType, paymentMethodConfigId, sessionInfo
    }
    
    init(
        paymentMethodType: PaymentMethodConfigType,
        paymentMethodConfigId: String,
        sessionInfo: SessionInfo?
    ) {
        self.paymentMethodType = paymentMethodType
        self.paymentMethodConfigId = paymentMethodConfigId
        self.sessionInfo = sessionInfo
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(paymentMethodType.rawValue, forKey: .paymentMethodType)
        try container.encode(paymentMethodConfigId, forKey: .paymentMethodConfigId)
        try? container.encode(sessionInfo, forKey: .sessionInfo)
    }
    
    struct SessionInfo: Codable {
        var locale: String
        var platform: String = "IOS"
        var redirectionUrl: String? = PrimerSettings.current.urlScheme
    }
    
}

struct BlikPaymentMethodOptions: PaymentMethodOptions {
    
    let paymentMethodType: PaymentMethodConfigType
    let paymentMethodConfigId: String
    let type: String = "OFF_SESSION_PAYMENT"
    let sessionInfo: SessionInfo?
    
    private enum CodingKeys : String, CodingKey {
        case type, paymentMethodType, paymentMethodConfigId, sessionInfo
    }
    
    init(
        paymentMethodType: PaymentMethodConfigType,
        paymentMethodConfigId: String,
        sessionInfo: SessionInfo?
    ) {
        self.paymentMethodType = paymentMethodType
        self.paymentMethodConfigId = paymentMethodConfigId
        self.sessionInfo = sessionInfo
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(paymentMethodType.rawValue, forKey: .paymentMethodType)
        try container.encode(paymentMethodConfigId, forKey: .paymentMethodConfigId)
        try? container.encode(sessionInfo, forKey: .sessionInfo)
    }
    
    struct SessionInfo: Codable {
        let blikCode: String
        let locale: String
        let platform: String = "IOS"
        let redirectionUrl: String? = PrimerSettings.current.urlScheme
    }
    
}

#endif

