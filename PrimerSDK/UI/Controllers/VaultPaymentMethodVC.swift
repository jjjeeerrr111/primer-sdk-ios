import UIKit

protocol ReloadDelegate {
    func reload()
}

class VaultPaymentMethodVC: UIViewController {
    
    private let fieldColor = UIColor(red: 254.0/255.0, green: 254.0/255.0, blue: 254.0/255.0, alpha: 1)
    
    private var checkout: UniversalCheckoutProtocol
    
    private let tableView = UITableView()
    private let backButton = UIButton()
    private let mainTitle = UILabel()
    private let editButton = UIButton()
    private let addButton = UIButton()
    
    private var showDeleteIcon = false
    
    var reloadDelegate: ReloadDelegate?
    
    init(_ checkout: UniversalCheckoutProtocol) {
        self.checkout = checkout
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = fieldColor
        
        view.addSubview(tableView)
        view.addSubview(backButton)
        view.addSubview(mainTitle)
        view.addSubview(editButton)
        view.addSubview(addButton)
        
        configureTableView()
        
        configureBackButton()
        configureMainTitle()
        configureEditButton()
        configureAddButton()
        setBackButtonContraints()
        setMainTitleConstraints()
        setEditButtonConstraints()
        setAddButtonConstraints()
    }
    
    deinit {
        if let reloadDelegate = reloadDelegate {
            reloadDelegate.reload()
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.rowHeight = 64
        tableView.tableFooterView = UIView()
        //        tableView.alwaysBounceVertical = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell5")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: mainTitle.bottomAnchor, constant: 12).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 12).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12).isActive = true
//        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -48).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 64 * 3).isActive = true
    }
    
    private func configureBackButton() {
        if #available(iOS 13.0, *) {
            backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        backButton.backgroundColor = .white
        backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
    }
    
    @objc private func dismissView() {
        dismiss(animated: true, completion: {
            self.checkout.loadPaymentMethods({
                result in
                DispatchQueue.main.async {
                    self.reloadDelegate?.reload()
                }
            })
        })
    }
    
    private func configureMainTitle() {
        mainTitle.text = "Other ways to pay"
    }
    
    private func configureEditButton() {
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(.systemBlue, for: .normal)
        editButton.setTitleColor(.black, for: .highlighted)
        editButton.contentHorizontalAlignment = .right
        editButton.backgroundColor = .white
        
        editButton.addTarget(self, action: #selector(editPaymentMethods), for: .touchUpInside)
    }
    
    @objc private func editPaymentMethods() {
        showDeleteIcon = !showDeleteIcon
        tableView.reloadData()
    }
    
    private func configureAddButton() {
        addButton.setTitle("Add new card", for: .normal)
        addButton.setTitleColor(.systemBlue, for: .normal)
        addButton.setTitleColor(.black, for: .highlighted)
        addButton.contentHorizontalAlignment = .left
        addButton.addTarget(self, action: #selector(addPaymentMethod), for: .touchUpInside)
    }
    
    @objc private func addPaymentMethod() {
        checkout.showCardForm(self, delegate: self)
    }
    
    private func setBackButtonContraints() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 24).isActive = true
        backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        //        backButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        //        backButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12).isActive = true
        //        backButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    private func setMainTitleConstraints() {
        mainTitle.translatesAutoresizingMaskIntoConstraints = false
        mainTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 24).isActive = true
        mainTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        mainTitle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    private func setEditButtonConstraints() {
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 24).isActive = true
        editButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        editButton.widthAnchor.constraint(equalToConstant: editButton.intrinsicContentSize.width).isActive = true
    }
    
    private func setAddButtonConstraints() {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 12).isActive = true
        addButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18).isActive = true
//        addButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: addButton.intrinsicContentSize.width).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: addButton.intrinsicContentSize.height).isActive = true
    }
}

extension VaultPaymentMethodVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkout.paymentMethodVMs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell5")
        cell.textLabel?.text = "**** **** **** \(checkout.paymentMethodVMs[indexPath.row].last4)"
        
        if (showDeleteIcon) {
            cell.accessoryType = .none
            let deleteButton = UIButton(type: .system)
            if #available(iOS 13.0, *) {
                let icon = UIImage(systemName: "minus.circle.fill")
                deleteButton.setImage(icon, for: .normal)
            } else {
//                let icon = UIImage(minus_icon, .normal)
//                deleteButton.setImage(icon, for: .normal)
            }
            
            deleteButton.tintColor = .red
            deleteButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            
            deleteButton.tag = indexPath.row
            
            deleteButton.addTarget(self, action: #selector(deleteMethod), for: .touchUpInside)
            
            cell.accessoryView = deleteButton
        } else {
            cell.accessoryType = checkout.selectedPaymentMethod == checkout.paymentMethodVMs[indexPath.row].id ? .checkmark : .none
        }
        
        cell.separatorInset = .zero
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (!showDeleteIcon) {
            
            checkout.selectedPaymentMethod = checkout.paymentMethodVMs[indexPath.row].id
            
            tableView.reloadData()
        }
    }
    
    @objc private func deleteMethod(sender: UIButton) {
        let methodId = checkout.paymentMethodVMs[sender.tag].id
        print("delete method:", sender.tag, methodId)
        checkout.deletePaymentMethod(id: methodId, {
            error in
            self.checkout.loadPaymentMethods({
                result in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
            
        })
    }
}

extension VaultPaymentMethodVC: ReloadDelegate {
    func reload() {
        self.checkout.loadPaymentMethods({
            result in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
}
