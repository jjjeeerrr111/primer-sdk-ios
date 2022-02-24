//
//  ViewController.swift
//  HeadlessUniversalCheckoutExample
//
//  Created by Evangelos on 16/2/22.
//

import PrimerSDK
import UIKit

class PayViewController: MyViewController {
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet weak var amountLabel: UILabel!
    var payByCardButton: UIButton!
    let amount = 10001
    let currency = Currency.EUR
    let countryCode = CountryCode.de
    var cardFormUIManager: PrimerHeadlessUniversalCheckout.CardFormUIManager!
    
    var availablePaymentMethodsTypes: [PrimerPaymentMethodType]?
    var transactionResponse: TransactionResponse?
    var paymentResponsesData: [Data] = []
    
    deinit {
        self.cardFormUIManager = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.amountLabel.text = "PRICE: " + amount.toCurrencyString(currencySymbol: currency.rawValue)
        self.configurePrimerHeadlessCheckout()
    }
    
    func configurePrimerHeadlessCheckout() {
        self.showLoading()
        self.fetchClientToken { (clientToken, err) in
            if let err = err {
                self.stopLoading()
                self.showError(withMessage: err.localizedDescription)
                
            } else if let clientToken = clientToken {
                // 👇 Settings are optional, but they are needed for Apple Pay and PayPal
                let settings = PrimerSettings(
                    merchantIdentifier: "merchant.dx.team",  // 👈 Entitlement added in Xcode's settings, required for Apple Pay
                    urlScheme: "merchant://")                // 👈 URL Scheme added in Xcode's settings, required for PayPal
                
                PrimerHeadlessUniversalCheckout.current.delegate = self
                PrimerHeadlessUniversalCheckout.current.start(withClientToken: clientToken, settings: settings) { [unowned self] (paymentMethodTypes, err) in
                    self.stopLoading()
                    
                    if let err = err {
                        self.showError(withMessage: err.localizedDescription)
                    } else if let paymentMethodTypes = paymentMethodTypes {
                        self.availablePaymentMethodsTypes = paymentMethodTypes
                        self.renderPaymentMethodsTypes()
                    }
                }
            }
        }
    }
    
    func fetchClientToken(completion: @escaping (String?, Error?) -> Void) {
        let networking = Networking()
        networking.requestClientSession(
            requestBody: Networking.buildClientSessionRequestBody(amount: amount, currency: currency, countryCode: countryCode),
            completion: completion)
    }
    
