//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Rishav Gupta on 03/11/21.
//

import Foundation

public struct FeedItem: Equatable {
    var id: UUID
    var description: String?
    var location: String?
    var imageURL: URL
}
