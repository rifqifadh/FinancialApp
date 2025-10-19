//
//  UserResponse.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//


//
//  UserResponse.swift
//  ExpenseTracker
//
//  Created by Rifqi on 20/07/25.
//

import Foundation

struct UserResponse: Codable, Equatable {
    let id: String
    let email: String?
    let fullname: String?
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullname = "full_name"
        case avatarUrl = "avatar_url"
    }
}

