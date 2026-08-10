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
struct GameExitPayload: Decodable {
    let exitData: GameJSON          // existing struct, unchanged
    let events: [AnalyticsEventDTO]
    }

struct AnalyticsEventDTO: Decodable {
    let name: String
    let timestampMs: Int64
    let params: [String: JSONValue]
}

enum JSONValue: Decodable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let v = try? c.decode(Bool.self)   { self = .bool(v);   return }
        if let v = try? c.decode(Double.self) { self = .number(v); return }
        if let v = try? c.decode(String.self) { self = .string(v); return }
        if c.decodeNil()                      { self = .null;     return }
        self = .null
    }
    
    /// Firebase rejects nil param values — filter .null out before logging.
    var firebaseValue: Any? {
        switch self {
            case .string(let s): return s
            case .number(let d): return d
            case .bool(let b):   return b
            case .null:          return nil
        }
    }
}
