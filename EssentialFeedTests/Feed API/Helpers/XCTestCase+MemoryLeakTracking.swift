//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Rishav Gupta on 04/02/23.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        // Need to make sure SUT was deallocated from memory, need to run these assertions after the tests
        addTeardownBlock { [weak instance] in
            
            // when every test finishes running then the tear down block is invoked
            // here sut gets captured strongly, so it will never be nil so we need to introduce weak sut in this block
            XCTAssertNil(instance, "Instance should have been deallocated, potential memory leak", file: file, line: line)
        }
    }
}
