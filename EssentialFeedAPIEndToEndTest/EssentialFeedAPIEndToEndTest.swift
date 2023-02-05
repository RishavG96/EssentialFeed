//
//  EssentialFeedAPIEndToEndTest.swift
//  EssentialFeedAPIEndToEndTest
//
//  Created by Rishav Gupta on 05/02/23.
//

import XCTest
import EssentialFeed


class EssentialFeedAPIEndToEndTest: XCTestCase {

    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(url: testServerURL, client: client)
        
        let exp = expectation(description: "wait for load completion")
        
        var receivedResult: LoadFeedResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        switch receivedResult {
        case let .success(items)?:
            XCTAssertEqual(items.count, 8, "Expected 8 items in the test account feed")
        case let .failure(error)?:
            XCTFail("Expected successful feed result got \(error) instead")
        default:
            XCTFail("Expected success got no result instead")
        }
    }
}
