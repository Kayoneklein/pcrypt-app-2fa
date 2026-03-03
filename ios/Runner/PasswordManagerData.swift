//
//  PasswordManagerData.swift
//  Runner
//
//  Created by theonetech on 11/09/23.
//  Copyright © 2023 MyPass. All rights reserved.
//

import UIKit


struct PasswordManagerData: Codable {
    let alarm: Int?
    let cre: Int?
    let files: [Files]?
    let gid: [GID]?
    let id: String?
    let name: String?
    let note: String?
    let pass: String?
    let pos: [POS]?
    let sharechanges: ShareCharges?
    let shares: Shares?
    let shareteams:[ShareTeams]?
    let upd: Int?
    let url: String?
    let urlpath: Bool?
    let user: String?
}

struct Files: Codable {
    
}

struct GID: Codable {
    
}

struct POS: Codable {
    
}

struct ShareTeams: Codable {
    
    
}

struct Shares: Codable {
    
}

struct ShareCharges: Codable {
    
}
