//
//  BeadelatorApp.swift
//  Beadelator
//
//  Created by Yuri Valankin on 24.07.2024.
//

import SwiftUI

// TODO:
// 1. Undo shape coloring
// 2. (+)Change background color
// 3. Hide unfilled shapes
// 4. Gallery navigation
// 5. PNG export
// 6. Draw as you drag
// 7. 

@main
struct BeadelatorApp: App {
    @State private var canvasGallery = CanvasGallery()
    var body: some Scene {
        WindowGroup {
            ContentView().environment(canvasGallery)
        }
    }
}
