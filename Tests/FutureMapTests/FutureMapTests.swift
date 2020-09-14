import XCTest
import FutureMap
import Combine

final class FutureMapTests: XCTestCase {
    func testExample() {
        var promise: ((Result<Int, Never>) -> Void)?
        
        let future: Future<Int, Never> = /* ... */ Future { promise = $0 }
        let mapped: Future<Int, Never> = future.futureMap { $0 * $0 }
        let cancellable = mapped.sink { value in
            print(value)
        }
        
        promise?(.success(3))
        cancellable.cancel()
    }
    
    func testFutureMap() {
        do {
            let expectation = XCTestExpectation()
            
            let a: Future<Int, Never> = .init { promise in
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    promise(.success(3))
                }
            }
            let r: Future<Int, Never> = a.futureMap { $0 * $0 }
            
            let cancellable = r.sink { value in
                XCTAssertEqual(value, 9)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 3.0)
            
            cancellable.cancel()
        }
    }
    
    func testFutureFlatMap() {
        do {
            let expectation = XCTestExpectation()
            
            let a: Future<Int, Never> = .init { promise in
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    promise(.success(3))
                }
            }
            let r: Future<Int, Never> = a.futureFlatMap { value in
                Future { promise in
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                        promise(.success(value * value))
                    }
                }
            }
            
            let cancellable = r.sink { value in
                XCTAssertEqual(value, 9)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 3.0)
            
            cancellable.cancel()
        }
    }
}
