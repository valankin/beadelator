//
//  CanvasRow.swift
//  Beadelator
//
//  Created by Yuri Valankin on 01.08.2024.
//

import SwiftUI




struct CanvasRow: View {
    var canvas: CanvasItem
    var body: some View {
        HStack {
            Image(systemName: "circle.hexagongrid.circle")
            Text(canvas.title)
        }
    }
}



#Preview {
    let canvases = CanvasGallery().canvases
    return Group {
        CanvasRow(canvas: canvases[0])
        CanvasRow(canvas: canvases[1])
    }
}
