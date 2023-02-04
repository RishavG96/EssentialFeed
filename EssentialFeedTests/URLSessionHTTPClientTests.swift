//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Rishav Gupta on 03/02/23.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> ()) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createsDataTaskWithURL() {
//        let url = URL(string: "http://any-url.com")!
//        let session = URLSessionSpy()
//        // as URLSession does not have receivedURLs, as it is a test detail. We need to spy it to create a URLSessionSpy which will be a subclass of URLSession
//
//        let sut = URLSessionHTTPClient(session: session)
//        sut.get(from: url) { _ in }
//
//        XCTAssertEqual(session.receivedURLs, [url])
    } // we checked here data task is getting created with the right url, next thing we need to check for the dataTask to start is to call resume()
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let task = URLSessionDataTaskSpy()
        let session = URLSessionSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        let session = URLSessionSpy()
        session.stub(url: url, error: error)
        
        let exp = expectation(description: "wait for completion")
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK :- Helpers

    // when  we are subclassing URLSession and URLSessionDataTask, it is often dangerous as
    //  we do not own those classes, we do not have access to their implementations
    // if we start mocking classes we do not own we can start creating assumptions in our mocked behaviour that could be wrong.
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            // now this method returns a URLSessionDataTask but we never want to ever execute a network request during a test. We need some sort of mock implementation of that DataTask, like a fake URLSessionDataTask
            guard let stub = stubs[url] else {
                fatalError("couldn't find stub for the given url")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() { }
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount: Int = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}