    func renderPaymentMethodsTypes() {
        guard let availablePaymentMethodsTypes = self.availablePaymentMethodsTypes, !availablePaymentMethodsTypes.isEmpty else {
            self.showError(withMessage: "Card payments are not available")
            return
        }
        
        let separatorView1 = UIView()
        separatorView1.backgroundColor = .clear
        self.stackView.addArrangedSubview(separatorView1)
        separatorView1.translatesAutoresizingMaskIntoConstraints = false
        separatorView1.heightAnchor.constraint(equalToConstant: 12).isActive = true

        if availablePaymentMethodsTypes.contains(.paymentCard) {
            do {
                self.cardFormUIManager = try PrimerHeadlessUniversalCheckout.CardFormUIManager()
                self.cardFormUIManager.cardFormUIManagerDelegate = self
                self.makeCardForm()
            } catch {
                self.stopLoading()
                self.showError(withMessage: error.localizedDescription)
                return
            }

            self.payByCardButton = UIButton()
            self.setPayByCardButton(enabled: true)

            self.payByCardButton.translatesAutoresizingMaskIntoConstraints = false
            self.payByCardButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            self.payByCardButton.addTarget(self, action: #selector(self.payWithCardTapped(_:)), for: .touchUpInside)
            self.payByCardButton.setTitle("Pay by card", for: .normal)
            self.payByCardButton.setTitleColor(.systemBlue, for: .normal)
            self.payByCardButton.setTitleColor(.gray, for: .disabled)
            self.payByCardButton.layer.borderColor = UIColor.lightGray.cgColor
            self.payByCardButton.layer.borderWidth = 1.0
            self.payByCardButton.layer.cornerRadius = 4.0
            self.stackView.addArrangedSubview(self.payByCardButton)

            let separatorView2 = UIView()
            separatorView2.backgroundColor = .clear
            self.stackView.addArrangedSubview(separatorView2)
            separatorView2.translatesAutoresizingMaskIntoConstraints = false
            separatorView2.heightAnchor.constraint(equalToConstant: 12).isActive = true

            let separatorView3 = UIView()
            separatorView3.backgroundColor = .lightGray
            self.stackView.addArrangedSubview(separatorView3)
            separatorView3.translatesAutoresizingMaskIntoConstraints = false
            separatorView3.heightAnchor.constraint(equalToConstant: 1).isActive = true

            let separatorView4 = UIView()
            separatorView4.backgroundColor = .clear
            self.stackView.addArrangedSubview(separatorView4)
            separatorView4.translatesAutoresizingMaskIntoConstraints = false
            separatorView4.heightAnchor.constraint(equalToConstant: 12).isActive = true
        }
        
        if availablePaymentMethodsTypes.contains(.adyenAlipay) {
            guard let adyenAliPayButton = PrimerHeadlessUniversalCheckout.makeButton(for: .adyenAlipay) else { return }
            adyenAliPayButton.addTarget(self, action: #selector(self.payWithAdyenAliPayTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(adyenAliPayButton)
        }
        
        if availablePaymentMethodsTypes.contains(.adyenGiropay) {
            guard let adyenGiropayButton = PrimerHeadlessUniversalCheckout.makeButton(for: .adyenGiropay) as? Button else { return }
            adyenGiropayButton.addTarget(self, action: #selector(self.payWithAdyenGiropayTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(adyenGiropayButton)
        }
        
        if availablePaymentMethodsTypes.contains(.adyenMobilePay) {
            guard let adyenMobilePayButton = PrimerHeadlessUniversalCheckout.makeButton(for: .adyenMobilePay) else { return }
            adyenMobilePayButton.addTarget(self, action: #selector(self.payWithAdyenMobilePayTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(adyenMobilePayButton)
        }
        
        if availablePaymentMethodsTypes.contains(.adyenSofort) {
            guard let adyenSofortButton = PrimerHeadlessUniversalCheckout.makeButton(for: .adyenSofort) else { return }
            adyenSofortButton.addTarget(self, action: #selector(self.payWithAdyenSofortTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(adyenSofortButton)
        }
        
        if availablePaymentMethodsTypes.contains(.adyenTrustly) {
            guard let adyenTrustlyButton = PrimerHeadlessUniversalCheckout.makeButton(for: .adyenTrustly) else { return }
            adyenTrustlyButton.addTarget(self, action: #selector(self.payWithAdyenTrustlyTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(adyenTrustlyButton)
        }
        
        if availablePaymentMethodsTypes.contains(.adyenTwint) {
            guard let adyenTwintButton = PrimerHeadlessUniversalCheckout.makeButton(for: .adyenTwint) else { return }
            adyenTwintButton.addTarget(self, action: #selector(self.payWithAdyenTwintTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(adyenTwintButton)
        }
        
        if availablePaymentMethodsTypes.contains(.adyenVipps) {
            guard let adyenVippsButton = PrimerHeadlessUniversalCheckout.makeButton(for: .adyenVipps) else { return }
            adyenVippsButton.addTarget(self, action: #selector(self.payWithAdyenVippsTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(adyenVippsButton)
        }
        
        if availablePaymentMethodsTypes.contains(.applePay) {
            guard let applePayButton = PrimerHeadlessUniversalCheckout.makeButton(for: .applePay) else { return }
            applePayButton.addTarget(self, action: #selector(self.payWithApplePayTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(applePayButton)
        }
        
        if availablePaymentMethodsTypes.contains(.atome) {
            guard let atomeButton = PrimerHeadlessUniversalCheckout.makeButton(for: .atome) else { return }
            atomeButton.addTarget(self, action: #selector(self.payWithAtomeTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(atomeButton)
        }
        
        if availablePaymentMethodsTypes.contains(.buckarooBancontact) {
            guard let buckarooBancontactButton = PrimerHeadlessUniversalCheckout.makeButton(for: .buckarooBancontact) else { return }
            buckarooBancontactButton.addTarget(self, action: #selector(self.payWithBuckarooBancontactTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(buckarooBancontactButton)
        }
        
        if availablePaymentMethodsTypes.contains(.buckarooEps) {
            guard let buckarooEpsButton = PrimerHeadlessUniversalCheckout.makeButton(for: .buckarooEps) else { return }
            buckarooEpsButton.addTarget(self, action: #selector(self.payWithBuckarooEpsTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(buckarooEpsButton)
        }
        
        if availablePaymentMethodsTypes.contains(.buckarooGiropay) {
            guard let buckarooGiropayButton = PrimerHeadlessUniversalCheckout.makeButton(for: .buckarooGiropay) else { return }
            buckarooGiropayButton.addTarget(self, action: #selector(self.payWithBuckarooGiropayTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(buckarooGiropayButton)
        }
        
        if availablePaymentMethodsTypes.contains(.buckarooIdeal) {
            guard let buckarooIdealButton = PrimerHeadlessUniversalCheckout.makeButton(for: .buckarooIdeal) else { return }
            buckarooIdealButton.addTarget(self, action: #selector(self.payWithBuckarooIdealTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(buckarooIdealButton)
        }
        
        if availablePaymentMethodsTypes.contains(.buckarooSofort) {
            guard let buckarooSofortButton = PrimerHeadlessUniversalCheckout.makeButton(for: .buckarooSofort) else { return }
            buckarooSofortButton.addTarget(self, action: #selector(self.payWithBuckarooSofortTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(buckarooSofortButton)
        }
        
        if availablePaymentMethodsTypes.contains(.hoolah) {
            guard let hoolahButton = PrimerHeadlessUniversalCheckout.makeButton(for: .hoolah) else { return }
            hoolahButton.addTarget(self, action: #selector(self.payWithHoolahTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(hoolahButton)
        }
        
        if availablePaymentMethodsTypes.contains(.mollieBankcontact) {
            guard let mollieBankcontactButton = PrimerHeadlessUniversalCheckout.makeButton(for: .mollieBankcontact) else { return }
            mollieBankcontactButton.addTarget(self, action: #selector(self.payWithMollieIdealTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(mollieBankcontactButton)
        }
        
        if availablePaymentMethodsTypes.contains(.mollieIdeal) {
            guard let mollieIdealButton = PrimerHeadlessUniversalCheckout.makeButton(for: .mollieIdeal) else { return }
            mollieIdealButton.addTarget(self, action: #selector(self.payWithMollieIdealTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(mollieIdealButton)
        }
        
        if availablePaymentMethodsTypes.contains(.payNLBancontact) {
            guard let payNLBancontactButton = PrimerHeadlessUniversalCheckout.makeButton(for: .payNLBancontact) else { return }
            payNLBancontactButton.addTarget(self, action: #selector(self.payWithPayNLBancontactTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(payNLBancontactButton)
        }
        
        if availablePaymentMethodsTypes.contains(.payNLGiropay) {
            guard let payNLGiropayButton = PrimerHeadlessUniversalCheckout.makeButton(for: .payNLGiropay) else { return }
            payNLGiropayButton.addTarget(self, action: #selector(self.payWithPayNLGiropayTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(payNLGiropayButton)
        }
        
        if availablePaymentMethodsTypes.contains(.payNLIdeal) {
            guard let payNLIdealButton = PrimerHeadlessUniversalCheckout.makeButton(for: .payNLIdeal) else { return }
            payNLIdealButton.addTarget(self, action: #selector(self.payWithPayNLIdealTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(payNLIdealButton)
        }
        
        if availablePaymentMethodsTypes.contains(.payNLPayconiq) {
            guard let payNLPayconiqButton = PrimerHeadlessUniversalCheckout.makeButton(for: .payNLPayconiq) else { return }
            payNLPayconiqButton.addTarget(self, action: #selector(self.payWithPayNLPayconiqTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(payNLPayconiqButton)
        }
        
        if availablePaymentMethodsTypes.contains(.payPal) {
            guard let payPalButton = PrimerHeadlessUniversalCheckout.makeButton(for: .payPal) else { return }
            payPalButton.addTarget(self, action: #selector(self.payWithPayPalButtonTapped(_:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(payPalButton)
        }
    }
    
    func makeCardForm() {
        var inputElements: [PrimerInputTextField] = []
        
        for requiredInputElementType in self.cardFormUIManager.requiredInputElementTypes {
            let textField = PrimerInputTextField(type: requiredInputElementType, frame: .zero)
            textField.inputElementDelegate = self
            
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
            textField.backgroundColor = .white
            textField.borderStyle = .none
            textField.layer.cornerRadius = 4.0
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = UIColor.systemBlue.cgColor
            textField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
        
            switch requiredInputElementType {
            case .cardNumber:
                textField.placeholder = "4242 4242 4242 4242"
                textField.text = "9120000000000006"
            case .expiryDate:
                textField.placeholder = "02/24"
                textField.text = "02/24"
            case .cvv:
                textField.placeholder = "123"
                textField.text = "123"
            case .cardholderName:
                textField.placeholder = "John Smith"
                textField.text = "John Smith"
            default:
                break
            }
            
            inputElements.append(textField)
        }
        
        cardFormUIManager.inputElements = inputElements
        
        if let cardNumberField = inputElements.filter({ $0.type == .cardNumber }).first {
            self.stackView.addArrangedSubview(cardNumberField)
        }
        
        if let expiryDateField = inputElements.filter({ $0.type == .expiryDate }).first,
           let cvvField = inputElements.filter({ $0.type == .cvv }).first {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 6.0
            rowStackView.distribution = .fillEqually
            rowStackView.addArrangedSubview(expiryDateField)
            rowStackView.addArrangedSubview(cvvField)
            
            self.stackView.addArrangedSubview(rowStackView)
            rowStackView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let cardholderNameField = inputElements.filter({ $0.type == .cardholderName }).first {
            self.stackView.addArrangedSubview(cardholderNameField)
        }
        
        if let postalCodeField = inputElements.filter({ $0.type == .postalCode }).first {
            self.stackView.addArrangedSubview(postalCodeField)
        }
    }
    
    func setPayByCardButton(enabled: Bool) {
        self.payByCardButton.isEnabled = enabled
        self.payByCardButton.layer.borderColor = enabled ? UIColor.systemBlue.cgColor : UIColor.lightGray.cgColor
    }
    
    @IBAction func payWithCardTapped(_ sender: Any) {
        self.cardFormUIManager?.tokenize()
    }
    
    @IBAction func payWithAdyenAliPayTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.adyenAlipay)
    }
    
    @IBAction func payWithAdyenGiropayTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.adyenGiropay)
    }
    
    @IBAction func payWithAdyenMobilePayTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.adyenMobilePay)
    }
    
    @IBAction func payWithAdyenSofortTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.adyenSofort)
    }
    
    @IBAction func payWithAdyenTrustlyTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.adyenTrustly)
    }
    
    @IBAction func payWithAdyenTwintTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.adyenTwint)
    }
    
    @IBAction func payWithAdyenVippsTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.adyenVipps)
    }

    @IBAction func payWithApplePayTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.applePay)
    }
    
    @IBAction func payWithAtomeTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.atome)
    }
    
    @IBAction func payWithBuckarooBancontactTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.buckarooBancontact)
    }
    
    @IBAction func payWithBuckarooEpsTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.buckarooEps)
    }
    
    @IBAction func payWithBuckarooGiropayTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.buckarooGiropay)
    }
    
