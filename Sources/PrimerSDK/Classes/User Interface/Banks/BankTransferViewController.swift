//
//  BankTransferViewController.swift
//  PrimerSDK
//
//  Created by Evangelos on 20/12/21.
//

#if canImport(UIKit)

import UIKit

internal class BankTransferViewController: PrimerFormViewController {
    
    let theme: PrimerThemeProtocol = DependencyContainer.resolve()
    
    private var viewModel: BankTransferTokenizationViewModel!
    internal private(set) var subtitle: String?
    
    deinit {
        log(logLevel: .debug, message: "🧨 deinit: \(self) \(Unmanaged.passUnretained(self).toOpaque())")
    }
    
    init(viewModel: BankTransferTokenizationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = viewModel.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = theme.view.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        verticalStackView.spacing = 16
        verticalStackView.addArrangedSubview(viewModel.accountHolderNameContainerView)
        verticalStackView.addArrangedSubview(viewModel.ibanContainerView)
        let separator = PrimerView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        verticalStackView.addArrangedSubview(separator)
        verticalStackView.addArrangedSubview(viewModel.submitButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let amountString = viewModel.amountString {
            let rightBarButton = UIButton()
            rightBarButton.setTitle(amountString, for: .normal)
            rightBarButton.setTitleColor(theme.text.title.color, for: .normal)
            (parent as? PrimerContainerViewController)?.mockedNavigationBar.rightBarButton = rightBarButton
        }
    }
    
}

#endif

