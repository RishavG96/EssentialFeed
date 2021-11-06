//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Rishav Gupta on 06/11/21.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

public class RemoteFeedLoader {
    
    private var client: HTTPClient
    private var url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}
