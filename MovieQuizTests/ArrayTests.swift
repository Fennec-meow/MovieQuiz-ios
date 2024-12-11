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
    
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let value = array[20]
        
        // Then
        XCTAssertNil(value)
    }
}
