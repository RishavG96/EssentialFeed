//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Rishav Gupta on 06/11/21.
//

import Foundation

public class RemoteFeedLoader: FeedLoader {
    
    private var client: HTTPClient
    private var url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public typealias Result = LoadFeedResult
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion(FeedItemMapper.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
