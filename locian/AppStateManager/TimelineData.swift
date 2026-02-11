//
//  TimelineData.swift
//  locian
//
//  Created by locian on 10/02/26.
//

import Foundation

struct TimelineData: Codable {
    let places: [MicroSituationData]
    let inputTime: String?
    let timeSpan: String?
    
    init(places: [MicroSituationData], inputTime: String? = nil, timeSpan: String? = nil) {
        self.places = places
        self.inputTime = inputTime
        self.timeSpan = timeSpan
    }
}
