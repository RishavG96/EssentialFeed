//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Rishav Gupta on 03/02/23.
//

import XCTest
import EssentialFeed

// We introiduced these 2 new types for the sole purpose of testing. These are not abstractions but they are meant to be used by other clients. They are abstractions just for the tests.
protocol HTTPSession {
    // we ensured that production code has visibility to only this method and we only need to mock this method and we do not need to care about any other method
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    private let session: HTTPSession
    
    init(session: HTTPSession) {
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
        let session = HTTPSessionSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        let session = HTTPSessionSpy()
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
    private class HTTPSessionSpy: HTTPSession {
        var receivedURLs = [URL]()
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }
        
        func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            receivedURLs.append(url)
            // now this method returns a URLSessionDataTask but we never want to ever execute a network request during a test. We need some sort of mock implementation of that DataTask, like a fake URLSessionDataTask
            guard let stub = stubs[url] else {
                fatalError("couldn't find stub for the given url")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionDataTask: HTTPSessionTask {
        func resume() { }
    }
    
    private class URLSessionDataTaskSpy: HTTPSessionTask {
        var resumeCallCount: Int = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
}
