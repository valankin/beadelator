//
//  ContentView.swift
//  Beadelator
//
//  Created by Yuri Valankin on 01.08.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CanvasList()
    }
}

#Preview {
    ContentView()
        .environment(CanvasGallery())
}
