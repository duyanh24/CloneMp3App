//
//  MypageServices.swift
//  Mp3App
//
//  Created by AnhLD on 9/29/20.
//  Copyright © 2020 AnhLD. All rights reserved.
//

import Foundation

struct MypageServices: HasPlaylistService, HasTrackService {
    var playlistService: PlaylistService
    var trackService: TrackService
}