    @IBAction func payWithBuckarooIdealTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.buckarooIdeal)
    }
    
    @IBAction func payWithBuckarooSofortTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.buckarooSofort)
    }
    
    @IBAction func payWithHoolahTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.hoolah)
    }
    
    @IBAction func payWithMollieBankcontactTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.mollieBankcontact)
    }
    
    @IBAction func payWithMollieIdealTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.mollieIdeal)
    }
    
    @IBAction func payWithPayNLBancontactTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.payNLBancontact)
    }
    
    
    @IBAction func payWithPayNLGiropayTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.payNLGiropay)
    }
    
    @IBAction func payWithPayNLIdealTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.payNLIdeal)
    }
    
    @IBAction func payWithPayNLPayconiqTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.payNLPayconiq)
    }
    
    @IBAction func payWithPayPalButtonTapped(_ sender: Any) {
        PrimerHeadlessUniversalCheckout.current.showPaymentMethod(.payPal)
    }
   
}

extension PayViewController: PrimerInputElementDelegate {
    func inputElementDidBlur(_ sender: PrimerInputElement) {
        
    }
    
    func inputElementDidFocus(_ sender: PrimerInputElement) {
        
    }
    
    func inputElementValueDidChange(_ sender: PrimerInputElement) {
        
    }
    
