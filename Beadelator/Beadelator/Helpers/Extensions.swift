//
//  Extensions.swift
//  Beadelator
//
//  Created by Игорь Рыкин on 03.02.2025.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
