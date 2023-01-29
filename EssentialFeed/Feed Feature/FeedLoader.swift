//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Rishav Gupta on 04/01/23.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
