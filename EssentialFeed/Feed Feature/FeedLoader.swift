//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Rishav Gupta on 03/11/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(comlpetion: @escaping (LoadFeedResult) -> Void)
}
