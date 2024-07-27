//
//  ContentView.swift
//  Beadelator
//
//  Created by Yuri Valankin on 24.07.2024.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    @State private var ellipses: [Ellipse] = []
    @State private var selectedColor: Color = .white
    @State private var defaultColor: Color = .gray
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var lastChangedEllipseIndex: Int = -1
    
    @State private var canvasItems: [CanvasItem] = []
    @State private var selectedCanvasID: UUID? = nil
    @State private var newCanvasTitle: String = ""
    
    let canvasWidth = 800
    let canvasHeight = 1000
    
    
//    let canvasWidth = 3840 // 4k resolution
//    let canvasHeight = 2160
    
    var canvasSize: CGSize {
        return CGSize(width: canvasWidth, height: canvasHeight)
    }
    
    let n_cells_width: Int
    let n_cells_height: Int
    init(n_cells_width: Int, n_cells_height: Int){
        /// Number of horizontal and vertical cells
        self.n_cells_width = n_cells_width
        self.n_cells_height = n_cells_height
    }
    
    
    var body: some View {
        let canvas = initCanvas()
        let scrollView = initScrollView(canvas: canvas)
        let colorPicker = ColorPicker("Select Color", selection: $selectedColor).padding()
        
        VStack {
            colorPicker
            scrollView
        }
    }
    // MARK: - Member functions
    
    
    // MARK: - Drawing functions
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
        for ellipse in ellipses {
            /// Create a bounding rectangle to fit an ellipse
            let rect = getRect(ellipse: ellipse)
            /// Draw an ellipse within the rectangle
            drawEllipse(context: context, rect: rect, color: ellipse.color)
        }
    }
    
    /// Init a canvas with Ellipses
    func initCanvas() -> Canvas<EmptyView> {
        let canvas =  Canvas { (context, size) in
            drawEllipses(context: context)
        }
        return canvas
    }
    
    /// Innit a Scrol View
    func initScrollView(canvas: Canvas<EmptyView>) -> ScrollView<some View>{
        return ScrollView([.horizontal, .vertical]) {
            canvas
                .frame(width: canvasSize.width, height: canvasSize.height)
                .cornerRadius(8)
                .background(Color.green)
                .onAppear(perform: setupEllipses)
                .gesture(DragGesture(minimumDistance: 0).onEnded(handleTouch))
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
    
    func getEllipseCenter(offset: CGPoint, shift: Int, row: Int, column: Int) -> CGPoint {
        let center = CGPoint(
            x: offset.y + CGFloat(shift * column),
            y: offset.x + CGFloat(shift * row)
        )
        return center
    }
    
    func setupEllipses() {
        
        /// Size of a cell containing 1 horizontal and 1 vertical bead
        let step: Int = canvasWidth / (n_cells_width)
        
        /// Bead radii values
        let radiusSmall: Int = step / 6
        let radiusLarge: Int = Int(1.5 * CGFloat(radiusSmall))
        
        /// Bead radii positions
        let horRadius = CGSize(width: radiusLarge, height: radiusSmall)
        let vertRadius = CGSize(width: radiusSmall, height: radiusLarge)
        
        /// Horizontal center offcet
        let horCentOff = CGPoint(x: radiusLarge, y: 2 * radiusLarge + radiusSmall)
        /// Vertical center offcet
        let vertCentOff = CGPoint(x: 2 * radiusLarge + radiusSmall, y: radiusLarge)
        
        let radii: [CGSize] = [horRadius, vertRadius]
        let offsets: [CGPoint] = [horCentOff, vertCentOff]
        
        
        let shift: Int = 2 * radiusSmall +  2 * radiusLarge
        
        
        let multiplier: Int = 2
        let rows = n_cells_width * multiplier
        let columns = n_cells_height
        
    
        print("multiplier: \(multiplier)")
        print("step: \(step)")
        print("radiusSmall: \(radiusSmall)")
        print("radiusLarge: \(radiusLarge)")
        print("horRadius: \(horRadius)")
        print("vertRadius: \(vertRadius)")

        print("horCentOff: \(horCentOff)")
        print("vertCentOff: \(vertCentOff)")
        print("shift: \(shift)")
        print("rows: \(rows)")
        print("columns: \(columns)")

        for row in 0..<rows {
            for column in 0..<columns {
                for (offset, radius) in zip(offsets, radii) {
                    let center = getEllipseCenter(offset: offset, shift: shift, row: row, column: column)
                    ellipses.append(Ellipse(center: center, radius: radius, color: Color.gray))
                }
            }
        }
    }
    
    /// O(n) search based on Eucledian distance
    func findNearestElipse(ellipses: [Ellipse], touchLocation: CGPoint) -> Ellipse? {
        let nearestEllipse = ellipses.min(by: {
            $0.center.distance(to: touchLocation) < $1.center.distance(to: touchLocation)
        })
        
        return nearestEllipse
    }
    
    /// O(n) ellipse index search
    func getEllipseIndex(nearestEllipse: Ellipse) -> Int?{
        return ellipses.firstIndex(
            where: { $0.id == nearestEllipse.id })
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
        if (nearestEllipseColor != selectedColor) {
            newColor = selectedColor
            /// Else, apply default color
        } else {
            newColor = defaultColor
        }
        
        /// Update color in any case
        ellipses[nearestEllipseIndex].color = newColor
        
        /// Toggle in any case
        ellipses[nearestEllipseIndex].isSelected.toggle()
        
    }
    
    /// Handle touch
    func handleTouch(value: DragGesture.Value) {
        /// Get scaled touch location
        let touchLocation = getScaledTouchLocation(value: value)
        
        /// Find nearest ellipse to the touch location
        let nearestEllipse = findNearestElipse(ellipses: ellipses, touchLocation: touchLocation)
        
        /// Find nearest Ellipse index
        let nearestIndex = getEllipseIndex(nearestEllipse: nearestEllipse!)!
        
        /// Store last changed ellipse index
        lastChangedEllipseIndex = nearestIndex
        
        /// Update color on touch
        updateEllipseOnTouch(nearestEllipseIndex: nearestIndex,
                             nearestEllipseColor: nearestEllipse!.color)
    }
}

