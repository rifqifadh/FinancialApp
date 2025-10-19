//
//  ChatMessageResponse.swift
//  FinancialApp
//
//  Created by Rifqi on 19/10/25.
//


//
//  ChatResponse.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 18/07/25.
//

import Foundation

struct MessageResponse: Codable {
	let id: String?
	let userId: String
	let createdAt: Date?
	let content: String
	let imageUrl: String?
    let role: String
    let channelId: String
    let name: String?
	
	enum CodingKeys: String, CodingKey {
		case id
		case userId = "user_id"
		case createdAt = "created_at"
		case content
		case imageUrl = "image_url"
        case role
        case channelId = "channel_id"
        case name
	}
}
