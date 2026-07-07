//
//  GameStructs.swift
//  brainwallet
//
//  Created by Kerry Washington on 7/3/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//


struct GameJSON: Codable {
    let socialNetwork: String
    let unixTimeStamp: Int?
    let totalScore: Int?
    let scoreA: Int?
    let scoreB: Int?
    let scoreC: Int?
    let bonusAmount: Int?
    
    enum CodingKeys: String, CodingKey {
        case socialNetwork = "social_network"
        case unixTimeStamp = "timestamp"
        case totalScore = "total_score"
        case bonusAmount = "bonus_amount"
        case scoreA = "score_a"
        case scoreB = "score_b"
        case scoreC = "score_c"
    }
}
