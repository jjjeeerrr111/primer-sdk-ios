//
//  PaymentResultViewController.swift
//  HeadlessUniversalCheckoutExample
//
//  Created by Evangelos on 22/2/22.
//

import UIKit

class PaymentResultViewController: UIViewController {
    
    static func instantiate(data: [Data]) -> PaymentResultViewController {
        let rvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentResultViewController") as! PaymentResultViewController
        rvc.data = data
        return rvc
    }
    
    var data: [Data]!
    
    @IBOutlet weak var responseStatus: UILabel!
    @IBOutlet weak var requiredActionsLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var responseTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paymentResponses = data.compactMap({ try? JSONDecoder().decode(Payment.Response.self, from: $0) }).sorted(by: { $0.dateStr ?? "" < $1.dateStr ?? "" })
        responseStatus.text = paymentResponses.last?.status.rawValue
        responseStatus.font = .systemFont(ofSize: 17, weight: .medium)
        switch paymentResponses.last?.status {
        case .declined,
                .failed:
            responseStatus.textColor = .red
        case .authorized,
                .settled:
            responseStatus.textColor = .green
        case .pending:
            responseStatus.textColor = .orange
        case .none:
            break
        }
        
        var requiredActionsNames = ""
        requiredActionsNames = paymentResponses.filter({ $0.requiredAction != nil }).compactMap({ $0.requiredAction!.name }).joined(separator: ", ").uppercased().folding(options: .diacriticInsensitive, locale: .current)
        requiredActionsLabel.text = requiredActionsNames
        
        var responsesStr = ""
        for paymentResponseData in data {
            responsesStr += (paymentResponseData.prettyPrintedJSONString as String? ?? "") + "\n\n----\n\n"
        }

        let responseAttrStr = NSMutableAttributedString(string: responsesStr, attributes: nil)
        
        let settledRanges = responsesStr.allRanges(of: Payment.Response.Status.settled.rawValue).compactMap({ $0.toNSRange(in: responsesStr) })
        settledRanges.forEach({ responseAttrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGreen, range: $0) })
        settledRanges.forEach({ responseAttrStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: $0) })
        
        let authorizedRanges = responsesStr.allRanges(of: Payment.Response.Status.authorized.rawValue).compactMap({ $0.toNSRange(in: responsesStr) })
        authorizedRanges.forEach({ responseAttrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGreen, range: $0) })
        authorizedRanges.forEach({ responseAttrStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: $0) })
        
        let declinedRanges = responsesStr.allRanges(of: Payment.Response.Status.declined.rawValue).compactMap({ $0.toNSRange(in: responsesStr) })
        declinedRanges.forEach({ responseAttrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemRed, range: $0) })
        declinedRanges.forEach({ responseAttrStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: $0) })
        
        let failedRanges = responsesStr.allRanges(of: Payment.Response.Status.failed.rawValue).compactMap({ $0.toNSRange(in: responsesStr) })
        failedRanges.forEach({ responseAttrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemRed, range: $0) })
        failedRanges.forEach({ responseAttrStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: $0) })
        
        let pendingRanges = responsesStr.allRanges(of: Payment.Response.Status.pending.rawValue).compactMap({ $0.toNSRange(in: responsesStr) })
        pendingRanges.forEach({ responseAttrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemOrange, range: $0) })
        pendingRanges.forEach({ responseAttrStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: $0) })
        
        if let amount = paymentResponses.last?.amount, let currencyCode = paymentResponses.last?.currencyCode {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = .currency
            currencyFormatter.currencySymbol = ""

            let amountDbl = Double(amount) / 100
            let amountStr = currencyFormatter.string(from: NSNumber(value: amountDbl))!
            
            amountLabel.text = "\(currencyCode) \(amountStr)"
            
            let amountRanges = responsesStr.allRanges(of: String(amount)).compactMap({ $0.toNSRange(in: responsesStr) })
            amountRanges.forEach({ responseAttrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemBlue, range: $0) })
            amountRanges.forEach({ responseAttrStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: $0) })
        }
        
        
        responseTextView.attributedText = responseAttrStr
    }
    
}
