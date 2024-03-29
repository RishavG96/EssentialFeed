//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Rishav Gupta on 06/01/23.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
//
//    public enum Result: Equatable {
//        case success([FeedItem])
//        case failure(RemoteFeedLoader.Error)
//    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity)) // domain level error
            }
        }
    }
}
