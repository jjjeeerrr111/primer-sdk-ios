import UIKit
import AuthenticationServices

protocol CardFormViewControllerDelegate: AddPaymentMethodDelegate {
    var uxMode: UXMode { get }
    func showScanner(_ controller: UIViewController)
    func reload()
}

class CardFormViewController: UIViewController {
    
    private let bkgColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1)
    private let validation = Validation()
    private let cardFormView = CardFormView()
    private let spinner = UIActivityIndicatorView()
    private let delegate: CardFormViewControllerDelegate
    private let transitionDelegate = TransitionDelegate()
    
    init(delegate: CardFormViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = transitionDelegate
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var formViewTitle: String {
        get {
            switch delegate.uxMode {
            case .CHECKOUT:
                return "Checkout"
            case .VAULT:
                return "Add card"
            }
        }
    }
    
    public override func viewDidLoad() {
        view.backgroundColor = self.bkgColor
        configureMainView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureMainView() {
        view.addSubview(self.cardFormView)
        cardFormView.pin(to: self.view)
        cardFormView.title.text = formViewTitle
        addTargetsToForm()
        hideKeyboardWhenTappedAround()
    }
    
    private func addTargetsToForm() {
        cardFormView.cardTF.addTarget(self, action: #selector(onCardNumberTextFieldChanged), for: .editingChanged)
        cardFormView.expTF.addTarget(self, action: #selector(onExpiryTextFieldChanged), for: .editingChanged)
        cardFormView.submitButton.addTarget(self, action: #selector(onSubmitButtonPressed), for: .touchUpInside)
        cardFormView.scannerButton.addTarget(self, action: #selector(onScanButtonPressed), for: .touchUpInside)
    }

    @objc private func onExpiryTextFieldChanged(_ sender: UITextField) {
        guard let currentText = sender.text else  { return }
        let dateMask = Veil(pattern: "##/##")
        sender.text = dateMask.mask(input: currentText, exhaustive: false)
    }
    
    @objc private func onCardNumberTextFieldChanged(_ sender: UITextField) {
        guard let currentText = sender.text else  { return }
        let numberMask = Veil(pattern: "#### #### #### ####")
        sender.text = numberMask.mask(input: currentText, exhaustive: false)
    }
    
    @objc private func onSubmitButtonPressed() {
        
        if (formValuesAreNotValid) { return }
        
        guard let name = cardFormView.nameTF.text else { return }
        guard var number = cardFormView.cardTF.text else { return }
        number = number.filter { !$0.isWhitespace }
        guard let expiryValues = cardFormView.expTF.text?.split(separator: "/") else { return }
        let expMonth = "\(expiryValues[0])"
        let expYear = "20\(expiryValues[1])"
        guard let cvc = cardFormView.cvcTF.text else { return }
        
        self.cardFormView.submitButton.showSpinner()
        
        let instrument = PaymentInstrument(
            number: number,
            cvv: cvc,
            expirationMonth: expMonth,
            expirationYear: expYear,
            cardholderName: name
        )
        
        delegate.addPaymentMethod(
            instrument: instrument,
            completion: { error in DispatchQueue.main.async { self.showModal(error) } })
    }
    
    @objc private func onScanButtonPressed() {
        delegate.showScanner(self)
    }
    
    private var formValuesAreNotValid: Bool  {
        get {
            if (validation.nameFieldIsNotValid(cardFormView.nameTF)) {
                cardFormView.nameTF.textColor = .red
                return true
            } else {
                cardFormView.nameTF.textColor = .black
            }
            
            if (validation.cardFieldIsNotValid(cardFormView.cardTF)) {
                cardFormView.cardTF.textColor = .red
                return true
            } else {
                cardFormView.cardTF.textColor = .black
            }
            
            if (validation.expiryFieldIsNotValid(cardFormView.expTF)) {
                cardFormView.expTF.textColor = .red
                return true
            } else {
                cardFormView.expTF.textColor = .black
            }
            
            if (validation.CVCFieldIsNotValid(cardFormView.cvcTF)) {
                cardFormView.cvcTF.textColor = .red
                return true
            } else {
                cardFormView.cvcTF.textColor = .black
            }
            
            return false
        }
    }
}
