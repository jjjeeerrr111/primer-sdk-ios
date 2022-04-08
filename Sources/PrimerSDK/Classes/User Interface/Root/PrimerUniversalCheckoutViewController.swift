//
//  PrimerUniversalCheckoutViewController.swift
//  PrimerSDK
//
//  Created by Evangelos Pittas on 31/7/21.
//

#if canImport(UIKit)

import UIKit

internal class PrimerUniversalCheckoutViewController: PrimerFormViewController {
    
    var savedCardView: CardButton!
    private var titleLabel: UILabel!
    private var savedPaymentMethodStackView: UIStackView!
    private var payButton: PrimerButton!
    private var selectedPaymentMethod: PaymentMethodToken?
    private let theme: PrimerThemeProtocol = DependencyContainer.resolve()
    private let paymentMethodConfigViewModels = PrimerConfiguration.paymentMethodConfigViewModels
    private var onClientSessionActionCompletion: ((Error?) -> Void)?
    private var singleUsePaymentMethod: PaymentMethodToken?
    private var resumePaymentId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewEvent = Analytics.Event(
            eventType: .ui,
            properties: UIEventProperties(
                action: .view,
                context: nil,
                extra: nil,
                objectType: .view,
                objectId: nil,
                objectClass: "\(Self.self)",
                place: .universalCheckout))
        Analytics.Service.record(event: viewEvent)
        
        title = NSLocalizedString("primer-checkout-nav-bar-title",
                                          tableName: nil,
                                          bundle: Bundle.primerResources,
                                          value: "Choose payment method",
                                          comment: "Choose payment method - Checkout Navigation Bar Title")
        
        view.backgroundColor = theme.view.backgroundColor
        
        verticalStackView.spacing = 14.0
        
        renderAmount()
        renderSelectedPaymentInstrument()
        renderAvailablePaymentMethods()
        
