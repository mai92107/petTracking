//
//  TripModel.swift
//  petTracking
//
//  Created by Rafael Mai on 2025/11/25.
//

struct TripModel: Codable {
    let uuid: String
    let time: String
    let distance: String
    let duration: String
}

struct TripDetail: Codable{
    let startAt: String
    let endAt: String
    let point: Int
    let deviceId: String
    let createdAt: String
    let updatedAt: String
}
