//
//  CanvasList.swift
//  Beadelator
//
//  Created by Yuri Valankin on 01.08.2024.
//

import SwiftUI

struct CanvasList: View {
    @Environment(CanvasGallery.self) var canvasGallery
    
    @State private var canvasID: CanvasItem.ID? = nil
    
    let imgSize: CGFloat = 30
    
    var body: some View {
        @Bindable var canvasGallery = canvasGallery
        
        NavigationSplitView {
            Divider()
            // Pass the binding for new canvas creation.
            CanvasCreate(selectedCanvasID: $canvasID)
            Divider()
            List(selection: $canvasID) {
                ForEach(Array(canvasGallery.canvases.enumerated()), id: \.element.id) { index, canvas in
                    NavigationLink(value: canvas.id) {
                        CanvasRow(canvas: canvas)
                    }
                    .tag(canvas.id)
                }
                .onDelete { indexSet in
                    canvasGallery.canvases.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Gallery")
        } detail: {
            if let canvasID = canvasID,
               let index = canvasGallery.canvases.firstIndex(where: { $0.id == canvasID }) {
                // Pass a binding to the selected canvas.
                CanvasDetail(canvas: $canvasGallery.canvases[index])
            } else {
                detailView()
            }
        }
    }
    
    func detailView() -> some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "s.square").foregroundColor(.cyan)
                Image(systemName: "e.circle").foregroundColor(.purple)
                Image(systemName: "l.square").foregroundColor(.cyan)
                Image(systemName: "e.circle").foregroundColor(.purple)
                Image(systemName: "c.square").foregroundColor(.cyan)
                Image(systemName: "t.circle").foregroundColor(.purple)
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Image(systemName: "c.circle").foregroundColor(.cyan)
                Image(systemName: "a.square").foregroundColor(.purple)
                Image(systemName: "n.circle").foregroundColor(.cyan)
                Image(systemName: "v.square").foregroundColor(.purple)
                Image(systemName: "a.circle").foregroundColor(.cyan)
                Image(systemName: "s.square").foregroundColor(.purple)
                Spacer()
            }
            Divider()
            Spacer()
            VStack {
                HStack {
                    Image(systemName: "heart.circle")
                        .frame(width: imgSize, height: imgSize)
                        .foregroundColor(.purple)
                    
                    Image(systemName: "heart.circle")
                        .frame(width: imgSize, height: imgSize)
                    
                    Image(systemName: "heart.circle")
                        .frame(width: imgSize, height: imgSize)
                        .foregroundColor(.purple)
                }
                HStack {
                    Image(systemName: "heart.circle")
                        .frame(width: imgSize, height: imgSize)
                    
                    Image(systemName: "heart.circle")
                        .frame(width: imgSize, height: imgSize)
                        .foregroundColor(.red)
                    
                    Image(systemName: "heart.circle")
                        .frame(width: imgSize, height: imgSize)
                }
                HStack {
                    Image(systemName: "heart.circle")
                        .frame(width: imgSize, height: imgSize)
                        .foregroundColor(.purple)
                    
                    Image(systemName: "heart.circle")
                        .frame(width: imgSize, height: imgSize)
                    
                    Image(systemName: "heart.circle")
                        .frame(width: imgSize, height: imgSize)
                        .foregroundColor(.purple)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    CanvasList()
        .environment(CanvasGallery())
}
