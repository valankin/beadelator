//
//  Ellipse.swift
//  Beadelator
//
//  Created by Yuri Valankin on 01.08.2024.
//

import Foundation
import SwiftUI


struct Ellipse: Identifiable {
    var id = UUID()
    var center: CGPoint
    var radius: CGSize
    var isSelected: Bool = false
    var color: Color
    
//    enum CodingKeys: String, CodingKey {
//        case id, center, radius, isSelected, color
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(["x": center.x, "y": center.y], forKey: .center)
//        try container.encode(["width": radius.width, "height": radius.height], forKey: .radius)
//        try container.encode(isSelected, forKey: .isSelected)
//        let colorComponents = color.components
//        try container.encode(["red": colorComponents.red, "green": colorComponents.green, "blue": colorComponents.blue, "opacity": colorComponents.opacity], forKey: .color)
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(UUID.self, forKey: .id)
//        
//        let centerDictionary = try container.decode([String: CGFloat].self, forKey: .center)
//        center = CGPoint(x: centerDictionary["x"] ?? 0, y: centerDictionary["y"] ?? 0)
//        
//        let radiusDictionary = try container.decode([String: CGFloat].self, forKey: .radius)
//        radius = CGSize(width: radiusDictionary["width"] ?? 0, height: radiusDictionary["height"] ?? 0)
//        
//        isSelected = try container.decode(Bool.self, forKey: .isSelected)
//        
//        let colorDictionary = try container.decode([String: Double].self, forKey: .color)
//        color = Color(
//            red: colorDictionary["red"] ?? 0,
//            green: colorDictionary["green"] ?? 0,
//            blue: colorDictionary["blue"] ?? 0,
//            opacity: colorDictionary["opacity"] ?? 1.0
//        )
//    }
}
    

/// Calculate ellipse's center based on initial point and it's posotion in the grid
/// offset - starting point to count from
/// shift - shift factor
/// row - row number
/// column - column number
/// Note: row and column could fit 2 ellipses
func getEllipseCenter(offset: CGPoint, shift: Int, row: Int, column: Int) -> CGPoint {
    let center = CGPoint(
        x: offset.y + CGFloat(shift * column),
        y: offset.x + CGFloat(shift * row)
    )
    return center
}


/// Finds nearest ellipse to the touch location
/// /// O(n) search based on Eucledian distance
func findNearestElipse(ellipses: [Ellipse], touchLocation: CGPoint) -> Ellipse? {
    let nearestEllipse = ellipses.min(by: {
        $0.center.distance(to: touchLocation) < $1.center.distance(to: touchLocation)
    })
    
    return nearestEllipse
}


/// Finds ellipse's index in the array
/// O(n) ellipse index search
func getEllipseIndex(ellipses: [Ellipse], ellipse: Ellipse) -> Int?{
    return ellipses.firstIndex(
        where: { $0.id == ellipse.id })
}
