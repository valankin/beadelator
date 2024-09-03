//
//  CanvasItem.swift
//  Beadelator
//
//  Created by Yuri Valankin on 01.08.2024.
//

import Foundation


// Structure to represent a saved canvas
struct CanvasItem: Identifiable {
    var id = UUID()
    var title: String
    var ellipses: [Ellipse]
    let n_cells_width: Int
    let n_cells_height: Int
}