        guard ClientTokenService.decodedClientToken.exists else { return }
        let vaultService: VaultServiceProtocol = DependencyContainer.resolve()
        vaultService.loadVaultedPaymentMethods { [weak self] error in
            
            guard error == nil else {
                self?.dismissOrShowResultScreen(error!)
                return
            }
            
            self?.renderSelectedPaymentInstrument(insertAt: 1)
        }
    }
    
    private func renderAmount() {
        let checkoutViewModel: VaultCheckoutViewModelProtocol = DependencyContainer.resolve()
        
        if let amountStr = checkoutViewModel.amountStringed {
            titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
            titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
            titleLabel.text = amountStr
            titleLabel.textColor = theme.text.amountLabel.color
            verticalStackView.addArrangedSubview(titleLabel)
        }
    }
    
    private func renderSelectedPaymentInstrument(insertAt index: Int? = nil) {
        if savedCardView != nil {
            verticalStackView.removeArrangedSubview(savedCardView)
            savedCardView.removeFromSuperview()
            savedCardView = nil
        }
        
        if savedPaymentMethodStackView != nil {
            verticalStackView.removeArrangedSubview(savedPaymentMethodStackView)
            savedPaymentMethodStackView.removeFromSuperview()
            savedPaymentMethodStackView = nil
        }
        
        let checkoutViewModel: VaultCheckoutViewModelProtocol = DependencyContainer.resolve()
        
        if let selectedPaymentMethod = checkoutViewModel.selectedPaymentMethod, let cardButtonViewModel = selectedPaymentMethod.cardButtonViewModel {
            
            self.selectedPaymentMethod = selectedPaymentMethod
            
            if savedPaymentMethodStackView == nil {
                savedPaymentMethodStackView = UIStackView()
                savedPaymentMethodStackView.axis = .vertical
                savedPaymentMethodStackView.alignment = .fill
                savedPaymentMethodStackView.distribution = .fill
                savedPaymentMethodStackView.spacing = 5.0
            }
            
            let titleHorizontalStackView = UIStackView()
            titleHorizontalStackView.axis = .horizontal
            titleHorizontalStackView.alignment = .fill
            titleHorizontalStackView.distribution = .fill
            titleHorizontalStackView.spacing = 8.0
            
            let savedPaymentMethodLabel = UILabel()
            savedPaymentMethodLabel.text = NSLocalizedString("primer-vault-checkout-payment-method-title",
                                                                      tableName: nil,
                                                                      bundle: Bundle.primerResources,
                                                                      value: "SAVED PAYMENT METHOD",
                                                                      comment: "SAVED PAYMENT METHOD - Vault Checkout Card Title")
            savedPaymentMethodLabel.adjustsFontSizeToFitWidth = true
            savedPaymentMethodLabel.minimumScaleFactor = 0.8
            savedPaymentMethodLabel.textColor = theme.text.subtitle.color
            savedPaymentMethodLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .regular)
            titleHorizontalStackView.addArrangedSubview(savedPaymentMethodLabel)
            
            let seeAllButton = UIButton()
            seeAllButton.translatesAutoresizingMaskIntoConstraints = false
            seeAllButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            let seeAllButtonTitle = NSLocalizedString("see-all",
                                                      tableName: nil,
                                                      bundle: Bundle.primerResources,
                                                      value: "See all",
                                                      comment: "See all - Universal checkout")
            seeAllButton.setTitle(seeAllButtonTitle, for: .normal)
            seeAllButton.titleLabel?.adjustsFontSizeToFitWidth = true
            seeAllButton.titleLabel?.minimumScaleFactor = 0.7
            seeAllButton.setTitleColor(theme.text.system.color, for: .normal)
            seeAllButton.addTarget(self, action: #selector(seeAllButtonTapped), for: .touchUpInside)
            titleHorizontalStackView.addArrangedSubview(seeAllButton)
            
            savedPaymentMethodStackView.addArrangedSubview(titleHorizontalStackView)
            
            let paymentMethodStackView = UIStackView()
            paymentMethodStackView.layer.cornerRadius = 4.0
            paymentMethodStackView.clipsToBounds = true
            paymentMethodStackView.backgroundColor = UIColor.black.withAlphaComponent(0.05)
            paymentMethodStackView.axis = .vertical
            paymentMethodStackView.alignment = .fill
            paymentMethodStackView.distribution = .fill
            paymentMethodStackView.spacing = 8.0
            paymentMethodStackView.isLayoutMarginsRelativeArrangement = true
            if #available(iOS 11.0, *) {
                paymentMethodStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            }

            let settings: PrimerSettingsProtocol = DependencyContainer.resolve()
            var amount: Int = settings.amount ?? 0
            
            if let surCharge = cardButtonViewModel.surCharge {
                let settings: PrimerSettingsProtocol = DependencyContainer.resolve()
                let theme: PrimerThemeProtocol = DependencyContainer.resolve()
                
                let surChargeLabel = UILabel()
                surChargeLabel.text = "+" + Int(surCharge).toCurrencyString(currency: settings.currency!)
                surChargeLabel.textColor = theme.text.body.color
                surChargeLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
                paymentMethodStackView.addArrangedSubview(surChargeLabel)
                
                amount += surCharge
            }
            
            if savedCardView == nil {
                savedCardView = CardButton()
                savedCardView.backgroundColor = .white
                savedCardView.translatesAutoresizingMaskIntoConstraints = false
                savedCardView.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
                savedCardView.render(model: cardButtonViewModel, showIcon: false)
                paymentMethodStackView.addArrangedSubview(savedCardView)
            }
            
            if payButton == nil {
                payButton = PrimerButton()
            }

            var title = NSLocalizedString("primer-form-view-card-submit-button-text-checkout",
                                          tableName: nil,
                                          bundle: Bundle.primerResources,
                                          value: "Pay",
                                          comment: "Pay - Card Form View (Sumbit button text)") //+ " " + (amount.toCurrencyString(currency: settings.currency) ?? "")
            
            if amount != 0, let currency = settings.currency {
                title += " \(amount.toCurrencyString(currency: currency))"
            }
                                    
            payButton.layer.cornerRadius = 4
            payButton.setTitle(title, for: .normal)
            payButton.setTitleColor(theme.mainButton.text.color, for: .normal)
            payButton.titleLabel?.font = .boldSystemFont(ofSize: 19)
            payButton.backgroundColor = theme.mainButton.color(for: .enabled)
            payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
            payButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            paymentMethodStackView.addArrangedSubview(payButton)
            
            if !paymentMethodStackView.arrangedSubviews.isEmpty {
                savedPaymentMethodStackView.addArrangedSubview(paymentMethodStackView)
            }

            if let index = index {
                verticalStackView.insertArrangedSubview(savedPaymentMethodStackView, at: index)
            } else {
                verticalStackView.addArrangedSubview(savedPaymentMethodStackView)
            }
        } else {
            if savedCardView != nil {
                verticalStackView.removeArrangedSubview(savedCardView)
                savedCardView.removeFromSuperview()
                savedCardView = nil
            }
            
            if savedPaymentMethodStackView != nil {
                verticalStackView.removeArrangedSubview(savedPaymentMethodStackView)
                savedPaymentMethodStackView.removeFromSuperview()
                savedPaymentMethodStackView = nil
            }
        }
        
        (self.parent as? PrimerContainerViewController)?.layoutContainerViewControllerIfNeeded {
            self.verticalStackView.layoutIfNeeded()
        }
        
        Primer.shared.primerRootVC?.layoutIfNeeded()
    }

    private func renderAvailablePaymentMethods() {
        PrimerFormViewController.renderPaymentMethods(paymentMethodConfigViewModels, on: verticalStackView)
    }

    @objc
    func seeAllButtonTapped(_ sender: Any) {
        let uiEvent = Analytics.Event(
            eventType: .ui,
            properties: UIEventProperties(
                action: .click,
                context: nil,
                extra: nil,
                objectType: .button,
                objectId: .seeAll,
                objectClass: "\(Self.self)",
                place: .universalCheckout))
        Analytics.Service.record(event: uiEvent)
        
        let vpivc = VaultedPaymentInstrumentsViewController()
        vpivc.delegate = self
        vpivc.view.translatesAutoresizingMaskIntoConstraints = false
        vpivc.view.heightAnchor.constraint(equalToConstant: self.parent!.view.bounds.height).isActive = true
        Primer.shared.primerRootVC?.show(viewController: vpivc)
    }
    
    @objc
    func payButtonTapped() {
        guard let selectedPaymentMethod = selectedPaymentMethod else { return }
        guard let config = PrimerConfiguration.paymentMethodConfigs?.filter({ $0.type.rawValue == selectedPaymentMethod.paymentInstrumentType.rawValue }).first else {
            return
        }
        
        let viewEvent = Analytics.Event(
            eventType: .ui,
            properties: UIEventProperties(
                action: .click,
                context: Analytics.Event.Property.Context(
                    issuerId: nil,
                    paymentMethodType: config.type.rawValue,
                    url: nil),
                extra: nil,
                objectType: .button,
                objectId: .pay,
                objectClass: "\(Self.self)",
                place: .universalCheckout))
        Analytics.Service.record(event: viewEvent)
        
        enableView(false)
        payButton.startAnimating()
        
        if PrimerDelegateProxy.isClientSessionActionsImplemented {
            var params: [String: Any] = ["paymentMethodType": config.type.rawValue]
            if config.type == .paymentCard {
                var network = selectedPaymentMethod.paymentInstrumentData?.network?.uppercased()
                if network == nil || network == "UNKNOWN" {
                    network = "OTHER"
                }
                
                params = [
                    "paymentMethodType": "PAYMENT_CARD",
                    "binData": [
                        "network": network,
                    ]
                ]
            }
            
            onClientSessionActionCompletion = { err in
                if let err = err {
                    DispatchQueue.main.async {
                        ClientSession.Action.unselectPaymentMethod(resumeHandler: nil)
                        PrimerDelegateProxy.onResumeError(err)
                        self.onClientSessionActionCompletion = nil
                    }
                } else {
                    self.continuePayment(withVaultedPaymentMethod: selectedPaymentMethod)
                }
            }
            
            ClientSession.Action.selectPaymentMethod(resumeHandler: self, withParameters: params)
            
        } else {
            continuePayment(withVaultedPaymentMethod: selectedPaymentMethod)
        }
    }
    
    private func continuePayment(withVaultedPaymentMethod paymentMethodToken: PaymentMethodToken) {
        guard let decodedClientToken = ClientTokenService.decodedClientToken else { return }
        let client: PrimerAPIClientProtocol = DependencyContainer.resolve()
        client.exchangePaymentMethodToken(clientToken: decodedClientToken, paymentMethodId: paymentMethodToken.id!) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let singleUsePaymentMethod):
                    self.singleUsePaymentMethod = singleUsePaymentMethod
                    self.handleContinuePaymentFlowWithPaymentMethod(singleUsePaymentMethod)
                case .failure(let error):
                    PrimerDelegateProxy.checkoutFailed(with: error)
                    self.dismissOrShowResultScreen(error)
                }
            }
        }
    }
}

