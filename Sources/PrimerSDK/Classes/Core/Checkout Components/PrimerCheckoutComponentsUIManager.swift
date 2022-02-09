//
//  PrimerCheckoutComponentsUIManager.swift
//  PrimerSDK
//
//  Created by Evangelos on 9/2/22.
//

import Foundation

public protocol PrimerCheckoutComponentsInputData{}

extension PrimerCheckoutComponents {
    struct IBANData: PrimerCheckoutComponentsInputData {
        var iban: String
        var name: String
    }
    
    struct OTPData: PrimerCheckoutComponentsInputData {
        var otp: String
    }
}

extension PrimerCheckoutComponents {
    
    public class UIManager {
        private(set) public var paymentMethodType: PaymentMethodConfigType
        private let appState: AppStateProtocol = DependencyContainer.resolve()
        
        public init(paymentMethodType: PaymentMethodConfigType) throws {
            switch paymentMethodType {
            case .paymentCard:
                break
            default:
                break
            }
            
            do {
                try PrimerCheckoutComponents.validateSession()
            } catch {
                ErrorHandler.handle(error: error)
                throw error
            }
            
            guard let availablePaymentMethodTypes = PrimerCheckoutComponents.listAvailablePaymentMethodsTypes() else {
                let err = PrimerError.invalidClientToken(userInfo: nil)
                ErrorHandler.handle(error: err)
                throw err
            }
            
            if !availablePaymentMethodTypes.contains(paymentMethodType) {
                let err = PrimerError.invalidClientToken(userInfo: nil)
                ErrorHandler.handle(error: err)
                throw err
            }
            
            self.paymentMethodType = paymentMethodType
        }
        
        public func startTokenization(withData data: PrimerCheckoutComponentsInputData? = nil) {
            guard let data = data else { return }
            
            if let ibanData = data as? IBANData {
                
            } else if let otpData = data as? OTPData {
                
            }
        }
    }
    
    public class CardFormUIManager: UIManager, PrimerInputElementDelegate {
        
        private(set) public var requiredInputElementTypes: [PrimerInputElementType] = []
        public var inputElements: [PrimerInputElement] = [] {
            didSet {
                var tmpInputElementsDelegates: [(PrimerInputElement, PrimerInputElementDelegate)] = []
                inputElements.forEach { el in
                    tmpInputElementsDelegates.append(( el, el.inputElementDelegate ))
                }
                inputElements.forEach { el in
                    el.inputElementDelegate = self
                }
                originalInputElementsDelegates = tmpInputElementsDelegates
                print("")
            }
        }
        private var originalInputElementsDelegates: [(PrimerInputElement, PrimerInputElementDelegate)] = []
        private(set) public var isFormValid: Bool = false
        
        public override init(paymentMethodType: PaymentMethodConfigType) throws {
            try super.init(paymentMethodType: paymentMethodType)
            self.requiredInputElementTypes = PrimerCheckoutComponents.listInputElementTypes(for: paymentMethodType) ?? []
        }
        
        public override func startTokenization(withData data: PrimerCheckoutComponentsInputData? = nil) {
            do {
                try PrimerCheckoutComponents.validateSession()
            } catch {
                ErrorHandler.handle(error: error)
                PrimerCheckoutComponents.delegate?.onEvent(.failure(error: error))
                return
            }
            
            PrimerCheckoutComponents.delegate?.onEvent(.preparationStarted)

            firstly {
                self.validateUI()
            }
            .then { () -> Promise<PaymentMethodTokenizationRequest> in
                return self.buildRequestBody()
            }
            .then { requestbody -> Promise<PaymentMethodToken> in
                return self.tokenize(request: requestbody)
            }
            .done { paymentMethodToken in
                PrimerCheckoutComponents.delegate?.onEvent(.tokenizationSucceeded(paymentMethodToken: paymentMethodToken, resumeHandler: nil))
            }
            .catch { err in
                PrimerCheckoutComponents.delegate?.onEvent(.failure(error: err))
            }
        }
        