    func inputElementDidDetectType(_ sender: PrimerInputElement, type: Any?) {
        
    }
    
    func inputElementValueIsValid(_ sender: PrimerInputElement, isValid: Bool) {
        guard isValid else { return }
        let invalidInputElements = self.cardFormUIManager.inputElements.filter({ $0.isValid != true })
        guard !invalidInputElements.isEmpty else { return }
        
        if sender.type == .expiryDate {
            if let invalidCvvInputElement = invalidInputElements.filter({ $0.type == .cvv }).first as? PrimerInputTextField {
                invalidCvvInputElement.becomeFirstResponder()
            }
        } else if sender.type == .cvv {
            if let invalidCardholderNameInputElement = invalidInputElements.filter({ $0.type == .cardholderName }).first as? PrimerInputTextField {
                invalidCardholderNameInputElement.becomeFirstResponder()
            }
        }
    }
}

extension PayViewController: PrimerCardFormDelegate {
    func cardFormUIManager(_ cardFormUIManager: PrimerHeadlessUniversalCheckout.CardFormUIManager, isCardFormValid: Bool) {
        self.setPayByCardButton(enabled: isCardFormValid)
    }
}

extension PayViewController: PrimerHeadlessUniversalCheckoutDelegate {
    func primerHeadlessUniversalCheckoutClientSessionDidSetUpSuccessfully() {
        
    }
    
