import UIKit

protocol VaultCheckoutViewDelegate: class, UITableViewDelegate, UITableViewDataSource {
    func cancel()
    func openVault()
    func pay()
    func selectTokenForPayment(token: PaymentMethodToken)
}

protocol VaultCheckoutViewDataSource: class {
    var selectedSavedPaymentMethod: PaymentMethodToken? { get }
    var amount: String? { get }
}

class VaultCheckoutView: UIView, ReactiveView {
    let indicator = UIActivityIndicatorView()
    let navBar = UINavigationBar()
    let amountLabelView = UILabel()
    let savedCardTitleLabel = UILabel()
    var savedCardButton = CardButton()
    let otherMethodsTitleLabel = UILabel()
    let tableView = UITableView()
    let payButton = UIButton()
    let seeAllLinkLabel = UILabel()
    let fadeView = UIView()
    
    var selected = false
    
    let vaulted: Bool = Primer.flow.vaulted
    
    weak var delegate: VaultCheckoutViewDelegate?
    weak var dataSource: VaultCheckoutViewDataSource?
    
    weak var heightConstraint: NSLayoutConstraint?
    weak var topConstraint: NSLayoutConstraint?
    
    func render(isBusy: Bool = false) {
        addSubview(indicator)
        addSubview(navBar)
        addSubview(amountLabelView)
        addSubview(savedCardTitleLabel)
        addSubview(savedCardButton)
        addSubview(otherMethodsTitleLabel)
        addSubview(tableView)
        addSubview(seeAllLinkLabel)
        addSubview(fadeView)
        addSubview(payButton)
        
        subviews.forEach { $0.isHidden = isBusy }
        indicator.isHidden = !isBusy
        
        if (isBusy) {
            indicator.pin(to: self)
            indicator.startAnimating()
        } else {
            configureNavBar()
            configureTableView()
            configurePayButton()
            configureAmountLabelView()
            configureSavedCardTitleLabel()
            configureSavedCardButton()
            configureSeeAllLinkLabel()
            configureOtherMethodsTitleLabel()
            
            anchorNavBar()
            anchorTableView()
            anchorPayButton()
            indicator.stopAnimating()
        }
    }
    
    func reloadVaultDetails() {
        if (vaulted) {
            configureSavedCardButton()
            payButton.isHidden = true
            savedCardButton.layoutIfNeeded()
        }
    }
}

//MARK: Configuration
extension VaultCheckoutView {
    private func configureNavBar() {
        //        guard let theme = delegate?.theme else { return }
        //        navBar.backgroundColor = theme.backgroundColor
        let navItem = UINavigationItem()
        //        let doneItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancel))
        //        navItem.leftBarButtonItem = doneItem
        navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBar.shadowImage = UIImage()
        navBar.setItems([navItem], animated: false)
        navBar.topItem?.title = "Choose payment method".localized()
    }
    
    @objc private func cancel() {
        delegate?.cancel()
    }
    
