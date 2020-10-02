//
//  TrackListRespone.swift
//  Mp3App
//
//  Created by AnhLD on 10/1/20.
//  Copyright © 2020 AnhLD. All rights reserved.
//

import Foundation

struct TrackListResponse: Codable {
    var genre: String?
    var playlist: [Playlist]?
    
    enum CodingKeys: String, CodingKey {
        case genre
        case playlist = "collection"
    }
}

struct Playlist: Codable {
    var track: Track?
    
    enum CodingKeys: String, CodingKey {
        case track
    }
}