    func primerHeadlessUniversalCheckoutPreparationStarted() {
        self.showLoading()
    }
    
    func primerHeadlessUniversalCheckoutTokenizationStarted() {
        self.showLoading()
    }
    
    func primerHeadlessUniversalCheckoutPaymentMethodPresented() {
        
    }
    
    func primerHeadlessUniversalCheckoutTokenizationSucceeded(paymentMethodToken: PaymentMethodToken, resumeHandler: ResumeHandlerProtocol?) {
        self.showLoading()
        
        let networking = Networking()
        networking.createPayment(with: paymentMethodToken) { res, err in
            if let err = err {
                self.stopLoading()
                self.showError(withMessage: err.localizedDescription)
                
            } else if let res = res {
                if let data = try? JSONEncoder().encode(res) {
                    self.paymentResponsesData.append(data)
                }
                
                guard let requiredAction = res.requiredAction else {
                    self.stopLoading()
                    resumeHandler?.handleSuccess()
                    return
                }
                
                guard let dateStr = res.dateStr else {
                    self.stopLoading()
                    resumeHandler?.handleSuccess()
                    return
                }
                
                self.transactionResponse = TransactionResponse(id: res.id, date: dateStr, status: res.status.rawValue, requiredAction: requiredAction)
                
                if requiredAction.name == "3DS_AUTHENTICATION", res.status == .pending {
                    resumeHandler?.handle(newClientToken: requiredAction.clientToken)
                } else if requiredAction.name == "USE_PRIMER_SDK", res.status == .pending {
                    resumeHandler?.handle(newClientToken: requiredAction.clientToken)
                } else {
                    let prvc = PaymentResultViewController.instantiate(data: self.paymentResponsesData)
                    self.navigationController?.pushViewController(prvc, animated: true)
                }
            }
        }
    }
    
    func primerHeadlessUniversalCheckoutResume(withResumeToken resumeToken: String, resumeHandler: ResumeHandlerProtocol?) {
        guard let transactionResponse = transactionResponse else {
            let merchantErr = NSError(domain: "merchant-domain", code: 2, userInfo: [NSLocalizedDescriptionKey: "Oh no, something went wrong parsing the response..."])
            showError(withMessage: merchantErr.localizedDescription)
            return
        }
        
        let networking = Networking()
        networking.resumePayment(transactionResponse.id, withResumeToken: resumeToken) { (res, err) in
            self.stopLoading()
            
            if let err = err {
                self.showError(withMessage: err.localizedDescription)
                
            } else if let res = res {
                let data = try! JSONEncoder().encode(res)
                self.paymentResponsesData.append(data)
                let prvc = PaymentResultViewController.instantiate(data: self.paymentResponsesData)
                self.navigationController?.pushViewController(prvc, animated: true)
                
            } else {
                fatalError()
            }
        }
    }
    
    func primerHeadlessUniversalCheckoutUniversalCheckoutDidFail(withError err: Error) {
        self.stopLoading()
        self.showError(withMessage: err.localizedDescription)
    }
    
}