        internal func validateUI() -> Promise<Void> {
            return Promise { seal in
                for inputElementType in self.requiredInputElementTypes {
                    if self.inputElements.filter({ $0.type == inputElementType }).isEmpty {
                        seal.reject(PrimerError.generic(message: "", userInfo: nil))
                        return
                    }
                }
                
                seal.fulfill()
            }
        }
        
        internal func buildRequestBody() -> Promise<PaymentMethodTokenizationRequest> {
            return Promise { seal in
                do {
                    switch self.paymentMethodType {
                    case .paymentCard:
                        guard let cardnumberField = inputElements.filter({ $0.type == .cardNumber }).first as? PrimerCheckoutComponents.TextField,
                              let expiryDateField = inputElements.filter({ $0.type == .expiryDate }).first as? PrimerCheckoutComponents.TextField,
                              let cvvField = inputElements.filter({ $0.type == .cvv }).first as? PrimerCheckoutComponents.TextField
                        else {
                            seal.reject(PrimerError.generic(message: "", userInfo: nil))
                            return
                        }
                        
                        guard cardnumberField.isValid,
                              expiryDateField.isValid,
                              cvvField.isValid
                        else {
                            seal.reject(PrimerError.generic(message: "", userInfo: nil))
                            return
                        }
                        
                        guard let cardNumber = cardnumberField._text,
                              let expiryDate = expiryDateField._text,
                              let cvv = cvvField._text
                        else {
                            seal.reject(PrimerError.generic(message: "", userInfo: nil))
                            return
                        }
                        
                        let expiryArr = expiryDate.components(separatedBy: expiryDateField.type.delimiter!)
                        let expiryMonth = expiryArr[0]
                        let expiryYear = "20" + expiryArr[1]
                        
                        var cardholderName: String?
                        if let cardholderNameField = inputElements.filter({ $0.type == .cardholderName }).first as? PrimerCheckoutComponents.TextField {
                            if !cardholderNameField.isValid {
                                seal.reject(PrimerError.generic(message: "", userInfo: nil))
                                return
                            }
                            
                            cardholderName = cardholderNameField._text
                        }
                        
                        let paymentInstrument = PaymentInstrument(
                            number: PrimerInputElementType.cardNumber.clearFormatting(value: cardNumber) as! String,
                            cvv: cvv,
                            expirationMonth: expiryMonth,
                            expirationYear: expiryYear,
                            cardholderName: cardholderName,
                            paypalOrderId: nil,
                            paypalBillingAgreementId: nil,
                            shippingAddress: nil,
                            externalPayerInfo: nil,
                            paymentMethodConfigId: nil,
                            token: nil,
                            sourceConfig: nil,
                            gocardlessMandateId: nil,
                            klarnaAuthorizationToken: nil,
                            klarnaCustomerToken: nil,
                            sessionData: nil)
                        
                        let primerSettings: PrimerSettingsProtocol = DependencyContainer.resolve()
                        let customerId = primerSettings.customerId
                        let request = PaymentMethodTokenizationRequest(paymentInstrument: paymentInstrument, paymentFlow: nil, customerId: nil)
                        seal.fulfill(request)
                        
                    default:
                        fatalError()
                    }
                } catch {
                    seal.reject(error)
                }
            }
        }
        
