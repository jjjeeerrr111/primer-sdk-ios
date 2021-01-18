import UIKit

extension VaultPaymentMethodViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.paymentMethods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = PaymentMethodTableViewCell(
            style: .default,
            reuseIdentifier: "paymentMethodCell",
            index: indexPath.row,
            paymentMethods: viewModel.paymentMethods,
            isSelected: viewModel.selectedId == viewModel.paymentMethods[indexPath.row].token,
            showDeleteIcon: showDeleteIcon
        )
        
        cell.deleteButton.addTarget(self, action: #selector(deleteMethod), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (!showDeleteIcon) {
            viewModel.selectedId = viewModel.paymentMethods[indexPath.row].token ?? ""
            tableView.reloadData()
        }
    }
    
    @objc private func deleteMethod(sender: UIButton) {
        guard let methodId = viewModel.paymentMethods[sender.tag].token else { return }
        viewModel.deletePaymentMethod(with: methodId, and: { [weak self] error in
            DispatchQueue.main.async { self?.subView?.tableView.reloadData() }
        })
    }
}

class PaymentMethodTableViewCell: UITableViewCell {
    
    var deleteButton = UIButton(type: .system)
    private let paymentMethod: PaymentMethodToken
    
    init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?,
        index: Int,
        paymentMethods: [PaymentMethodToken],
        isSelected: Bool,
        showDeleteIcon: Bool
    ) {
        self.paymentMethod = paymentMethods[index]
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel?.text = paymentMethod.description
        
        if (showDeleteIcon) {
            accessoryType = .none
            if #available(iOS 13.0, *) {
                deleteButton.setImage(ImageName.delete.image, for: .normal)
            } else {
                deleteButton.setImage(ImageName.delete.image, for: .normal)
            }
            deleteButton.tintColor = .red
            deleteButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            deleteButton.tag = index
            
            accessoryView = deleteButton
        } else {
            accessoryType = isSelected ? .checkmark : .none
        }
        
        separatorInset = .zero
        
        if (index == paymentMethods.count - 1) {
            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
