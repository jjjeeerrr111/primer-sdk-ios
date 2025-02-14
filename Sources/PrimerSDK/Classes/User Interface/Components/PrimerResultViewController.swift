//
//  PrimerResultViewController.swift
//  PrimerSDK
//
//  Created by Evangelos on 3/2/22.
//

#if canImport(UIKit)

import UIKit

internal class PrimerResultViewController: PrimerViewController {
    
    internal enum ScreenType {
        case success, failure
    }

    private(set) internal var message: String?
    private(set) internal var screenType: ScreenType
    private(set) internal var resultView: PrimerResultComponentView!

    init(screenType: PrimerResultViewController.ScreenType, message: String?) {
        self.message = message
        self.screenType = screenType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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
                place: .errorScreen))
        Analytics.Service.record(event: viewEvent)

        (parent as? PrimerContainerViewController)?.navigationItem.hidesBackButton = true

        let img = (screenType == .success) ? UIImage(named: "check-circle", in: Bundle.primerResources, compatibleWith: nil) : UIImage(named: "x-circle", in: Bundle.primerResources, compatibleWith: nil)
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = .black
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        imgView.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        
        if screenType == .success {
            self.message = Primer.shared.flow.internalSessionFlow.vaulted ?
            NSLocalizedString("primer-success-screen-vault-setup-success",
                              tableName: nil,
                              bundle: Bundle.primerResources,
                              value: "A new payment method\nhas been successfully added!",
                              comment: "A new payment method\nhas been successfully added! - Success Screen Message")
            : NSLocalizedString("primer-success-screen-setup-success",
                                tableName: nil,
                                bundle: Bundle.primerResources,
                                value: "Success!",
                                comment: "Success! - Success Screen Title")
            
        }
        
        resultView = PrimerResultComponentView(frame: .zero, imageView: imgView, message: message, loadingIndicator: nil)
        view.addSubview(resultView)
        resultView.translatesAutoresizingMaskIntoConstraints = false
        resultView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).isActive = true
        resultView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        resultView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).isActive = true
        resultView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (parent as? PrimerContainerViewController)?.navigationItem.hidesBackButton = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (parent as? PrimerContainerViewController)?.navigationItem.hidesBackButton = true
    }

}

#endif
