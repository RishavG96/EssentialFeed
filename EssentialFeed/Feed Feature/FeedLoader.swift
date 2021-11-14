//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Rishav Gupta on 03/11/21.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func load(comlpetion: @escaping (LoadFeedResult<Error>) -> Void)
}
