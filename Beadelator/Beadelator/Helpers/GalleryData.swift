//
//  GalleryData.swift
//  Beadelator
//
//  Created by Yuri Valankin on 05.08.2024.
//

import Foundation
import SwiftUI


//var canvases: [CanvasItem] = load("gallery.json")



//var testCanvas = CanvasItem(
//    id: UUID(),
//    title: "New Canvas",
//    ellipses: [],
//    n_cells_width: 30,
//    n_cells_height: 60)
//
//
//var testCanvasList = [
//    CanvasItem(
//        id: UUID(),
//        title: "New Canvas",
//        ellipses: [],
//        n_cells_width: 30,
//        n_cells_height: 60),
//    CanvasItem(
//        id: UUID(),
//        title: "New Canvas 2",
//        ellipses: [],
//        n_cells_width: 30,
//        n_cells_height: 60)
//]


@Observable
final class CanvasGallery {
    var canvases: [CanvasItem] = [
        CanvasItem(
            id: UUID(),
            title: "New Canvas",
            ellipses: [],
            n_cells_width: 30,
            n_cells_height: 60),
        CanvasItem(
            id: UUID(),
            title: "New Canvas 2",
            ellipses: [],
            n_cells_width: 30,
            n_cells_height: 60)
    ]
    
    func byID(id: UUID) -> CanvasItem? {
        return canvases.first(where: {$0.id == id})
    }
        
}
    



func load<T: Decodable>(_ filename: String) -> T {
    let data: Data


    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }


    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }


    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}



//// Create sample data
//let sampleEllipses = [
//    Ellipse(center: CGPoint(x: 50, y: 100), radius: CGSize(width: 30, height: 40), color: Color.red),
//    Ellipse(center: CGPoint(x: 150, y: 200), radius: CGSize(width: 50, height: 60), color: Color.green),
//    Ellipse(center: CGPoint(x: 250, y: 300), radius: CGSize(width: 70, height: 80), color: Color.blue)
//]
//
//let sampleCanvasItems = [
//    CanvasItem(title: "First Canvas", ellipses: sampleEllipses),
//    CanvasItem(title: "Second Canvas", ellipses: [
//        Ellipse(center: CGPoint(x: 100, y: 150), radius: CGSize(width: 20, height: 30), color: Color.yellow),
//        Ellipse(center: CGPoint(x: 200, y: 250), radius: CGSize(width: 40, height: 50), color: Color.purple)
//    ])
//]
//
//// Encode to JSON
//func encodeToJSONFile(canvasItems: [CanvasItem]) {
//    let encoder = JSONEncoder()
//    encoder.outputFormatting = .prettyPrinted
//
//    do {
//        let jsonData = try encoder.encode(canvasItems)
//        if let jsonString = String(data: jsonData, encoding: .utf8) {
//            print(jsonString)
//        }
//        let fileURL = getDocumentsDirectory().appendingPathComponent("gallery.json")
//        try jsonData.write(to: fileURL)
//        print("JSON written to: \(fileURL)")
//    } catch {
//        print("Error encoding to JSON: \(error.localizedDescription)")
//    }
//}
//
//// Get the documents directory for saving the file
//func getDocumentsDirectory() -> URL {
//    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//}
//
//// Call the function to encode and save the data
//encodeToJSONFile(canvasItems: sampleCanvasItems)
