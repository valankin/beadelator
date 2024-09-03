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

    
//    @State private var ellipses: [Ellipse] = []
    @State private var lastChangedEllipseIndex: Int = -1
    
    @State private var selectedShapeColor: Color = .white
    @State private var defaultShapeColor: Color = .gray

    @State private var selectedBackgroundColor: Color = .gray
    
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    
    @State private var selectedCanvasID: UUID? = nil
    @State private var newCanvasTitle: String = ""
        
    
    @State var canvas: CanvasItem
        
    
    let canvasWidth = 800
    let canvasHeight = 1000
    
    
    var canvasSize: CGSize {
        return CGSize(width: canvasWidth, height: canvasHeight)
    }
    
    
    
    init(canvas: CanvasItem){
        self.canvas = canvas
    }
    
        var body: some View {
            @Bindable var canvasGallery = canvasGallery
            
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
                            /// Create a bounding rectangle to fit an ellipse
                            let rect = getRect(ellipse: ellipse)
                            /// Draw an ellipse within the rectangle
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
                setupEllipses(color: defaultShapeColor)
            }
        }
    
    func undo(){
        
    }
    
    /// Draws an ellipse within a rect
    func drawEllipse(context: GraphicsContext,
                     rect: CGRect,
                     color: Color){
        
        /// This creates a path in the shape of an ellipse that fits within the specified rectangle
        let path = Path(ellipseIn: rect)
        
        /// Fills the specified path with a color
        context.fill(path, with: .color(color))
        
        /// Draws a border (stroke) around the specified path
        context.stroke(path, with: .color(.black), lineWidth: 1)
    }
    
    
    /// Draws ellipses
    func drawEllipses(context: GraphicsContext) {
        for ellipse in canvas.ellipses {
            /// Create a bounding rectangle to fit an ellipse
            let rect = getRect(ellipse: ellipse)
            /// Draw an ellipse within the rectangle
            drawEllipse(context: context, rect: rect, color: ellipse.color)
        }
    }
    
    
    func getRect(ellipse: Ellipse) -> CGRect {
        return CGRect(
            origin: CGPoint(
                x: ellipse.center.x - ellipse.radius.width,
                y: ellipse.center.y - ellipse.radius.height
            ),
            size: CGSize(width: ellipse.radius.width * 2,
                         height: ellipse.radius.height * 2)
        )
    }

    
    
    func setupEllipses(color: Color) {
        
        /// Size of a cell containing 1 horizontal and 1 vertical bead
        let step: Int = canvasWidth / (canvas.n_cells_width)
        
        /// Bead radii values
        let radiusSmall: Int = step / 6
        let radiusLarge: Int = Int(1.5 * CGFloat(radiusSmall))
        
        /// Bead radii positions
        let horRadius = CGSize(width: radiusLarge, height: radiusSmall)
        let vertRadius = CGSize(width: radiusSmall, height: radiusLarge)
        
        /// Horizontal center offset
        let horCentOff = CGPoint(x: radiusLarge, y: 2 * radiusLarge + radiusSmall)
        /// Vertical center offset
        let vertCentOff = CGPoint(x: 2 * radiusLarge + radiusSmall, y: radiusLarge)
        
        let radii: [CGSize] = [horRadius, vertRadius]
        let offsets: [CGPoint] = [horCentOff, vertCentOff]
        
        
        let shift: Int = 2 * radiusSmall +  2 * radiusLarge
        
        
        let multiplier: Int = 2
        let rows = canvas.n_cells_width * multiplier
        let columns = canvas.n_cells_height
        
        
//        print("multiplier: \(multiplier)")
//        print("step: \(step)")
//        print("radiusSmall: \(radiusSmall)")
//        print("radiusLarge: \(radiusLarge)")
//        print("horRadius: \(horRadius)")
//        print("vertRadius: \(vertRadius)")
//        
//        print("horCentOff: \(horCentOff)")
//        print("vertCentOff: \(vertCentOff)")
//        print("shift: \(shift)")
//        print("rows: \(rows)")
//        print("columns: \(columns)")
        
        for row in 0..<rows {
            for column in 0..<columns {
                for (offset, radius) in zip(offsets, radii) {
                    let center =  getEllipseCenter(offset: offset, shift: shift, row: row, column: column)
                    canvas.ellipses.append(Ellipse(center: center, radius: radius, color: color))
                }
            }
        }
    }
    
    
    /// If canvas is zoomed, scale it down
    func getScaledTouchLocation(value: DragGesture.Value) -> CGPoint {
        return CGPoint(x: value.location.x / currentScale,
                       y: value.location.y / currentScale)
    }
    
    
    /// Update ellipse color
    func updateEllipseOnTouch(nearestEllipseIndex: Int, nearestEllipseColor: Color){
        let newColor: Color
        
        /// If color is different from selected, apply new color
        if (nearestEllipseColor != selectedShapeColor) {
            newColor = selectedShapeColor
            /// Else, apply default color
        } else {
            newColor = defaultShapeColor
        }
        
        /// Update color in any case
        canvas.ellipses[nearestEllipseIndex].color = newColor
        
        /// Toggle in any case
        canvas.ellipses[nearestEllipseIndex].isSelected.toggle()
        
    }
    
    /// Handle touch
    func handleTouch(value: DragGesture.Value) {
        /// Get scaled touch location
        let touchLocation = getScaledTouchLocation(value: value)
        
        /// Find nearest ellipse to the touch location
        let nearestEllipse = findNearestElipse(ellipses: canvas.ellipses, touchLocation: touchLocation)
        
        /// Find nearest Ellipse index
        let nearestIndex = getEllipseIndex(ellipses: canvas.ellipses, ellipse: nearestEllipse!)!
        
        /// Store last changed ellipse index
        lastChangedEllipseIndex = nearestIndex
        
        /// Update color on touch
        updateEllipseOnTouch(nearestEllipseIndex: nearestIndex,
                             nearestEllipseColor: nearestEllipse!.color)
        
        print("HANDLE TOUCH FROM CANVAS: \(canvas.title) - \(canvas.id)")
    }
}

#Preview {
    let canvases = CanvasGallery().canvases
    return CanvasDetail(canvas: canvases[0])
        .environment(CanvasGallery())
}
