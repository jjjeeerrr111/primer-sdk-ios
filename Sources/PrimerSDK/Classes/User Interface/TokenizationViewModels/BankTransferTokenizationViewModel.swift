//
//  BankTransferTokenizationViewModel.swift
//  PrimerSDK
//
//  Created by Evangelos on 20/12/21.
//

#if canImport(UIKit)

import Foundation
import UIKit

class BankTransferTokenizationViewModel: PaymentMethodTokenizationViewModel {
    
    private var flow: PaymentFlow
    
    override lazy var title: String = {
        return "Bank Transfer"
    }()
    
    override lazy var buttonTitle: String? = {
        switch config.type {
        case .adyenBankTransfer:
            return Primer.shared.flow.internalSessionFlow.vaulted
            ? NSLocalizedString("payment-method-type-bank-transfer-vault",
                                tableName: nil,
                                bundle: Bundle.primerResources,
                                value: "Bank Transfer",
                                comment: "Bank Transfer - Payment Method Type (Vault)")
            
            : NSLocalizedString("payment-method-type-bank-transfer-checkout",
                                tableName: nil,
                                bundle: Bundle.primerResources,
                                value: "Bank Transfer",
                                comment: "Bank Transfer - Payment Method Type (Checkout)")
        default:
            assert(true, "Shouldn't end up in here")
            return nil
        }
    }()
    
    override lazy var buttonImage: UIImage? = {
        switch config.type {
        default:
            assert(true, "Shouldn't end up in here")
            return nil
        }
    }()
    
    override lazy var buttonColor: UIColor? = {
        switch config.type {
        case .adyenBankTransfer:
            return theme.paymentMethodButton.color(for: .enabled)
        default:
            assert(true, "Shouldn't end up in here")
            return nil
        }
    }()
    
    override lazy var buttonTitleColor: UIColor? = {
        switch config.type {
        case .adyenBankTransfer:
            return theme.paymentMethodButton.text.color
        default:
            assert(true, "Shouldn't end up in here")
            return nil
        }
    }()
    
    override lazy var buttonBorderWidth: CGFloat = {
        switch config.type {
        case .adyenBankTransfer:
            return theme.paymentMethodButton.border.width
        default:
            assert(true, "Shouldn't end up in here")
            return 0.0
        }
    }()
    
    override lazy var buttonBorderColor: UIColor? = {
        switch config.type {
        case .adyenBankTransfer:
            return theme.paymentMethodButton.border.color(for: .enabled)
        default:
            assert(true, "Shouldn't end up in here")
            return nil
        }
    }()
    
    override lazy var buttonTintColor: UIColor? = {
        switch config.type {
        case .adyenBankTransfer:
            return theme.paymentMethodButton.iconColor
        default:
            assert(true, "Shouldn't end up in here")
            return nil
        }
    }()
    
    override lazy var buttonFont: UIFont? = {
        return UIFont.systemFont(ofSize: 17.0, weight: .medium)
    }()
    
    override lazy var buttonCornerRadius: CGFloat? = {
        return 4.0
    }()
    
    lazy var accountHolderNameTextField: PrimerTextFieldView = {
        let field = PrimerTextFieldView()
        field.placeholder = "Full name"
        
        field.heightAnchor.constraint(equalToConstant: 36).isActive = true
        field.textColor = theme.input.text.color
        field.borderStyle = .none
        field.delegate = self
        field.isValid = { text in
            return Validator.validate(cardholderName: text)
        }
        return field
    }()
    internal lazy var accountHolderNameContainerView: PrimerCustomFieldView = {
        let containerView = PrimerCustomFieldView()
        containerView.fieldView = accountHolderNameTextField
        containerView.placeholderText = "Account holder"
        containerView.setup()
        containerView.tintColor = theme.input.border.color(for: .selected)
        return containerView
    }()
    
    lazy var ibanTextField: PrimerTextFieldView = {
        let field = PrimerTextFieldView()
        field.placeholder = "AA 1234 1234 1234 1234"
        field.heightAnchor.constraint(equalToConstant: 36).isActive = true
        field.textColor = theme.input.text.color
        field.borderStyle = .none
        field.delegate = self
        field.isValid = { text in
            return Validator.validate(iban: text)
        }
        return field
    }()
    internal lazy var ibanContainerView: PrimerCustomFieldView = {
        let containerView = PrimerCustomFieldView()
        containerView.fieldView = ibanTextField
        containerView.placeholderText = "IBAN"
        containerView.setup()
        containerView.tintColor = theme.input.border.color(for: .selected)
        return containerView
    }()
    
