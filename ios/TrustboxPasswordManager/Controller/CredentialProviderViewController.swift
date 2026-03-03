//
//  CredentialProviderViewController.swift
//  TrustboxPasswordManager
//
//  Created by theonetech on 04/09/23.
//  Copyright © 2023 MyPass. All rights reserved.
//

import AuthenticationServices

class CredentialProviderViewController: ASCredentialProviderViewController {

    @IBOutlet weak var tableView: UITableView!

    var arrPassword = [PasswordManagerData]()
    var arrMainPassword = [PasswordManagerData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 150
        registerTableViewCells()
        
        let defaults = UserDefaults(suiteName: "group.com.pcryptApp")
        if let data = defaults?.data(forKey: "passwordData") {
            do {
                let decoder = JSONDecoder()
                let password = try decoder.decode([PasswordManagerData].self, from: data)
                arrPassword = password
                arrMainPassword = password
                debugPrint(arrPassword)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                arrPassword = []
                arrMainPassword = []
                print("Unable to Decode Notes (\(error))")
            }
        } else {
            arrPassword = []
            arrMainPassword = []
        }
    }
    
    private func registerTableViewCells() {
        let cell = UINib(nibName: "PasswordListingTableViewCell", bundle: nil)
        self.tableView.register(cell, forCellReuseIdentifier: "CustomTableViewCell")
    }
    
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        if let identifier = serviceIdentifiers.first?.identifier as? String {
            if let url = URL(string: identifier) {
                let domain = url.host
                arrPassword = arrPassword.filter { $0.url?.contains(domain ?? "") ?? false }
                if arrPassword.count == 0 {
                    arrPassword = arrMainPassword
                }
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func cancel(_ sender: AnyObject?) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }
}
extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
