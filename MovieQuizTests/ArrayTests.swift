//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Kira on 28.11.2024.
//

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws { 
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let value = array[2]
        
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() {
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let index = 20
        let value: Int?
        
        // Then
        if array.indices.contains(index) {
            value = array[index]
        } else {
            value = nil
        }
        
        XCTAssertNil(value)
    }
}