    lazy var submitButton: PrimerOldButton = {
        var buttonTitle: String = NSLocalizedString("primer-form-view-bank-transfer-submit-button",
                                                    tableName: nil,
                                                    bundle: Bundle.primerResources,
                                                    value: "Continue",
                                                    comment: "Continue - Bank Transfer Form View (Sumbit button text)")
        
        let submitButton = PrimerOldButton()
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        submitButton.isAccessibilityElement = true
        submitButton.accessibilityIdentifier = "submit_btn"
        submitButton.isEnabled = false
        submitButton.setTitle(buttonTitle, for: .normal)
        submitButton.setTitleColor(theme.mainButton.text.color, for: .normal)
        submitButton.backgroundColor = theme.mainButton.color(for: .disabled)
        submitButton.layer.cornerRadius = 4
        submitButton.clipsToBounds = true
        submitButton.addTarget(self, action: #selector(submitButtonTapped(_:)), for: .touchUpInside)
        return submitButton
    }()
    
    var amountString: String? {
        let settings: PrimerSettingsProtocol = DependencyContainer.resolve()
        guard let amount = settings.amount else { return nil }
        guard let currency = settings.currency else { return nil }
        return amount.toCurrencyString(currency: currency)
    }
    
    required init(config: PaymentMethodConfig) {
        self.flow = Primer.shared.flow.internalSessionFlow.vaulted ? .vault : .checkout
        super.init(config: config)
    }
    
    override func validate() throws {
//        let settings: PrimerSettingsProtocol = DependencyContainer.resolve()
//
//        guard let decodedClientToken = ClientTokenService.decodedClientToken else {
//            let err = PaymentException.missingClientToken
//            _ = ErrorHandler.shared.handle(error: err)
//            throw err
//        }
//
//        guard decodedClientToken.pciUrl != nil else {
//            let err = PrimerError.tokenizationPreRequestFailed
//            _ = ErrorHandler.shared.handle(error: err)
//            throw err
//        }
//
//        if !Primer.shared.flow.internalSessionFlow.vaulted {
//            if settings.amount == nil {
//                let err = PaymentException.missingAmount
//                _ = ErrorHandler.shared.handle(error: err)
//                throw err
//            }
//
//            if settings.currency == nil {
//                let err = PaymentException.missingCurrency
//                _ = ErrorHandler.shared.handle(error: err)
//                throw err
//            }
//        }
    }
    
    @objc
    override func presentNativeUI() {
//        let cfvc = PrimerCardFormViewController(viewModel: self)
//        Primer.shared.primerRootVC?.show(viewController: cfvc)
    }
    
    @objc
    override func startTokenizationFlow() {
        super.startTokenizationFlow()
        
        let btvc = BankTransferViewController(viewModel: self)
        DispatchQueue.main.async {
            Primer.shared.primerRootVC?.show(viewController: btvc)
        }
        
//        do {
//            try self.validate()
//        } catch {
//            DispatchQueue.main.async {
//                Primer.shared.delegate?.checkoutFailed?(with: error)
//                self.handleFailedTokenizationFlow(error: error)
//            }
//            return
//        }
//
//        DispatchQueue.main.async {
//            let pcfvc = PrimerCardFormViewController(viewModel: self)
//            Primer.shared.primerRootVC?.show(viewController: pcfvc)
//        }
    }
        
    @objc
    func submitButtonTapped(_ sender: UIButton) {
//        submitButton.showSpinner(true)
//        Primer.shared.primerRootVC?.view.isUserInteractionEnabled = false
//
//        if Primer.shared.delegate?.onClientSessionActions != nil {
//            var network = self.cardNetwork?.rawValue.uppercased()
//            if network == nil || network == "UNKNOWN" {
//                network = "OTHER"
//            }
//
//            let params: [String: Any] = [
//                "paymentMethodType": "PAYMENT_CARD",
//                "binData": [
//                    "network": network,
//                ]
//            ]
//
//            onClientSessionActionCompletion = { err in
//                if let err = err {
//                    DispatchQueue.main.async {
//                        self.submitButton.showSpinner(false)
//                        Primer.shared.primerRootVC?.view.isUserInteractionEnabled = true
//                        Primer.shared.delegate?.onResumeError?(err)
//                        self.onClientSessionActionCompletion = nil
//                    }
//                    self.handle(error: err)
//                } else {
//                    self.cardComponentsManager.tokenize()
//                }
//            }
//
//            ClientSession.Action.selectPaymentMethod(resumeHandler: self, withParameters: params)
//        } else {
//            cardComponentsManager.tokenize()
//        }
    }
}

extension BankTransferTokenizationViewModel: PrimerTextFieldViewDelegate {
    
