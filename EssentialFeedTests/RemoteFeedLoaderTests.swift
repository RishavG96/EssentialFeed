//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Rishav Gupta on 05/11/21.
//

import Foundation
import XCTest

class RemoteFeedLoader {
    func load() {
        
    }
}

class HTTPClient {
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let sut = RemoteFeedLoader()
        let client = HTTPClient()
        
        sut.load()
        
        XCTAssertNil(client.requestedURL)
    }
}
