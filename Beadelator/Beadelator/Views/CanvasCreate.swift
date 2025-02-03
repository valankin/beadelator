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
    /// Binding to update the selected canvas ID in the master view.
    @Binding var selectedCanvasID: UUID?
    
    @State var textValidator = TextValidator()
    @State private var errorMessage: String? = nil

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
                    // Allow only word characters (remove non-word characters)
                    let value = newValue.replacingOccurrences(
                        of: "\\W",
                        with: "",
                        options: .regularExpression
                    )
                    if value != newValue {
                        self.textValidator.text = value
                    }
                }
        }
    }
    
    func createNewCanvas() {
        guard !textValidator.text.isEmpty else {
            errorMessage = "Cannot be empty!"
            return
        }
        
        if canvasGallery.canvases.first(where: { $0.title == textValidator.text }) != nil {
            errorMessage = "Canvas exists!"
        } else {
            let newCanvas = CanvasItem(
                id: UUID(),
                title: textValidator.text,
                ellipses: [],
                n_cells_width: 30,
                n_cells_height: 60
            )
            canvasGallery.canvases.append(newCanvas)
            selectedCanvasID = newCanvas.id
            textValidator.text = ""
            errorMessage = nil
        }
    }
}

#Preview {
    CanvasCreate(selectedCanvasID: .constant(nil))
        .environment(CanvasGallery())
}