    private func configureAmountLabelView() {
        amountLabelView.text = dataSource?.amount
        amountLabelView.font = .boldSystemFont(ofSize: 32)
        amountLabelView.translatesAutoresizingMaskIntoConstraints = false
        amountLabelView.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 6).isActive = true
        amountLabelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Primer.theme.layout.safeMargin).isActive = true
    }
    
    private func configureSavedCardTitleLabel() {
        if (vaulted) {
            savedCardTitleLabel.text = "SAVED CARD".localized()
            savedCardTitleLabel.textColor = Primer.theme.colorTheme.disabled1
            savedCardTitleLabel.font = .systemFont(ofSize: 12, weight: .light)
        }
        savedCardTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        savedCardTitleLabel.topAnchor.constraint(equalTo: amountLabelView.bottomAnchor, constant: 12).isActive = true
        savedCardTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Primer.theme.layout.safeMargin).isActive = true
    }
    
    private func configureSavedCardButton() {
        savedCardButton.translatesAutoresizingMaskIntoConstraints = false
        savedCardButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Primer.theme.layout.safeMargin).isActive = true
        savedCardButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Primer.theme.layout.safeMargin).isActive = true
        
        if let buttonViewModel = dataSource?.selectedSavedPaymentMethod?.cardButtonViewModel {
            if (vaulted) {
                topConstraint = savedCardButton.topAnchor.constraint(equalTo: savedCardTitleLabel.bottomAnchor, constant: 12)
                heightConstraint = savedCardButton.heightAnchor.constraint(equalToConstant: 64)
                savedCardButton.addTarget(self, action: #selector(toggleSavedCardSelected), for: .touchUpInside)
                savedCardButton.render(model: buttonViewModel)
            } else {
                topConstraint = savedCardButton.topAnchor.constraint(equalTo: savedCardTitleLabel.bottomAnchor, constant: 0)
                heightConstraint = savedCardButton.heightAnchor.constraint(equalToConstant: 0)
            }
        } else {
            topConstraint = savedCardButton.topAnchor.constraint(equalTo: savedCardTitleLabel.bottomAnchor, constant: 0)
            heightConstraint = savedCardButton.heightAnchor.constraint(equalToConstant: 0)
        }
        
        heightConstraint?.isActive = true
        topConstraint?.isActive = true
    }
    
    @objc private func toggleSavedCardSelected() {
        UIView.animate(withDuration: 0.25, animations: {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.selected = !strongSelf.selected
            strongSelf.addFadeView(isEnabled: strongSelf.selected)
            strongSelf.payButton.isHidden = !strongSelf.selected
            strongSelf.savedCardButton.toggleBorder(isSelected: strongSelf.selected)
            //            strongSelf.savedCardButton.toggleIcon(isEnabled: !strongSelf.selected)
            strongSelf.layoutIfNeeded()
        })
    }
    
    private func addFadeView(isEnabled: Bool) {
        let val: CGFloat = isEnabled ? 0.5 : 0.0
        fadeView.backgroundColor = Primer.theme.colorTheme.main1.withAlphaComponent(val)
        fadeView.isUserInteractionEnabled = isEnabled
        fadeView.translatesAutoresizingMaskIntoConstraints = false
        fadeView.topAnchor.constraint(equalTo: savedCardButton.bottomAnchor).isActive = true
        fadeView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        fadeView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        fadeView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func configureSeeAllLinkLabel() {
        seeAllLinkLabel.translatesAutoresizingMaskIntoConstraints = false
        seeAllLinkLabel.text = vaulted ? "See All".localized() : ""
        seeAllLinkLabel.font = .systemFont(ofSize: 14)
        seeAllLinkLabel.textColor = Primer.theme.colorTheme.text3
        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(openVault))
        seeAllLinkLabel.addGestureRecognizer(tapRecogniser)
        seeAllLinkLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        seeAllLinkLabel.topAnchor.constraint(equalTo: savedCardButton.bottomAnchor, constant: vaulted ? 12 : 0).isActive = true
        seeAllLinkLabel.isUserInteractionEnabled = true
    }
    
    @objc private func openVault() {
        delegate?.openVault()
    }
    
    private func configureOtherMethodsTitleLabel() {
        otherMethodsTitleLabel.text = vaulted ? "OTHER WAYS TO PAY".localized() : ""
        otherMethodsTitleLabel.textColor = Primer.theme.colorTheme.disabled1
        otherMethodsTitleLabel.font = .systemFont(ofSize: 12, weight: .light)
        otherMethodsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        otherMethodsTitleLabel.topAnchor.constraint(equalTo: seeAllLinkLabel.bottomAnchor, constant: vaulted ? 24 : 0).isActive = true
        otherMethodsTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Primer.theme.layout.safeMargin).isActive = true
    }
    
    private func configureTableView() {
        tableView.delegate = delegate
        tableView.dataSource = delegate
        tableView.layer.cornerRadius = 8.0
        tableView.backgroundColor = Primer.theme.colorTheme.main1
        tableView.rowHeight = 46
        tableView.tableFooterView = UIView()
        tableView.alwaysBounceVertical = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell3")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell4")
    }
    
    func configurePayButton() {
        payButton.layer.cornerRadius = 12
        payButton.setTitle(Primer.theme.content.vaultCheckout.payButtonText, for: .normal)
        payButton.setTitleColor(Primer.theme.colorTheme.text2, for: .normal)
        payButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        payButton.backgroundColor = Primer.theme.colorTheme.tint1
        payButton.addTarget(self, action: #selector(onTap), for: .touchUpInside)
        let imageView = UIImageView(image: ImageName.lock.image)
        payButton.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerYAnchor.constraint(equalTo: payButton.centerYAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: payButton.trailingAnchor, constant: -16).isActive = true
        payButton.isHidden = true //before it's toggled, hide
    }
    
    @objc private func onTap(sender: UIButton) {
        payButton.isEnabled = false
        print("paying!")
        payButton.showSpinner()
        delegate?.pay()
    }
}

//MARK: Anchoring
extension VaultCheckoutView {
    private func anchorNavBar() {
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        navBar.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    private func anchorTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: otherMethodsTitleLabel.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Primer.theme.layout.safeMargin).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Primer.theme.layout.safeMargin).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 400).isActive = true
    }
    
    private func anchorPayButton() {
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        payButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        payButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Primer.theme.layout.safeMargin).isActive = true
        payButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Primer.theme.layout.safeMargin).isActive = true
        payButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
