//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Rishav Gupta on 04/01/23.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let locaiton: String?
    let imageURL: URL
}
