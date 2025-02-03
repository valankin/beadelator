//
//  CanvasDetail.swift
//  Beadelator
//
//  Created by Yuri Valankin on 01.08.2024.
//

import SwiftUI
import PencilKit

struct CanvasDetail: View {
    
    @Environment(CanvasGallery.self) var canvasGallery
    
    /// Now we hold a binding to the actual canvas from the gallery.
    @Binding var canvas: CanvasItem
    
    @State private var lastChangedEllipseIndex: Int = -1
    
    @State private var selectedShapeColor: Color = .white
    @State private var defaultShapeColor: Color = .gray
    @State private var selectedBackgroundColor: Color = .gray
    
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    
    let canvasWidth = 800
    let canvasHeight = 1000
    
    var canvasSize: CGSize {
        CGSize(width: canvasWidth, height: canvasHeight)
    }
    
    init(canvas: Binding<CanvasItem>) {
        _canvas = canvas
    }
    
    var body: some View {
        VStack {
            HStack {
                ColorPicker("Shape color", selection: $selectedShapeColor)
                    .padding()
                ColorPicker("Background color", selection: $selectedBackgroundColor)
                    .padding()
            }
            Divider()
            Button {
                undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            
            ScrollView([.horizontal, .vertical]) {
                Canvas { context, size in
                    for ellipse in canvas.ellipses {
                        let rect = getRect(ellipse: ellipse)
                        drawEllipse(context: context, rect: rect, color: ellipse.color)
                    }
                }
                .frame(width: canvasSize.width, height: canvasSize.height)
                .cornerRadius(8)
                .background(selectedBackgroundColor)
                .gesture(DragGesture(minimumDistance: 0).onEnded(handleTouch))
            }
        }
        .onAppear{
            // Only initialize the ellipses if none exist.
            if canvas.ellipses.isEmpty {
                setupEllipses(color: defaultShapeColor)
            }
        }
    }
    
    func undo(){
        // (Undo logic can be implemented here if needed.)
    }
    
    /// Draws an ellipse within a rectangle.
    func drawEllipse(context: GraphicsContext, rect: CGRect, color: Color) {
        let path = Path(ellipseIn: rect)
        context.fill(path, with: .color(color))
        context.stroke(path, with: .color(.black), lineWidth: 1)
    }
    
    func getRect(ellipse: Ellipse) -> CGRect {
        CGRect(
            origin: CGPoint(
                x: ellipse.center.x - ellipse.radius.width,
                y: ellipse.center.y - ellipse.radius.height
            ),
            size: CGSize(width: ellipse.radius.width * 2,
                         height: ellipse.radius.height * 2)
        )
    }
    
    func setupEllipses(color: Color) {
        let step: Int = canvasWidth / canvas.n_cells_width
        let radiusSmall: Int = step / 6
        let radiusLarge: Int = Int(1.5 * CGFloat(radiusSmall))
        
        let horRadius = CGSize(width: radiusLarge, height: radiusSmall)
        let vertRadius = CGSize(width: radiusSmall, height: radiusLarge)
        
        let horCentOff = CGPoint(x: radiusLarge, y: 2 * radiusLarge + radiusSmall)
        let vertCentOff = CGPoint(x: 2 * radiusLarge + radiusSmall, y: radiusLarge)
        
        let radii: [CGSize] = [horRadius, vertRadius]
        let offsets: [CGPoint] = [horCentOff, vertCentOff]
        
        let shift: Int = 2 * radiusSmall + 2 * radiusLarge
        
        let multiplier: Int = 2
        let rows = canvas.n_cells_width * multiplier
        let columns = canvas.n_cells_height
        
        for row in 0..<rows {
            for column in 0..<columns {
                for (offset, radius) in zip(offsets, radii) {
                    let center = getEllipseCenter(offset: offset, shift: shift, row: row, column: column)
                    canvas.ellipses.append(Ellipse(center: center, radius: radius, color: color))
                }
            }
        }
    }
    
    func getScaledTouchLocation(value: DragGesture.Value) -> CGPoint {
        CGPoint(x: value.location.x / currentScale,
                y: value.location.y / currentScale)
    }
    
    func updateEllipseOnTouch(nearestEllipseIndex: Int, nearestEllipseColor: Color) {
        let newColor: Color = (nearestEllipseColor != selectedShapeColor) ? selectedShapeColor : defaultShapeColor
        canvas.ellipses[nearestEllipseIndex].color = newColor
        canvas.ellipses[nearestEllipseIndex].isSelected.toggle()
    }
    
    func handleTouch(value: DragGesture.Value) {
        let touchLocation = getScaledTouchLocation(value: value)
        guard let nearestEllipse = findNearestElipse(ellipses: canvas.ellipses, touchLocation: touchLocation),
              let nearestIndex = getEllipseIndex(ellipses: canvas.ellipses, ellipse: nearestEllipse)
        else { return }
        
        lastChangedEllipseIndex = nearestIndex
        updateEllipseOnTouch(nearestEllipseIndex: nearestIndex, nearestEllipseColor: nearestEllipse.color)
        print("HANDLE TOUCH FROM CANVAS: \(canvas.title) - \(canvas.id)")
    }
}
