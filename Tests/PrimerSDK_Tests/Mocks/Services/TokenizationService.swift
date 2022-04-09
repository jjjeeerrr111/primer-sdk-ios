//
//  TokenizationService.swift
//  PrimerSDKTests
//
//  Created by Carl Eriksson on 16/01/2021.
//

#if canImport(UIKit)

@testable import PrimerSDK

class MockTokenizationService: TokenizationServiceProtocol {
    
    var tokenizedPaymentMethodToken: PaymentMethod.Tokenization.Response?
    
    var paymentInstrumentType: String
    var tokenType: String
    var tokenizeCalled = false
    lazy var paymentMethodTokenJSON: [String: Any] = [
        "token": "payment_method_token",
        "analyticsId": "analytics_id",
        "tokenType":  tokenType,
        "paymentInstrumentType": paymentInstrumentType
    ]
    
    init(paymentInstrumentType: String, tokenType: String) {
        self.paymentInstrumentType = paymentInstrumentType
        self.tokenType = tokenType
    }

    func tokenize(request: TokenizationRequest, onTokenizeSuccess: @escaping (Result<PaymentMethod.Tokenization.Response, Error>) -> Void) {
        tokenizeCalled = true
        
        let paymentMethodTokenData = try! JSONSerialization.data(withJSONObject: paymentMethodTokenJSON, options: .fragmentsAllowed)
        let token = try! JSONParser().parse(PaymentMethod.Tokenization.Response.self, from: paymentMethodTokenData) //PaymentMethodToken(token: "tokenID", paymentInstrumentType: .paymentCard, vaultData: VaultData())
        return onTokenizeSuccess(.success(token))
    }
    
    func tokenize(request: TokenizationRequest) -> Promise<PaymentMethod.Tokenization.Response> {
        return Promise { seal in
            self.tokenize(request: request) { result in
                switch result {
                case .failure(let err):
                    seal.reject(err)
                case .success(let res):
                    seal.fulfill(res)
                }
            }
        }
    }
}

#endif
