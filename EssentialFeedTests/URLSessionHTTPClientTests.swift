//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Rishav Gupta on 03/02/23.
//

import XCTest
import EssentialFeed

// We introiduced these 2 new types for the sole purpose of testing. These are not abstractions but they are meant to be used by other clients. They are abstractions just for the tests.
//protocol HTTPSession {
//    // we ensured that production code has visibility to only this method and we only need to mock this method and we do not need to care about any other method
//    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
//}
//
//protocol HTTPSessionTask {
//    func resume()
//}

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
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
    
//    func test_getFromURL_resumesDataTaskWithURL() {
//        let url = URL(string: "http://any-url.com")!
//        let task = URLSessionDataTaskSpy()
//        let session = HTTPSessionSpy()
//        session.stub(url: url, task: task)
//
//        let sut = URLSessionHTTPClient(session: session)
//        sut.get(from: url) { _ in }
//
//        XCTAssertEqual(task.resumeCallCount, 1)
//    }
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequest()
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: error)
        
        let exp = expectation(description: "wait for completion")
        
        let sut = URLSessionHTTPClient()
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected failure with error got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequest()
    }
    
    // MARK :- Helpers

    // when  we are subclassing URLSession and URLSessionDataTask, it is often dangerous as
    //  we do not own those classes, we do not have access to their implementations
    // if we start mocking classes we do not own we can start creating assumptions in our mocked behaviour that could be wrong.
    private class URLProtocolStub: URLProtocol {
        var receivedURLs = [URL]()
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {
                return false
            }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
        
//        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
//            receivedURLs.append(url)
//            // now this method returns a URLSessionDataTask but we never want to ever execute a network request during a test. We need some sort of mock implementation of that DataTask, like a fake URLSessionDataTask
//            guard let stub = stubs[url] else {
//                fatalError("couldn't find stub for the given url")
//            }
//            completionHandler(nil, nil, stub.error)
//            return stub.task
//        }
    }
    
//    private class FakeURLSessionDataTask: HTTPSessionTask {
//        func resume() { }
//    }
//
//    private class URLSessionDataTaskSpy: HTTPSessionTask {
//        var resumeCallCount: Int = 0
//
//        func resume() {
//            resumeCallCount += 1
//        }
//    }
}
