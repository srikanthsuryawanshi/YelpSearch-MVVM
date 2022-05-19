//
//  PositionResponse.swift
//  YelpSearch
//
//  Created by Srikanth SP on 19/05/22.
//

import Foundation

struct PositionResponse: Codable {
    var data: [PositionData]
}

struct PositionData: Codable {
    var label: String?
}
