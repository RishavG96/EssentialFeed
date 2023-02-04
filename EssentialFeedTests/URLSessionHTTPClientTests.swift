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
//        let url = URL(string: "http://wrong-url.com")!
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        
        let url = URL(string: "http://any-url.com")!
        
        let exp = expectation(description: "wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        // We can use the same mechanism to test post requests, also investigate the body of the request and also investigate query params of the request. Any request related data that we care about can be asserted through these observers without hitting the network.
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }

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
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let exp = expectation(description: "wait for completion")
        
        makeSUT().get(from: url) { result in
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
    }
    
    // MARK :- Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        // Need to make sure SUT was deallocated from memory, need to run these assertions after the tests
        addTeardownBlock { [weak instance] in
            
            // when every test finishes running then the tear down block is invoked
            // here sut gets captured strongly, so it will never be nil so we need to introduce weak sut in this block
            XCTAssertNil(instance, "Instance should have been deallocated, potential memory leak", file: file, line: line)
        }
    }

    // when  we are subclassing URLSession and URLSessionDataTask, it is often dangerous as
    //  we do not own those classes, we do not have access to their implementations
    // if we start mocking classes we do not own we can start creating assumptions in our mocked behaviour that could be wrong.
    private class URLProtocolStub: URLProtocol {
        var receivedURLs = [URL]()
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
//            guard let url = request.url else {
//                return false
//            }
//
//            return URLProtocolStub.stubs[url] != nil
            
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            requestObserver?(request)
            return request
        }
        
        override func startLoading() {
//            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
//
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
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
