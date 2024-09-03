//
//  color.swift
//  Beadelator
//
//  Created by Yuri Valankin on 05.08.2024.
//

import Foundation
import SwiftUI



extension Color {
    /// Extracts RGB and opacity components from a `Color` object.
    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        // Using a color to extract components
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
}
    
