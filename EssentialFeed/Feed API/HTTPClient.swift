//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Rishav Gupta on 28/01/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
