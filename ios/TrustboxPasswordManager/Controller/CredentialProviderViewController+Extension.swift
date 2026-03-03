//
//  CredentialProviderViewController+Extension.swift
//  TrustboxPasswordManager
//
//  Created by theonetech on 05/09/23.
//  Copyright © 2023 MyPass. All rights reserved.
//

import Foundation
import AuthenticationServices


extension CredentialProviderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrPassword.count == 0 {
                self.tableView.setEmptyMessage("No data available")
            } else {
                self.tableView.restore()
            }
        
        return arrPassword.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellFound = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as? PasswordListingTableViewCell {
            cellFound.configPasswordData(data: arrPassword[indexPath.row])
            return cellFound
        }
        return UITableViewCell()
    }
    
}

extension CredentialProviderViewController: UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = arrPassword[indexPath.row]
        let passwordCredential = ASPasswordCredential(user: data.user ?? "", password: data.pass ?? "")
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
    }
    
}
