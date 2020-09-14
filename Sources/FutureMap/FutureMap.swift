import Combine

extension Future {
    // `P` must be a publisher which receives just one value.
    private convenience init<P: Publisher>(_ publisher: P) where P.Output == Output, P.Failure == Failure {
        self.init { promise in
            var count = 0
            let keep: Keep<AnyCancellable> = .init()
            keep.value = publisher
                .handleEvents(receiveCancel: { keep.value = nil })
                .sink(receiveCompletion: { completion in
                    assert(count == 1)
                    if case .failure(let error) = completion {
                        promise(.failure(error))
                    }
                    keep.value = nil
                }, receiveValue: { value in
                    assert(count == 0)
                    count += 1
                    promise(.success(value))
                })
        }
    }
    
    public func futureAllSatisfy(_ predicate: @escaping (Output) -> Bool) -> Future<Bool, Failure> {
        Future<Bool, Failure>(allSatisfy(predicate))
    }
    
    public func futureCatch<E: Error>(_ handler: @escaping (Failure) -> Future<Output, E>) -> Future<Output, E> {
        Future<Output, E>(`catch`(handler))
    }
    
    public func futureContains(where predicate: @escaping (Output) -> Bool) -> Future<Bool, Failure> {
        Future<Bool, Failure>(contains(where: predicate))
    }
    
    public func futureFlatMap<T>(maxPublishers: Subscribers.Demand = .unlimited, _ transform: @escaping (Output) -> Future<T, Failure>) -> Future<T, Failure> {
        Future<T, Failure>(flatMap(maxPublishers: maxPublishers, transform))
    }

    public func futureMap<T>(_ transform: @escaping (Output) -> T) -> Future<T, Failure> {
        Future<T, Failure>(map(transform))
    }
    
    public func futureMapError<E: Error>(_ transform: @escaping (Failure) -> E) -> Future<Output, E> {
        Future<Output, E>(mapError(transform))
    }
    
    public func futureMax(by areInIncreasingOrder: @escaping (Output, Output) -> Bool) -> Future<Output, Failure> {
        Future<Output, Failure>(max(by: areInIncreasingOrder))
    }
    
    public func futureMin(by areInIncreasingOrder: @escaping (Output, Output) -> Bool) -> Future<Output, Failure> {
        Future<Output, Failure>(min(by: areInIncreasingOrder))
    }
    
    public func futurePrint(_ prefix: String = "", to stream: TextOutputStream? = nil) -> Future<Output, Failure> {
        Future<Output, Failure>(print(prefix, to: stream))
    }
    
    public func futureReceive<S: Scheduler>(on scheduler: S, options: S.SchedulerOptions? = nil) -> Future<Output, Failure> {
        Future<Output, Failure>(receive(on: scheduler, options: options))
    }
    
    public func futureReduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) -> T) -> Future<T, Failure> {
        Future<T, Failure>(reduce(initialResult, nextPartialResult))
    }
    
    public func futureReplaceError(with output: Output) -> Future<Output, Never> {
        Future<Output, Never>(replaceError(with: output))
    }

    public func futureReplaceNil<T>(with output: T) -> Future<T, Failure> where Output == T? {
        Future<T, Failure>(replaceNil(with: output))
    }
    
    public func futureTryAllSatisfy(_ predicate: @escaping (Output) throws -> Bool) -> Future<Bool, Error> {
        Future<Bool, Error>(tryAllSatisfy(predicate))
    }
    
    public func futureTryCatch<E: Error>(_ handler: @escaping (Failure) throws -> Future<Output, E>) -> Future<Output, Error> {
        Future<Output, Error>(tryCatch(handler))
    }
    
    public func futureTryContains(where predicate: @escaping (Output) throws -> Bool) -> Future<Bool, Error> {
        Future<Bool, Error>(tryContains(where: predicate))
    }
    
    public func futureTryMap<T>(_ transform: @escaping (Output) throws -> T) -> Future<T, Error> {
        Future<T, Error>(tryMap(transform))
    }
    
    public func futureTryMax(by areInIncreasingOrder: @escaping (Output, Output) throws -> Bool) -> Future<Output, Error> {
        Future<Output, Error>(tryMax(by: areInIncreasingOrder))
    }
    
    public func futureTryMin(by areInIncreasingOrder: @escaping (Output, Output) throws -> Bool) -> Future<Output, Error> {
        Future<Output, Error>(tryMin(by: areInIncreasingOrder))
    }
    
    func futureTryReduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) throws -> T) -> Future<T, Error> {
        Future<T, Error>(tryReduce(initialResult, nextPartialResult))
    }
}

extension Future where Output: Equatable {
    public func futureContains(_ output: Output) -> Future<Bool, Failure> {
        Future<Bool, Failure>(contains(output))
    }
}

extension Future where Output: Comparable {
    public func futureMax() -> Future<Output, Failure> {
        Future<Output, Failure>(max())
    }
    
    public func futureMin() -> Future<Output, Failure> {
        Future<Output, Failure>(min())
    }
}


private final class Keep<Value: AnyObject> {
    var value: Value?
}
