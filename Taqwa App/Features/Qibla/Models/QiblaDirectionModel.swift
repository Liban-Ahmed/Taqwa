//
//  QiblaDirectionModel.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//

import Foundation

struct QiblaDirectionModel {
    /// The user's current coordinates
    let latitude: Double
    let longitude: Double

    /// The calculated bearing (in degrees from North) to the Kaaba in Makkah
    let qiblaBearing: Double
}
