//
//  CanvasDetail.swift
//  Beadelator
//
//  Created by Yuri Valankin on 01.08.2024.
//

import SwiftUI
import PencilKit
import UIKit

struct CanvasDetail: View {
    @Environment(CanvasGallery.self) var canvasGallery
    
    /// Bind to the canvas from the gallery so its state is persistent.
    @Binding var canvas: CanvasItem
    
    // MARK: - Drawing & Undo State
    
    // Undo stack stores previous state for an ellipse.
    @State private var undoStack: [(index: Int, previousColor: Color, previousIsSelected: Bool)] = []
    
    // Keeps track of the last updated ellipse index during a drag.
    @State private var lastUpdatedIndexDuringDrag: Int? = nil
    
    // MARK: - Control States
    
    @State private var selectedShapeColor: Color = .white
    @State private var defaultShapeColor: Color = .gray
    @State private var selectedBackgroundColor: Color = .gray
    @State private var hideUnfilledShapes: Bool = false
    @State private var controlsVisible: Bool = true
    
    // Toggle between drawing and panning modes.
    @State private var drawingMode: Bool = true
    
    // MARK: - Zoom State
    
    @State private var currentScale: CGFloat = 1.0
    
    // MARK: - Export State
    
    @State private var exportImage: UIImage? = nil
    @State private var showingShareSheet: Bool = false
    
    // MARK: - Canvas Dimensions
    
