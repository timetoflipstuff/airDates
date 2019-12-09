//
//  NetworkModels.swift
//  airDates
//
//  Created by Alex Mikhaylov on 02/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import Foundation

struct Results: Codable {
    var tv_shows: [Show]
}

struct Show: Codable {
    var id: Int
    var name: String
    var start_date: String?
    var end_date: String?
    var country: String
    var network: String
    var status: String
    var image_thumbnail_path: String
}

struct ShowInfoJSON: Codable {
    var tvShow: ShowInfo
}

struct ShowInfo: Codable {
    var id: Int
    var name: String
    var description: String
    var genres: [String]
    var country: String
    var network: String
    var status: String
    var countdown: Episode?
    var episodes: [Episode]?
}

struct Episode: Codable {
    var season: Int
    var episode: Int
    var name: String
    var air_date: String
}
