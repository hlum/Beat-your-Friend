//
//  PunchDirection.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/14.
//

import SwiftUI

enum PunchDirection {
    case up(strength: Double)
    case down(strength: Double)
    case left(strength: Double)
    case right(strength: Double)
    
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
