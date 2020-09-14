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
}