extension PrimerUniversalCheckoutViewController {
    
    private func handle(_ clientToken: String) {
        
        if PrimerHeadlessUniversalCheckout.current.clientToken != clientToken {
            
            ClientTokenService.storeClientToken(clientToken) { error in
                DispatchQueue.main.async {
                    
                    guard error == nil else {
                        ErrorHandler.handle(error: error!)
                        PrimerDelegateProxy.onResumeError(error!)
                        return
                    }

                    self.continueHandleNewClientToken(clientToken)
                }
            }
        } else {
            self.continueHandleNewClientToken(clientToken)
        }
    }
    
    private func continueHandleNewClientToken(_ clientToken: String) {
        
        guard let decodedClientToken = ClientTokenService.decodedClientToken else {
            let error = PrimerError.invalidValue(key: "resumeToken", value: nil, userInfo: ["file": #file, "class": "\(Self.self)", "function": #function, "line": "\(#line)"])
            ErrorHandler.handle(error: error)
            DispatchQueue.main.async {
                self.handleErrorBasedOnSDKSettings(error)
            }
            return
        }

        if decodedClientToken.intent == RequiredActionName.threeDSAuthentication.rawValue {
            
            #if canImport(Primer3DS)
            guard let paymentMethod = singleUsePaymentMethod else {
                DispatchQueue.main.async {
                    self.onClientSessionActionCompletion = nil
                    let err = PrimerError.invalid3DSKey(userInfo: ["file": #file, "class": "\(Self.self)", "function": #function, "line": "\(#line)"])
                    ErrorHandler.handle(error: err)
                    self.handleErrorBasedOnSDKSettings(err)
                }
                return
            }
            
            let threeDSService = ThreeDSService()
            threeDSService.perform3DS(paymentMethodToken: paymentMethod, protocolVersion: ClientTokenService.decodedClientToken?.env == "PRODUCTION" ? .v1 : .v2, sdkDismissed: nil) { result in
                switch result {
                case .success(let paymentMethodToken):
                    DispatchQueue.main.async {
                        guard let threeDSPostAuthResponse = paymentMethodToken.1,
                              let resumeToken = threeDSPostAuthResponse.resumeToken else {
                                  DispatchQueue.main.async {
                                      self.onClientSessionActionCompletion = nil
                                      let err = ParserError.failedToDecode(message: "Failed to decode the threeDSPostAuthResponse", userInfo: ["file": #file, "class": "\(Self.self)", "function": #function, "line": "\(#line)"])
                                      ErrorHandler.handle(error: err)
                                      self.handleErrorBasedOnSDKSettings(err)
                                  }
                                  return
                              }
                        
                        self.handleResumeStepsBasedOnSDKSettings(resumeToken: resumeToken)
                    }
                    
                case .failure(let err):
                    log(logLevel: .error, message: "Failed to perform 3DS with error \(err as NSError)")
                    
                    DispatchQueue.main.async {
                        self.onClientSessionActionCompletion = nil
                        let containerErr = PrimerError.failedToPerform3DS(error: err, userInfo: ["file": #file, "class": "\(Self.self)", "function": #function, "line": "\(#line)"])
                        ErrorHandler.handle(error: containerErr)
                        self.handleErrorBasedOnSDKSettings(containerErr)
                    }
                }
            }
            #else
            
            DispatchQueue.main.async {
                self.onClientSessionActionCompletion = nil
                let err = PrimerError.failedToPerform3DS(error: nil, userInfo: ["file": #file, "class": "\(Self.self)", "function": #function, "line": "\(#line)"])
                ErrorHandler.handle(error: err)
                self.handleErrorBasedOnSDKSettings(err)
            }
            #endif
            
        } else if decodedClientToken.intent == RequiredActionName.checkout.rawValue {
            let configService: PaymentMethodConfigServiceProtocol = DependencyContainer.resolve()
            
            firstly {
                configService.fetchConfig()
            }
            .done {
                self.onClientSessionActionCompletion?(nil)
            }
            .catch { err in
                ErrorHandler.handle(error: err)
                DispatchQueue.main.async {
                    self.handleErrorBasedOnSDKSettings(err)
                }
            }
        } else {
            let err = PrimerError.invalidValue(key: "resumeToken", value: nil, userInfo: ["file": #file, "class": "\(Self.self)", "function": #function, "line": "\(#line)"])
            ErrorHandler.handle(error: err)
            DispatchQueue.main.async {
                self.handleErrorBasedOnSDKSettings(err)
            }
        }
    }
}

extension PrimerUniversalCheckoutViewController {
    
    // MARK: - Helpers
    
    private func handleContinuePaymentFlowWithPaymentMethod(_ paymentMethod: PaymentMethodToken) {
                
        let settings: PrimerSettingsProtocol = DependencyContainer.resolve()
        
        if settings.isManualPaymentHandlingEnabled {
            
            PrimerDelegateProxy.onTokenizeSuccess(paymentMethod, resumeHandler: self)
            
        } else {
            
            guard let paymentMethodTokenString = paymentMethod.token else {
                
                DispatchQueue.main.async {
                    let paymentMethodTokenError = PrimerError.invalidValue(key: "paymentMethodToken", value: "Payment method token not valid", userInfo: ["file": #file, "class": "\(Self.self)", "function": #function, "line": "\(#line)"])
                    ErrorHandler.handle(error: paymentMethodTokenError)
                    self.handleErrorBasedOnSDKSettings(paymentMethodTokenError)
                }
                return
            }
            
            firstly {
                self.handleCheckoutWillCreatePaymentEvent(paymentMethodTokenString)
            }
            .then { paymentCreateAdditionalValues -> Promise<Payment.Response?> in
                let clientToken = paymentCreateAdditionalValues?.clientToken ?? paymentMethodTokenString
                return self.handleCreatePaymentEvent(clientToken)
            }
            .done { paymentResponse -> Void in
                
                guard let paymentResponse = paymentResponse,
                      let paymentResponseDict = try? paymentResponse.asDictionary() else {
                          return
                      }
                
                self.resumePaymentId = paymentResponse.id
                
                if paymentResponse.status == .pending, let requiredAction = paymentResponse.requiredAction {
                    Primer.shared.delegate?.onPaymentPending?(paymentResponseDict)
                    self.handle(newClientToken: requiredAction.clientToken)
                } else {
                    Primer.shared.delegate?.checkoutDidComplete?(paymentResponseDict)
                    self.handleSuccess()
                }
            }
            .catch { error in
                self.handleErrorBasedOnSDKSettings(error)
            }
        }
    }
    
    // Raise "payment creation started" event
    
    private func handleCheckoutWillCreatePaymentEvent(_ paymentMethodData: String) -> Promise<PaymentCreateAdditionalValues?> {
        return Promise { seal in
            Primer.shared.delegate?.checkoutWillCreatePayment?(paymentMethodData, completion: { paymentCreateAdditionalValues in
                // If merchant sents a custom data
                if let clientToken = paymentCreateAdditionalValues?.clientToken {
                    seal.fulfill(PaymentCreateAdditionalValues(clientToken: clientToken))
                }
                // If merchant sents an error to show
                // The flow will terminate
                else if let errorMessage = paymentCreateAdditionalValues?.error {
                    seal.reject(errorMessage)
                }
                // If merchant will continue only with SDK data
                else {
                    seal.fulfill(nil)
                }
            })
        }
    }
    
    // Create payment with Payment method token

    private func handleCreatePaymentEvent(_ paymentMethodData: String) -> Promise<Payment.Response?> {
        
        return Promise { seal in
        
            let createResumePaymentService: CreateResumePaymentServiceProtocol = DependencyContainer.resolve()
            createResumePaymentService.createPayment(paymentRequest: Payment.CreateRequest(token: paymentMethodData)) { paymentResponse, error in
                
                guard error == nil else {
                    seal.reject(error!)
                    return
                }
                
                seal.fulfill(paymentResponse)
            }
        }
    }
    
    private func makePaymentResponseAsDictionary(_ response: Payment.Response?) -> Promise<[String: Any]?> {
        Promise { seal in
            do {
                let dictionary = try response.asDictionary()
                seal.fulfill(dictionary)
            } catch {
                seal.reject(error)
            }
        }
    }
}
    
extension PrimerUniversalCheckoutViewController {
    
    private func enableView(_ isEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.isUserInteractionEnabled = isEnabled
            (self?.parent as? PrimerContainerViewController)?.scrollView.isScrollEnabled = isEnabled
            Primer.shared.primerRootVC?.swipeGesture?.isEnabled = isEnabled
            
            for sv in (self?.verticalStackView.arrangedSubviews ?? []) {
                sv.alpha = sv == self?.savedPaymentMethodStackView ? 1.0 : (isEnabled ? 1.0 : 0.5)
            }
            
            for sv in (self?.savedPaymentMethodStackView.arrangedSubviews ?? []) {
                if let stackView = sv as? UIStackView, !stackView.arrangedSubviews.filter({ $0 is PrimerButton }).isEmpty {
                    for ssv in stackView.arrangedSubviews {
                        if ssv is PrimerButton {
                            ssv.alpha = 1.0
                        } else {
                            ssv.alpha = (isEnabled ? 1.0 : 0.5)
                        }
                    }
                } else {
                    sv.alpha = (isEnabled ? 1.0 : 0.5)
                }
            }
        }
    }
}

extension PrimerUniversalCheckoutViewController: ResumeHandlerProtocol {
    
    func handle(error: Error) {
        DispatchQueue.main.async {
            self.onClientSessionActionCompletion?(error)
            self.payButton.stopAnimating()
            self.enableView(true)
            self.dismissOrShowResultScreen(error)
            self.singleUsePaymentMethod = nil
        }
    }
    
    func handle(newClientToken clientToken: String) {
        self.handle(clientToken)
    }
    
    func handleSuccess() {
        DispatchQueue.main.async {
            self.payButton.stopAnimating()
            self.enableView(true)
            self.dismissOrShowResultScreen()
            self.singleUsePaymentMethod = nil
        }
    }
}

extension PrimerUniversalCheckoutViewController {
    
    private func handleResumeStepsBasedOnSDKSettings(resumeToken: String) {
        
        let settings: PrimerSettingsProtocol = DependencyContainer.resolve()
        
        if settings.isManualPaymentHandlingEnabled {
            PrimerDelegateProxy.onResumeSuccess(resumeToken, resumeHandler: self)
        } else {
            
            // Resume payment with Payment method token
                            
            guard let resumePaymentId = self.resumePaymentId else {
                DispatchQueue.main.async {
                    let resumePaymentIdError = PrimerError.invalidValue(key: "resumePaymentId", value: "Resume payment id token not valid", userInfo: ["file": #file, "class": "\(Self.self)", "function": #function, "line": "\(#line)"])
                    ErrorHandler.handle(error: resumePaymentIdError)
                    self.handleErrorBasedOnSDKSettings(resumePaymentIdError)
                }
                return
            }
            
            let createResumePaymentService: CreateResumePaymentServiceProtocol = DependencyContainer.resolve()
            createResumePaymentService.resumePaymentWithPaymentId(resumePaymentId, paymentResumeRequest: Payment.ResumeRequest(token: resumeToken)) { paymentResponse, error in
                
                guard let paymentResponse = paymentResponse,
                      let paymentResponseDict = try? paymentResponse.asDictionary(),
                      error == nil else {
                    self.handleErrorBasedOnSDKSettings(error!)
                    return
                }
                
                if paymentResponse.status == .pending, let requiredAction = paymentResponse.requiredAction {
                    Primer.shared.delegate?.onPaymentPending?(paymentResponseDict)
                    self.handle(newClientToken: requiredAction.clientToken)
                } else {
                    Primer.shared.delegate?.checkoutDidComplete?(paymentResponseDict)
                    self.handleSuccess()
                }
            }
        }
    }
}


extension PrimerUniversalCheckoutViewController {
    
    private func handleErrorBasedOnSDKSettings(_ error: Error) {
        
        let settings: PrimerSettingsProtocol = DependencyContainer.resolve()
        if settings.isManualPaymentHandlingEnabled {
            PrimerDelegateProxy.onResumeError(error)
            handle(error: error)
        } else {
            Primer.shared.delegate?.checkoutDidFail?(error: error, data: nil, completion: { errorMessage in
                let merchantError = PrimerError.merchantError(message: errorMessage ?? "")
                self.handle(error: merchantError)
            })
        }
    }
}


extension PrimerUniversalCheckoutViewController: ReloadDelegate {
    func reload() {
        renderSelectedPaymentInstrument(insertAt: 1)
    }
}

extension PrimerUniversalCheckoutViewController {
    
    func dismissOrShowResultScreen(_ error: Error? = nil) {
        
        let settings: PrimerSettingsProtocol = DependencyContainer.resolve()
        
        if settings.hasDisabledSuccessScreen {
            Primer.shared.dismiss()
        } else {
            let status: PrimerResultViewController.ScreenType = error == nil ? .success : .failure
            let resultViewController = PrimerResultViewController(screenType: status, message: error?.localizedDescription)
            resultViewController.view.translatesAutoresizingMaskIntoConstraints = false
            resultViewController.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
            Primer.shared.primerRootVC?.show(viewController: resultViewController)
        }
    }
}

#endif
