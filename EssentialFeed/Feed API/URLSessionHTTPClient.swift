//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Rishav Gupta on 04/02/23.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {
        
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> ()) {
//        let url = URL(string: "http://wrong-url.com")!
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