        internal func tokenize(request: PaymentMethodTokenizationRequest) -> Promise<PaymentMethodToken> {
            return Promise { seal in
                let apiClient: PrimerAPIClientProtocol = DependencyContainer.resolve()
                apiClient.tokenizePaymentMethod(clientToken: ClientTokenService.decodedClientToken!, paymentMethodTokenizationRequest: request) { result in
                    switch result {
                    case .success(let paymentMethodToken):
                        seal.fulfill(paymentMethodToken)

                    case .failure(let err):
                        let containerErr = PrimerError.underlyingErrors(errors: [err], userInfo: ["file": #file, "class": "\(Self.self)", "function": #function, "line": "\(#line)"])
                        ErrorHandler.handle(error: containerErr)
                        seal.reject(err)
                    }
                }
            }
        }
        
        public func inputElementShouldFocus(_ sender: PrimerInputElement) -> Bool {
            guard let senderTextField = sender as? PrimerCheckoutComponents.TextField else { return true }
            guard let inputElementWithOriginalDelegate = originalInputElementsDelegates.filter({ ($0.0 as? PrimerCheckoutComponents.TextField) == senderTextField }).first else { return true }
            
            if let shouldFocus = inputElementWithOriginalDelegate.1.inputElementShouldFocus?(sender) {
                return shouldFocus
            } else {
                return true
            }
        }
        
        public func inputElementDidFocus(_ sender: PrimerInputElement) {
            guard let senderTextField = sender as? PrimerCheckoutComponents.TextField else { return }
            guard let inputElementWithOriginalDelegate = originalInputElementsDelegates.filter({ ($0.0 as? PrimerCheckoutComponents.TextField) == senderTextField }).first else { return }
            inputElementWithOriginalDelegate.1.inputElementDidFocus?(sender)
        }
        
        public func inputElementShouldBlur(_ sender: PrimerInputElement) -> Bool {
            guard let senderTextField = sender as? PrimerCheckoutComponents.TextField else { return true }
            guard let inputElementWithOriginalDelegate = originalInputElementsDelegates.filter({ ($0.0 as? PrimerCheckoutComponents.TextField) == senderTextField }).first else { return true }
            
            if let shouldBlur = inputElementWithOriginalDelegate.1.inputElementShouldBlur?(sender) {
                return shouldBlur
            } else {
                return true
            }
        }
        
        public func inputElementDidBlur(_ sender: PrimerInputElement) {
            guard let senderTextField = sender as? PrimerCheckoutComponents.TextField else { return }
            guard let inputElementWithOriginalDelegate = originalInputElementsDelegates.filter({ ($0.0 as? PrimerCheckoutComponents.TextField) == senderTextField }).first else { return }
            inputElementWithOriginalDelegate.1.inputElementDidBlur?(sender)
        }
        
        public func inputElementValueDidChange(_ sender: PrimerInputElement) {
            guard let senderTextField = sender as? PrimerCheckoutComponents.TextField else { return }
            guard let inputElementWithOriginalDelegate = originalInputElementsDelegates.filter({ ($0.0 as? PrimerCheckoutComponents.TextField) == senderTextField }).first else { return }
            inputElementWithOriginalDelegate.1.inputElementValueDidChange?(sender)
        }
        
        public func inputElementDidDetectType(_ sender: PrimerInputElement, type: Any?) {
            guard let senderTextField = sender as? PrimerCheckoutComponents.TextField else { return }
            guard let inputElementWithOriginalDelegate = originalInputElementsDelegates.filter({ ($0.0 as? PrimerCheckoutComponents.TextField) == senderTextField }).first else { return }
            
            if let cvvTextField = self.inputElements.filter({ $0.type == .cvv }).first as? PrimerCheckoutComponents.TextField {
                cvvTextField.detectedValueType = type
            }
            
            inputElementWithOriginalDelegate.1.inputElementDidDetectType?(sender, type: type)
        }
        
        public func inputElementValueIsValid(_ sender: PrimerInputElement, isValid: Bool) {
            guard let senderTextField = sender as? PrimerCheckoutComponents.TextField else { return }
            guard let inputElementWithOriginalDelegate = originalInputElementsDelegates.filter({ ($0.0 as? PrimerCheckoutComponents.TextField) == senderTextField }).first else { return }
            inputElementWithOriginalDelegate.1.inputElementValueIsValid?(sender, isValid: isValid)
            
            DispatchQueue.global(qos: .userInitiated).async {
                var tmpIsFormValid: Bool
                let inputElementsValidation = self.inputElements.compactMap({ $0.isValid })
                tmpIsFormValid = !inputElementsValidation.contains(false)
                
                if tmpIsFormValid != self.isFormValid {
                    self.isFormValid = tmpIsFormValid
                }
            }
        }
    }
    
}
