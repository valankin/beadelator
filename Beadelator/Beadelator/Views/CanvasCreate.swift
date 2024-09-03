//
//  CanvasCreate.swift
//  Beadelator
//
//  Created by Yuri Valankin on 07.08.2024.
//

import SwiftUI
import Combine


@Observable
class TextValidator {
    var text = ""
}

struct CanvasCreate: View {
    
    @Environment(CanvasGallery.self) var canvasGallery

    @State var textValidator = TextValidator()
    
    @State private var errorMessage: String? = nil
    @State private var newCanvasName: String = ""


    var body: some View {
        HStack {
            Button {
                createNewCanvas()
            } label: {
                Image(systemName: "doc.badge.plus")
            
            }
            .disabled(textValidator.text.isEmpty)
            .padding()
            
            if let errorMessage = errorMessage {
            Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            TextField("Canvas name", text: $textValidator.text)
                .padding(.horizontal, 20.0)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onReceive(Just(textValidator.text)) { newValue in
                    let value = newValue.replacingOccurrences(
                        of: "\\W", with: "", options: .regularExpression)
                    
                    if value != newValue {
                        self.textValidator.text = value
                    }
                }
        }
    }
    func createNewCanvas() {
        
        if textValidator.text.isEmpty {
            errorMessage = "Cannot be empty!"
            return
        }
        
        if canvasGallery.canvases.first(where: {$0.title == textValidator.text}) != nil  {
            errorMessage = "Canvas exists!"
            
        } else {
            let newCanvas = CanvasItem(
                id: UUID(),
                title: textValidator.text,
                ellipses: [],
                n_cells_width: 30,
                n_cells_height: 60)
            
            canvasGallery.canvases.append(newCanvas)
            
            textValidator.text = ""
            errorMessage = nil
        }
    }
}

#Preview {
    CanvasCreate()
        .environment(CanvasGallery())
}