    func primerTextFieldView(_ primerTextFieldView: PrimerTextFieldView, isValid: Bool?) {
        print("isValid: \(isValid)")
        if primerTextFieldView == accountHolderNameTextField {
            
        } else if primerTextFieldView == ibanTextField {
            
        }
        
        if accountHolderNameTextField.isTextValid,
           ibanTextField.isTextValid
        {
            submitButton.isEnabled = true
            submitButton.backgroundColor = theme.mainButton.color(for: .enabled)
        } else {
            submitButton.isEnabled = false
            submitButton.backgroundColor = theme.mainButton.color(for: .disabled)
        }
    }
}

extension BankTransferTokenizationViewModel {
    
    override func handle(error: Error) {
//        DispatchQueue.main.async {
//            if self.onClientSessionActionCompletion != nil {
//                ClientSession.Action.unselectPaymentMethod(resumeHandler: nil)
//                self.onClientSessionActionCompletion?(error)
//                self.onClientSessionActionCompletion = nil
//            }
//
//            self.handleFailedTokenizationFlow(error: error)
//            self.submitButton.showSpinner(false)
//            Primer.shared.primerRootVC?.view.isUserInteractionEnabled = true
//        }
//
//        completion?(nil, error)
    }
    
    override func handle(newClientToken clientToken: String) {
//        do {
//            let state: AppStateProtocol = DependencyContainer.resolve()
//
//            if state.clientToken != clientToken {
//                try ClientTokenService.storeClientToken(clientToken)
//            }
//
//            let decodedClientToken = ClientTokenService.decodedClientToken!
//
//            if decodedClientToken.intent == RequiredActionName.threeDSAuthentication.rawValue {
//                #if canImport(Primer3DS)
//                guard let paymentMethod = paymentMethod else {
//                    DispatchQueue.main.async {
//                        let err = PrimerError.threeDSFailed
//                        Primer.shared.delegate?.onResumeError?(err)
//                    }
//                    return
//                }
//
//                let threeDSService = ThreeDSService()
//                threeDSService.perform3DS(paymentMethodToken: paymentMethod, protocolVersion: decodedClientToken.env == "PRODUCTION" ? .v1 : .v2, sdkDismissed: nil) { result in
//                    switch result {
//                    case .success(let paymentMethodToken):
//                        DispatchQueue.main.async {
//                            guard let threeDSPostAuthResponse = paymentMethodToken.1,
//                                  let resumeToken = threeDSPostAuthResponse.resumeToken else {
//                                      DispatchQueue.main.async {
//                                          let err = PrimerError.threeDSFailed
//                                          Primer.shared.delegate?.onResumeError?(err)
//                                          self.handle(error: err)
//                                      }
//                                      return
//                                  }
//
//                            Primer.shared.delegate?.onResumeSuccess?(resumeToken, resumeHandler: self)
//                        }
//
//                    case .failure(let err):
//                        log(logLevel: .error, message: "Failed to perform 3DS with error \(err as NSError)")
//                        let err = PrimerError.threeDSFailed
//                        DispatchQueue.main.async {
//                            Primer.shared.delegate?.onResumeError?(err)
//                        }
//                    }
//                }
//                #else
//                let error = PrimerError.threeDSFailed
//                DispatchQueue.main.async {
//                    Primer.shared.delegate?.onResumeError?(error)
//                }
//                #endif
//
//            } else if decodedClientToken.intent == RequiredActionName.checkout.rawValue {
//                let configService: PaymentMethodConfigServiceProtocol = DependencyContainer.resolve()
//
//                firstly {
//                    configService.fetchConfig()
//                }
//                .done {
//                    let settings: PrimerSettingsProtocol = DependencyContainer.resolve()
//                    if let amount = settings.amount {
//                        self.configurePayButton(amount: amount)
//                    }
//                    self.onClientSessionActionCompletion?(nil)
//                }
//                .catch { err in
//                    self.onClientSessionActionCompletion?(err)
//                }
//            } else {
//                let err = PrimerError.invalidValue(key: "resumeToken")
//
//                handle(error: err)
//                DispatchQueue.main.async {
//                    Primer.shared.delegate?.onResumeError?(err)
//                }
//            }
//
//        } catch {
//            handle(error: error)
//            DispatchQueue.main.async {
//                Primer.shared.delegate?.onResumeError?(error)
//            }
//        }
    }
    
    override func handleSuccess() {
//        DispatchQueue.main.async {
//            self.submitButton.showSpinner(false)
//            Primer.shared.primerRootVC?.view.isUserInteractionEnabled = true
//        }
//        completion?(paymentMethod, nil)
    }
}

#endif

