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
    
    /// Use a binding so that every canvas “owns” its persistent drawing state.
    @Binding var canvas: CanvasItem
    
    // For undo functionality.
    @State private var undoStack: [(index: Int, previousColor: Color, previousIsSelected: Bool)] = []
    
    // Keep track of the last updated ellipse in the current drag.
    @State private var lastUpdatedIndexDuringDrag: Int? = nil
    
    // Color pickers.
    @State private var selectedShapeColor: Color = .white
    @State private var defaultShapeColor: Color = .gray
    @State private var selectedBackgroundColor: Color = .gray
    
    // Hide unfilled shapes toggle.
    @State private var hideUnfilledShapes: Bool = false

    // For PNG export.
    @State private var exportImage: UIImage? = nil
    @State private var showingShareSheet: Bool = false
    
    // Toggle for showing/hiding controls.
    @State private var controlsVisible: Bool = true
    
    // Canvas size.
    let canvasWidth = 800
    let canvasHeight = 1000
    var canvasSize: CGSize { CGSize(width: canvasWidth, height: canvasHeight) }
    
    init(canvas: Binding<CanvasItem>) {
        _canvas = canvas
    }
    
    var body: some View {
        VStack {
            // Toggle bar for showing/hiding controls.
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
            
            // Conditionally show the control section.
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
            
            // The drawing canvas.
            ScrollView([.horizontal, .vertical]) {
                Canvas { context, size in
                    // Draw each ellipse (skip those unfilled if requested).
                    for ellipse in canvas.ellipses {
                        if hideUnfilledShapes && ellipse.color == defaultShapeColor {
                            continue
                        }
                        let rect = getRect(ellipse: ellipse)
                        drawEllipse(context: context, rect: rect, color: ellipse.color)
                    }
                }
                .frame(width: canvasSize.width, height: canvasSize.height)
                .cornerRadius(8)
                .background(selectedBackgroundColor)
                // Draw as you drag.
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged(handleDrag)
                        .onEnded { _ in lastUpdatedIndexDuringDrag = nil }
                )
            }
        }
        .onAppear {
            // Initialize ellipses only once.
            if canvas.ellipses.isEmpty {
                setupEllipses(color: defaultShapeColor)
            }
        }
        // Present a share sheet when PNG export is ready.
        .sheet(isPresented: $showingShareSheet) {
            if let image = exportImage {
                ShareSheet(activityItems: [image])
            }
        }
    }
    
    /// Draw an ellipse within a given rectangle.
    func drawEllipse(context: GraphicsContext, rect: CGRect, color: Color) {
        let path = Path(ellipseIn: rect)
        context.fill(path, with: .color(color))
        context.stroke(path, with: .color(.black), lineWidth: 1)
    }
    
    /// Get the bounding rectangle for an ellipse.
    func getRect(ellipse: Ellipse) -> CGRect {
        CGRect(origin: CGPoint(x: ellipse.center.x - ellipse.radius.width,
                                 y: ellipse.center.y - ellipse.radius.height),
               size: CGSize(width: ellipse.radius.width * 2,
                            height: ellipse.radius.height * 2))
    }
    
    /// Create the beads (ellipses) on the canvas.
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
    
    /// Convert the drag gesture location (in our case, no extra scaling is applied).
    func getScaledTouchLocation(value: DragGesture.Value) -> CGPoint {
        value.location
    }
    
    /// As the user drags, update the ellipse under the finger.
    func handleDrag(value: DragGesture.Value) {
        let touchLocation = getScaledTouchLocation(value: value)
        guard let nearestEllipse = findNearestElipse(ellipses: canvas.ellipses, touchLocation: touchLocation),
              let nearestIndex = getEllipseIndex(ellipses: canvas.ellipses, ellipse: nearestEllipse)
        else { return }
        
        // Avoid updating repeatedly on the same bead in one drag.
        if lastUpdatedIndexDuringDrag == nearestIndex { return }
        
        // Save current state for undo.
        let oldState = (index: nearestIndex,
                        previousColor: canvas.ellipses[nearestIndex].color,
                        previousIsSelected: canvas.ellipses[nearestIndex].isSelected)
        undoStack.append(oldState)
        
        updateEllipseOnTouch(nearestEllipseIndex: nearestIndex,
                             nearestEllipseColor: canvas.ellipses[nearestIndex].color)
        lastUpdatedIndexDuringDrag = nearestIndex
    }
    
    /// Update a bead’s color (toggle between the selected color and the default).
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
    
    /// Export the current canvas as a PNG image and present a share sheet.
    func exportPNG() {
        // Create an offscreen renderer for the canvas.
        let renderer = ImageRenderer(content:
            Canvas { context, size in
                for ellipse in canvas.ellipses {
                    if hideUnfilledShapes && ellipse.color == defaultShapeColor {
                        continue
                    }
                    let rect = getRect(ellipse: ellipse)
                    drawEllipse(context: context, rect: rect, color: ellipse.color)
                }
            }
            .frame(width: canvasSize.width, height: canvasSize.height)
            .background(selectedBackgroundColor)
        )
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage {
            exportImage = uiImage
            showingShareSheet = true
        }
    }
}