    let canvasWidth = 800
    let canvasHeight = 1000
    var canvasSize: CGSize { CGSize(width: canvasWidth, height: canvasHeight) }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            // --- Controls Toggle ---
            HStack {
                Button(action: { controlsVisible.toggle() }) {
                    HStack {
                        Text(controlsVisible ? "Hide Controls" : "Show Controls")
                        Image(systemName: controlsVisible ? "chevron.up" : "chevron.down")
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
            
            // --- Control Panel (if visible) ---
            if controlsVisible {
                VStack(spacing: 0) {
                    HStack {
                        ColorPicker("Shape color", selection: $selectedShapeColor)
                            .padding()
                    }
                    HStack {
                        ColorPicker("Background color", selection: $selectedBackgroundColor)
                            .padding()
                    }
                    HStack {
                        Toggle("Hide unfilled shapes", isOn: $hideUnfilledShapes)
                            .padding()
                    }
                    HStack {
                        Button {
                            undo()
                        } label: {
                            Label("Undo", systemImage: "arrow.uturn.backward")
                        }
                        .padding()
                        
                        Button {
                            exportPNG()
                        } label: {
                            Label("Export PNG", systemImage: "square.and.arrow.up")
                        }
                        .padding()
                    }
                }
            }
            
            Divider()
            
            // --- Drawing Area in a ScrollView ---
            ScrollView([.horizontal, .vertical]) {
                // Use a computed view for the canvas so we can conditionally attach the gesture.
                Group {
                    drawingCanvas
                }
                .if(drawingMode) { view in
                    view.gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged(handleDrag)
                            .onEnded { _ in lastUpdatedIndexDuringDrag = nil }
                    )
                }
            }
            
            // --- Zoom & Mode Controls ---
            HStack {
                // Toggle between drawing and panning.
                Button(action: {
                    drawingMode.toggle()
                }) {
                    Image(systemName: drawingMode ? "pencil" : "hand.draw")
                        .font(.title)
                }
                .padding(.horizontal)
                
                // Zoom controls.
                Button(action: {
                    withAnimation { currentScale = max(currentScale - 0.1, 0.5) }
                }) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.title)
                }
                .padding(.horizontal)
                
                Slider(value: $currentScale, in: 0.5...2.0, step: 0.1)
                    .padding(.horizontal)
                
                Button(action: {
                    withAnimation { currentScale = min(currentScale + 0.1, 2.0) }
                }) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.title)
                }
                .padding(.horizontal)
                
                Text("\(Int(currentScale * 100))%")
                    .padding(.trailing)
            }
            .padding(.vertical)
        }
        .onAppear {
            // Initialize the ellipses only once.
            if canvas.ellipses.isEmpty {
                setupEllipses(color: defaultShapeColor)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = exportImage {
                ShareSheet(activityItems: [image])
            }
        }
    }
    
    // MARK: - Computed Canvas View
    
    /// The canvas view that draws the ellipses. It applies scaling to each ellipse.
    var drawingCanvas: some View {
        Canvas { context, _ in
            for ellipse in canvas.ellipses {
                if hideUnfilledShapes && ellipse.color == defaultShapeColor { continue }
                let scaledRect = getScaledRect(for: ellipse)
                drawEllipse(context: context, rect: scaledRect, color: ellipse.color)
            }
        }
        .frame(width: canvasSize.width * currentScale,
               height: canvasSize.height * currentScale)
        .background(selectedBackgroundColor)
        .cornerRadius(8)
    }
    
    // MARK: - Drawing Helpers
    
    /// Draws an ellipse within the specified rectangle.
    func drawEllipse(context: GraphicsContext, rect: CGRect, color: Color) {
        let path = Path(ellipseIn: rect)
        context.fill(path, with: .color(color))
        context.stroke(path, with: .color(.black), lineWidth: 1)
    }
    
    /// Returns the original bounding rectangle for an ellipse (in unscaled coordinates).
    func getRect(ellipse: Ellipse) -> CGRect {
        CGRect(
            origin: CGPoint(
                x: ellipse.center.x - ellipse.radius.width,
                y: ellipse.center.y - ellipse.radius.height
            ),
            size: CGSize(
                width: ellipse.radius.width * 2,
                height: ellipse.radius.height * 2
            )
        )
    }
    
    /// Returns the rectangle for an ellipse scaled by the current zoom factor.
    func getScaledRect(for ellipse: Ellipse) -> CGRect {
        let rect = getRect(ellipse: ellipse)
        return CGRect(
            x: rect.origin.x * currentScale,
            y: rect.origin.y * currentScale,
            width: rect.size.width * currentScale,
            height: rect.size.height * currentScale
        )
    }
    
    /// Initializes the canvas with ellipses if empty.
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
    
    // MARK: - Drag Gesture Handling
    
    /// Converts the drag location (from the scaled view) to the unscaled coordinate system.
    func getScaledTouchLocation(value: DragGesture.Value) -> CGPoint {
        CGPoint(x: value.location.x / currentScale, y: value.location.y / currentScale)
    }
    
    /// Handles the drag gesture to update the nearest ellipse (only when in drawing mode).
    func handleDrag(value: DragGesture.Value) {
        let touchLocation = getScaledTouchLocation(value: value)
        guard let nearestEllipse = findNearestElipse(ellipses: canvas.ellipses, touchLocation: touchLocation),
              let nearestIndex = getEllipseIndex(ellipses: canvas.ellipses, ellipse: nearestEllipse)
        else { return }
        
        // Avoid updating repeatedly on the same ellipse during a single drag.
        if lastUpdatedIndexDuringDrag == nearestIndex { return }
        
        // Save the current state for undo.
        let oldState = (index: nearestIndex,
                        previousColor: canvas.ellipses[nearestIndex].color,
                        previousIsSelected: canvas.ellipses[nearestIndex].isSelected)
        undoStack.append(oldState)
        
        updateEllipseOnTouch(nearestEllipseIndex: nearestIndex,
                             nearestEllipseColor: canvas.ellipses[nearestIndex].color)
        lastUpdatedIndexDuringDrag = nearestIndex
    }
    
    /// Toggles an ellipse’s color between the selected color and the default.
    func updateEllipseOnTouch(nearestEllipseIndex: Int, nearestEllipseColor: Color) {
        let newColor: Color = (nearestEllipseColor != selectedShapeColor) ? selectedShapeColor : defaultShapeColor
        canvas.ellipses[nearestEllipseIndex].color = newColor
        canvas.ellipses[nearestEllipseIndex].isSelected.toggle()
    }
    
    /// Undo the last color change.
    func undo() {
        guard let lastAction = undoStack.popLast() else { return }
        canvas.ellipses[lastAction.index].color = lastAction.previousColor
        canvas.ellipses[lastAction.index].isSelected = lastAction.previousIsSelected
    }
    
    // MARK: - PNG Export
    
    /// Exports the current canvas view as a PNG image and presents a share sheet.
    func exportPNG() {
        let renderer = ImageRenderer(content:
            Canvas { context, _ in
                for ellipse in canvas.ellipses {
                    if hideUnfilledShapes && ellipse.color == defaultShapeColor { continue }
                    let scaledRect = getScaledRect(for: ellipse)
                    drawEllipse(context: context, rect: scaledRect, color: ellipse.color)
                }
            }
            .frame(width: canvasSize.width * currentScale,
                   height: canvasSize.height * currentScale)
            .background(selectedBackgroundColor)
        )
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage {
            exportImage = uiImage
            showingShareSheet = true
        }
    }
}
