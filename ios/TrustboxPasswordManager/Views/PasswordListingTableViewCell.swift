//
//  PasswordListingTableViewCell.swift
//  TrustboxPasswordManager
//
//  Created by theonetech on 05/09/23.
//  Copyright © 2023 MyPass. All rights reserved.
//

import UIKit

class PasswordListingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelPassordName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func configPasswordData(data: PasswordManagerData) {
        labelPassordName.text = data.name
    }
    
}
