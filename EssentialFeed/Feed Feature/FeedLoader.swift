//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Rishav Gupta on 03/11/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
