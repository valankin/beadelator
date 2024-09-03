//
//  GCPointDistance.swift
//  Beadelator
//
//  Created by Yuri Valankin on 01.08.2024.
//

import Foundation


extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
    }
}
