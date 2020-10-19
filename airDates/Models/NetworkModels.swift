//
//  NetworkModels.swift
//  airDates
//
//  Created by Alex Mikhaylov on 02/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import UIKit

struct Results: Codable {
    var pages: Int
    var tv_shows: [Show]
}

/// Represents the show information returned by the API.
struct Show: Codable {
    var id: Int
    var name: String
    var start_date: String?
    var end_date: String?
    var country: String?
    var network: String?
    var status: String
    var image_thumbnail_path: String
}

/// Represents the structure of JSON returned by the API for a single show.
struct ShowInfoJSON: Codable {
    var tvShow: ShowInfo
}

/// Represents a single show returned by the API.
struct ShowInfo: Codable {
    var id: Int
    var thumbnailPath: String
    var name: String
    var description: String
    var genres: [String]
    var country: String?
    var network: String?
    var status: String
    var countdown: Episode?
    var episodes: [Episode]?
}

/// Used by MyShowsVC.
struct ShowMetaInfo {
    var showInfo: ShowInfo
    var image: UIImage? = nil
}

struct BasicShowMetaInfo {
    var showInfo: Show
    var image: UIImage? = nil
}

/// Represents the structure of a show returned by the API.
struct Episode: Codable {
    var season: Int
    var episode: Int
    var name: String
    var air_date: String
}
