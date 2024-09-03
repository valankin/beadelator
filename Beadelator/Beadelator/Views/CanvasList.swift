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
//            CanvasCreate()
//            List(canvasGallery.canvases, selection: $canvasID) {
//                canvas in
//                NavigationLink(canvas.title, value: canvas.id)
//            }
            
            Divider()
            CanvasCreate()
            Divider()
            List(selection: $canvasID) {
                ForEach(canvasGallery.canvases) { canvas in
                    NavigationLink {
                        CanvasDetail(canvas: canvas)
                    } label :{
                        CanvasRow(canvas: canvas)
                    }
                }.onDelete { indexSet in
                    canvasGallery.canvases.remove(atOffsets: indexSet)
                }
                
            }.navigationTitle("Gallery").on
        } detail: {
                
            if let canvasID {
                if let item = canvasGallery.byID(id: canvasID) {
                    CanvasDetail(canvas: item)
                }
            } else {
                detailView()
            }
                
            
        }
    }
    
    func detailView() -> some View {
        return VStack {
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

