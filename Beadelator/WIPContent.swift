//import SwiftUI
//import PencilKit
//
//
//// MARK: Requirements:
//// MARK: MainView
//// MainView contains Side Panel and Canvas
//// Side panel contains 
//
//
///// Canvas:
///// I want to be able to:
///// - Delete a canvas
///// - Clear a canvas
///// - Canvcanvases to be saved to a gallery so i can return to them later, when i switch canvases, my progress is automatically saved. Also when i add a canvas it must be initialized with ellipses immediately
//
//
//
//
//struct ContentViewWIP: View {
//    @State private var ellipses: [Ellipse] = []
//    @State private var selectedColor: Color = .white
//    @State private var defaultColor: Color = .gray
//    @State private var currentScale: CGFloat = 1.0
//    @State private var lastScaleValue: CGFloat = 1.0
//    @State private var lastChangedEllipseIndex: Int = -1
//    
//    @State private var canvasItems: [CanvasItem] = []
//    @State private var selectedCanvasID: UUID? = nil
//    @State private var newCanvasTitle: String = ""
//    
//    let canvasWidth = 800
//    let canvasHeight = 1000
//    
//    var canvasSize: CGSize {
//        return CGSize(width: canvasWidth, height: canvasHeight)
//    }
//    
//    let n_cells_width: Int
//    let n_cells_height: Int
//    init(n_cells_width: Int, n_cells_height: Int){
//        self.n_cells_width = n_cells_width
//        self.n_cells_height = n_cells_height
//    }
//    
//    var body: some View {
//        HStack {
//            VStack {
//                ColorPicker("Select Color", selection: $selectedColor).padding()
//                
//                TextField("New Canvas Title", text: $newCanvasTitle, onCommit: {
//                    hideKeyboard()
//                })
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//                
//                Button(action: createNewCanvas) {
//                    Text("Add Canvas")
//                        .padding()
//                        .background(newCanvasTitle.isEmpty ? Color.gray : Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//                .disabled(newCanvasTitle.isEmpty)
//                
//                List(canvasItems) { item in
//                    Button(action: { selectCanvas(item) }) {
//                        Text(item.title)
//                            .padding()
//                            .background(selectedCanvasID == item.id ? Color.gray.opacity(0.5) : Color.clear)
//                            .cornerRadius(8)
//                    }
//                }
//                
//                Button(action: {
//                    Task {
//                        await exportCanvasToPNG()
//                    }
//                }) {
//                    Text("Export to PNG")
//                        .padding()
//                        .background(Color.purple)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//            }
//            .frame(maxWidth: UIScreen.main.bounds.width * 0.2)
//            .navigationTitle("Canvas Gallery")
//            
//            VStack {
//                if let selectedCanvasID = selectedCanvasID,
//                   let selectedCanvas = canvasItems.first(where: { $0.id == selectedCanvasID }) {
//                    initScrollView(canvas: initCanvas(ellipses: selectedCanvas.ellipses))
//                }
//            }
//            .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
//        }
//    }
//    
//    func createNewCanvas() {
//        guard !newCanvasTitle.isEmpty else { return }
//        let newCanvas = CanvasItem(title: newCanvasTitle, ellipses: [])
//        canvasItems.append(newCanvas)
//        newCanvasTitle = ""
//        selectCanvas(newCanvas)
//    }
//    
//    func selectCanvas(_ canvasItem: CanvasItem) {
//        selectedCanvasID = canvasItem.id
//        ellipses = canvasItem.ellipses
//    }
//    
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//    
//    @MainActor
//    func exportCanvasToPNG() async {
//        let renderer = ImageRenderer(content: initCanvas(ellipses: ellipses))
//        let image = renderer.uiImage
//        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
//    }
//    
//    func drawEllipse(context: GraphicsContext, rect: CGRect, color: Color){
//        let path = Path(ellipseIn: rect)
//        context.fill(path, with: .color(color))
//        context.stroke(path, with: .color(.black), lineWidth: 1)
//    }
//    
//    func drawEllipses(context: GraphicsContext) {
//        for ellipse in ellipses {
//            let rect = getRect(ellipse: ellipse)
//            drawEllipse(context: context, rect: rect, color: ellipse.color)
//        }
//    }
//    
//    func initCanvas() -> Canvas<EmptyView> {
//        let canvas =  Canvas { (context, size) in
//            drawEllipses(context: context)
//        }
//        return canvas
//    }
//    
//    func initCanvas(ellipses: [Ellipse]) -> Canvas<EmptyView> {
//        Canvas { (context, size) in
//            drawEllipses(context: context)
//        }
//    }
//    
//    func initScrollView(canvas: Canvas<EmptyView>) -> ScrollView<some View> {
//        return ScrollView([.horizontal, .vertical]) {
//            canvas
//                .frame(width: canvasSize.width, height: canvasSize.height)
//                .cornerRadius(8)
//                .background(Color.gray)
//                .onAppear(perform: setupEllipses)
//                .gesture(DragGesture(minimumDistance: 0).onEnded(handleTouch))
//        }
//    }
//    
//    func getRect(ellipse: Ellipse) -> CGRect {
//        return CGRect(
//            origin: CGPoint(
//                x: ellipse.center.x - ellipse.radius.width,
//                y: ellipse.center.y - ellipse.radius.height
//            ),
//            size: CGSize(width: ellipse.radius.width * 2, height: ellipse.radius.height * 2)
//        )
//    }
//    
//    
//    
//    func getEllipseCenter(offset: CGPoint, shift: Int, row: Int, column: Int) -> CGPoint {
//        return CGPoint(
//            x: offset.y + CGFloat(shift * column),
//            y: offset.x + CGFloat(shift * row)
//        )
//    }
//    
//    func setupEllipses() {
//        let step: Int = canvasWidth / (n_cells_width)
//        let radiusSmall: Int = step / 6
//        let radiusLarge: Int = Int(1.5 * CGFloat(radiusSmall))
//        let horRadius = CGSize(width: radiusLarge, height: radiusSmall)
//        let vertRadius = CGSize(width: radiusSmall, height: radiusLarge)
//        let horCentOff = CGPoint(x: radiusLarge, y: 2 * radiusLarge + radiusSmall)
//        let vertCentOff = CGPoint(x: 2 * radiusLarge + radiusSmall, y: radiusLarge)
//        let radii: [CGSize] = [horRadius, vertRadius]
//        let offsets: [CGPoint] = [horCentOff, vertCentOff]
//        let shift: Int = 2 * radiusSmall +  2 * radiusLarge
//        let multiplier: Int = 2
//        let rows = n_cells_width * multiplier
//        let columns = n_cells_height
//        
//        for row in 0..<rows {
//            for column in 0..<columns {
//                for (offset, radius) in zip(offsets, radii) {
//                    let center = getEllipseCenter(offset: offset, shift: shift, row: row, column: column)
//                    ellipses.append(Ellipse(center: center, radius: radius, color: Color.gray))
//                }
//            }
//        }
//    }
//    
//    func findNearestElipse(ellipses: [Ellipse], touchLocation: CGPoint) -> Ellipse? {
//        return ellipses.min(by: {
//            $0.center.distance(to: touchLocation) < $1.center.distance(to: touchLocation)
//        })
//    }
//    
//    func getEllipseIndex(nearestEllipse: Ellipse) -> Int? {
//        return ellipses.firstIndex(where: { $0.id == nearestEllipse.id })
//    }
//    
//    func getScaledTouchLocation(value: DragGesture.Value) -> CGPoint {
//        return CGPoint(x: value.location.x / currentScale, y: value.location.y / currentScale)
//    }
//    
//    func updateEllipseOnTouch(nearestEllipseIndex: Int, nearestEllipseColor: Color){
//        let newColor = (nearestEllipseColor != selectedColor) ? selectedColor : defaultColor
//        ellipses[nearestEllipseIndex].color = newColor
//        ellipses[nearestEllipseIndex].isSelected.toggle()
//    }
//    
//    func handleTouch(value: DragGesture.Value) {
//        let touchLocation = getScaledTouchLocation(value: value)
//        if let nearestEllipse = findNearestElipse(ellipses: ellipses, touchLocation: touchLocation),
//           let nearestIndex = getEllipseIndex(nearestEllipse: nearestEllipse) {
//            lastChangedEllipseIndex = nearestIndex
//            updateEllipseOnTouch(nearestEllipseIndex: nearestIndex, nearestEllipseColor: nearestEllipse.color)
//        }
//    }
//}
//
////struct ContentView_Previews: PreviewProvider {
////    static var previews: some View {
////        ContentView(n_cells_width: 10, n_cells_height: 10)
////    }
////}
