//
//  PunchDirection.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/14.
//

import SwiftUI

enum PunchDirection: Codable, Equatable {
    case up(strength: Double)
    case down(strength: Double)
    case left(strength: Double)
    case right(strength: Double)
    
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case type
        case strength
    }
    
    enum DirectionType: String, Codable {
        case up, down, left, right
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .up(let strength):
            try container.encode(DirectionType.up, forKey: .type)
            try container.encode(strength, forKey: .strength)
        case .down(let strength):
            try container.encode(DirectionType.down, forKey: .type)
            try container.encode(strength, forKey: .strength)
        case .left(let strength):
            try container.encode(DirectionType.left, forKey: .type)
            try container.encode(strength, forKey: .strength)
        case .right(let strength):
            try container.encode(DirectionType.right, forKey: .type)
            try container.encode(strength, forKey: .strength)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(DirectionType.self, forKey: .type)
        let strength = try container.decode(Double.self, forKey: .strength)
        
        switch type {
        case .up:
            self = .up(strength: strength)
        case .down:
            self = .down(strength: strength)
        case .left:
            self = .left(strength: strength)
        case .right:
            self = .right(strength: strength)
        }
    }
    
    var degree: Double {
        switch self {
        case .up:
                0
        case .down:
                180
        case .left:
                -90
        case .right:
                90
        }
    }
    
    var overlayPlacement: Alignment {
        switch self {
        case .up:
                .top
        case .down:
                .bottom
        case .left:
                .leading
        case .right:
                .trailing
        }
    }
    
    var strength: Double {
        switch self {
        case .up(let s), .down(let s), .left(let s), .right(let s):
            return s
        }
    }
}
