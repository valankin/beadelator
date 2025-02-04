//
//  BeadelatorApp.swift
//  Beadelator
//
//  Created by Yuri Valankin on 24.07.2024.
//

import SwiftUI

// TODO:
// none

@main
struct BeadelatorApp: App {
    @State private var canvasGallery = CanvasGallery()
    var body: some Scene {
        WindowGroup {
            ContentView().environment(canvasGallery)
        }
    }
}
