//
//  KlarnaService.swift
//  PrimerSDK
//
//  Created by Carl Eriksson on 22/02/2021.
//

#if canImport(UIKit)

internal protocol KlarnaServiceProtocol {
    func createPaymentSession(_ completion: @escaping (Result<String, Error>) -> Void)
    func createKlarnaCustomerToken(_ completion: @escaping (Result<KlarnaCustomerTokenAPIResponse, Error>) -> Void)
    func finalizePaymentSession(_ completion: @escaping (Result<KlarnaFinalizePaymentSessionresponse, Error>) -> Void)
}

internal class KlarnaService: KlarnaServiceProtocol {
    
    deinit {
        log(logLevel: .debug, message: "🧨 deinit: \(self) \(Unmanaged.passUnretained(self).toOpaque())")
    }

    func createPaymentSession(_ completion: @escaping (Result<String, Error>) -> Void) {
        let state: AppStateProtocol = DependencyContainer.resolve()

        guard let clientToken = state.decodedClientToken else {
            return completion(.failure(KlarnaException.noToken))
        }

        let settings: PrimerSettingsProtocol = DependencyContainer.resolve()
        
        guard let configId = state.paymentMethodConfig?.getConfig(for: .klarna)?.id else {
            return completion(.failure(KlarnaException.noPaymentMethodConfigId))
        }

        guard let klarnaSessionType = settings.klarnaSessionType else {
            return completion(.failure(KlarnaException.undefinedSessionType))
        }
        
        var amount = settings.amount
        if amount == nil && Primer.shared.flow == .checkoutWithKlarna {
            return completion(.failure(KlarnaException.noAmount))
        }
        
        
        var orderItems: [OrderItem]? = nil
                        
        if case .hostedPaymentPage = klarnaSessionType {
            if amount == nil {
                return completion(.failure(KlarnaException.noAmount))
            }
            
            if settings.currency == nil {
                return completion(.failure(KlarnaException.noCurrency))
            }
            
            if settings.orderItems.isEmpty {
                return completion(.failure(KlarnaException.missingOrderItems))
            }
            
            if !settings.orderItems.filter({ $0.unitAmount == nil }).isEmpty {
                return completion(.failure(KlarnaException.orderItemMissesAmount))
            }
            
            orderItems = settings.orderItems

            log(logLevel: .info, message: "Klarna amount: \(amount!) \(settings.currency!.rawValue)")
            
        } else if case .recurringPayment = klarnaSessionType {
            // Do not send amount for recurring payments, even if it's set
            amount = nil
        }
        
        var body: KlarnaCreatePaymentSessionAPIRequest
        
        if settings.countryCode != nil || settings.currency != nil {
            body = KlarnaCreatePaymentSessionAPIRequest(
                paymentMethodConfigId: configId,
                sessionType: klarnaSessionType,
                localeData: settings.localeData,
                description: klarnaSessionType == .recurringPayment ? settings.klarnaPaymentDescription : nil,
                redirectUrl: "https://primer.io/success",
                totalAmount: amount,
                orderItems: orderItems)
        } else {
            body = KlarnaCreatePaymentSessionAPIRequest(
                paymentMethodConfigId: configId,
                sessionType: klarnaSessionType,
                localeData: settings.localeData,
                description: klarnaSessionType == .recurringPayment ? settings.klarnaPaymentDescription : nil,
                redirectUrl: "https://primer.io/success",
                totalAmount: amount,
                orderItems: orderItems)
        }
        
        log(logLevel: .info, message: "config ID: \(configId)", className: "KlarnaService", function: "createPaymentSession")
        
        let api: PrimerAPIClientProtocol = DependencyContainer.resolve()

        api.klarnaCreatePaymentSession(clientToken: clientToken, klarnaCreatePaymentSessionAPIRequest: body) { [weak self] (result) in
            switch result {
            case .failure:
                completion(.failure(KlarnaException.failedApiCall))
            case .success(let response):
                log(logLevel: .info, message: "\(response)", className: "KlarnaService", function: "createPaymentSession")
                state.sessionId = response.sessionId
                completion(.success(response.hppRedirectUrl))
            }
        }
    }

    func createKlarnaCustomerToken(_ completion: @escaping (Result<KlarnaCustomerTokenAPIResponse, Error>) -> Void) {
        let state: AppStateProtocol = DependencyContainer.resolve()
        
        guard let clientToken = state.decodedClientToken else {
            return completion(.failure(KlarnaException.noToken))
        }
        
        let settings: PrimerSettingsProtocol = DependencyContainer.resolve()

        guard let configId = state.paymentMethodConfig?.getConfig(for: .klarna)?.id,
              let authorizationToken = state.authorizationToken,
              let sessionId = state.sessionId else {
            return completion(.failure(KlarnaException.noPaymentMethodConfigId))
        }

        let body = CreateKlarnaCustomerTokenAPIRequest(
            paymentMethodConfigId: configId,
            sessionId: sessionId,
            authorizationToken: authorizationToken,
            description: settings.klarnaPaymentDescription,
            localeData: settings.localeData
        )
        
        let api: PrimerAPIClientProtocol = DependencyContainer.resolve()

        api.klarnaCreateCustomerToken(clientToken: clientToken, klarnaCreateCustomerTokenAPIRequest: body) { (result) in
            switch result {
            case .failure:
                completion(.failure(KlarnaException.failedApiCall))
            case .success(let response):
                log(logLevel: .info, message: "\(response)", className: "KlarnaService", function: "createCustomerToken")
                completion(.success(response))
            }
        }
    }

    func finalizePaymentSession(_ completion: @escaping (Result<KlarnaFinalizePaymentSessionresponse, Error>) -> Void) {
        let state: AppStateProtocol = DependencyContainer.resolve()
        
        guard let clientToken = state.decodedClientToken else {
            return completion(.failure(KlarnaException.noToken))
        }

        guard let config = state.paymentMethodConfig?.getConfig(for: .klarna),
              let configId = config.id,
              let sessionId = state.sessionId else {
            return completion(.failure(KlarnaException.noPaymentMethodConfigId))
        }

        let body = KlarnaFinalizePaymentSessionRequest(paymentMethodConfigId: configId, sessionId: sessionId)

        log(logLevel: .info, message: "config ID: \(configId)", className: "KlarnaService", function: "finalizePaymentSession")
        
        let api: PrimerAPIClientProtocol = DependencyContainer.resolve()

        api.klarnaFinalizePaymentSession(clientToken: clientToken, klarnaFinalizePaymentSessionRequest: body) { (result) in
            switch result {
            case .failure:
                completion(.failure(KlarnaException.failedApiCall))
            case .success(let response):
                log(logLevel: .info, message: "\(response)", className: "KlarnaService", function: "createPaymentSession")
                completion(.success(response))
            }
        }
    }
}

#endif
