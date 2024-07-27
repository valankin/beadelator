//
//  Models.swift
//  Beadelator
//
//  Created by Yuri Valankin on 24.07.2024.
//

//import Foundation
import SwiftUI

struct Ellipse: Identifiable {
    let id = UUID()
    var center: CGPoint
    var radius: CGSize
    var isSelected: Bool = false
    var color: Color
}


// Structure to represent a saved canvas
struct CanvasItem: Identifiable {
    let id = UUID()
    var ellipses: [Ellipse]
    var title: String
}


extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
    }
}

extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }
}
