import Dispatch

/// Thenable represents an asynchronous operation that can be chained.
internal protocol Thenable: AnyObject {
    /// The type of the wrapped value
    associatedtype T

    /// `pipe` is immediately executed when this `Thenable` is resolved
    func pipe(to: @escaping(Result<T, Error>) -> Void)

    /// The resolved result or nil if pending.
    var result: Result<T, Error>? { get }
}

internal extension Thenable {
    /**
     The provided closure executes when this promise is fulfilled.

     This allows chaining promises. The promise returned by the provided closure is resolved before the promise returned by this closure resolves.

     - Parameter on: The dispatcher that executes the provided closure.
     - Parameter body: The closure that executes when this promise fulfills. It must return a promise.
     - Returns: A new promise that resolves when the promise returned from the provided closure resolves. For example:

           firstly {
               URLSession.shared.dataTask(.promise, with: url1)
           }.then { response in
               transform(data: response.data)
           }.done { transformation in
               //…
           }
     */
    func then<U: Thenable>(on: Dispatcher = conf.D.map, _ body: @escaping(T) throws -> U) -> Promise<U.T> {
        let rp = Promise<U.T>(.pending)
        pipe {
            switch $0 {
            case .success(let value):
                on.dispatch {
                    do {
                        let rv = try body(value)
                        guard rv !== rp else { throw PMKError.returnedSelf }
                        rv.pipe(to: rp.box.seal)
                    } catch {
                        rp.box.seal(.failure(error))
                    }
                }
            case .failure(let error):
                rp.box.seal(.failure(error))
            }
        }
        return rp
    }

    /**
     The provided closure is executed when this promise is fulfilled.

     This is like `then` but it requires the closure to return a non-promise.

     - Parameter on: The dispatcher that executes the provided closure.
     - Parameter transform: The closure that is executed when this Promise is fulfilled. It must return a non-promise.
     - Returns: A new promise that is fulfilled with the value returned from the provided closure or rejected if the provided closure throws. For example:

           firstly {
               URLSession.shared.dataTask(.promise, with: url1)
           }.map { response in
               response.data.length
           }.done { length in
               //…
           }
     */
    func map<U>(on: Dispatcher = conf.D.map, _ transform: @escaping(T) throws -> U) -> Promise<U> {
        let rp = Promise<U>(.pending)
        pipe {
            switch $0 {
            case .success(let value):
                on.dispatch {
                    do {
                        rp.box.seal(.success(try transform(value)))
                    } catch {
                        rp.box.seal(.failure(error))
                    }
                }
            case .failure(let error):
                rp.box.seal(.failure(error))
            }
        }
        return rp
    }

    /**
      The provided closure is executed when this promise is fulfilled.

      In your closure return an `Optional`, if you return `nil` the resulting promise is rejected with `PMKError.compactMap`, otherwise the promise is fulfilled with the unwrapped value.

           firstly {
               URLSession.shared.dataTask(.promise, with: url)
           }.compactMap {
               try JSONSerialization.jsonObject(with: $0.data) as? [String: String]
           }.done { dictionary in
               //…
           }.catch {
               // either `PMKError.compactMap` or a `JSONError`
           }
     */
    func compactMap<U>(on: Dispatcher = conf.D.map, _ transform: @escaping(T) throws -> U?) -> Promise<U> {
        let rp = Promise<U>(.pending)
        pipe {
            switch $0 {
            case .success(let value):
                on.dispatch {
                    do {
                        if let rv = try transform(value) {
                            rp.box.seal(.success(rv))
                        } else {
                            throw PMKError.compactMap(value, U.self)
                        }
                    } catch {
                        rp.box.seal(.failure(error))
                    }
                }
            case .failure(let error):
                rp.box.seal(.failure(error))
            }
        }
        return rp
    }

    /**
     The provided closure is executed when this promise is fulfilled.

     Equivalent to `map { x -> Void in`, but since we force the `Void` return Swift
     is happier and gives you less hassle about your closure’s qualification.

     - Parameter on: The dispatcher that executes the provided closure.
     - Parameter body: The closure that is executed when this Promise is fulfilled.
     - Returns: A new promise fulfilled as `Void` or rejected if the provided closure throws.

           firstly {
               URLSession.shared.dataTask(.promise, with: url)
           }.done { response in
               print(response.data)
           }
     */
    func done(on: Dispatcher = conf.D.return, _ body: @escaping(T) throws -> Void) -> Promise<Void> {
        let rp = Promise<Void>(.pending)
        pipe {
            switch $0 {
            case .success(let value):
                on.dispatch {
                    do {
                        try body(value)
                        rp.box.seal(.success(()))
                    } catch {
                        rp.box.seal(.failure(error))
                    }
                }
            case .failure(let error):
                rp.box.seal(.failure(error))
            }
        }
        return rp
    }

    /**
     The provided closure is executed when this promise is fulfilled.

     This is like `done` but it returns the same value that the handler is fed.
     `get` immutably accesses the fulfilled value; the returned Promise maintains that value.

     - Parameter on: The dispatcher that executes the provided closure.
     - Parameter body: The closure that is executed when this Promise is fulfilled.
     - Returns: A new promise that is fulfilled with the value that the handler is fed or rejected if the provided closure throws. For example:

           firstly {
               .value(1)
           }.get { foo in
               print(foo, " is 1")
           }.done { foo in
               print(foo, " is 1")
           }.done { foo in
               print(foo, " is Void")
           }
     */
    func get(on: Dispatcher = conf.D.return, _ body: @escaping (T) throws -> Void) -> Promise<T> {
        return map(on: on) {
            try body($0)
            return $0
        }
    }

    /**
     The provided closure is executed with promise result.

     This is like `get` but provides the Result<T> of the Promise so you can inspect the value of the chain at this point without causing any side effects.

     - Parameter on: The dispatcher that executes the provided closure.
     - Parameter body: The closure that is executed with Result of Promise.
     - Returns: A new promise that is resolved with the result that the handler is fed. For example:

     promise.tap{ print($0) }.then{ /*…*/ }
     */
    func tap(on: Dispatcher = conf.D.map, _ body: @escaping(Result<T, Error>) -> Void) -> Promise<T> {
        return Promise { seal in
            pipe { result in
                on.dispatch {
                    body(result)
                    seal.resolve(result)
                }
            }
        }
    }

    /// - Returns: a new promise chained off this promise but with its value discarded.
    func asVoid() -> Promise<Void> {
        return map(on: nil) { _ in }
    }
}

internal extension Thenable {
    /**
     - Returns: The error with which this promise was rejected; `nil` if this promise is not rejected.
     */
    var error: Error? {
        switch result {
        case .none:
            return nil
        case .some(.success):
            return nil
        case .some(.failure(let error)):
            return error
        }
    }

    /**
     - Returns: `true` if the promise has not yet resolved.
     */
    var isPending: Bool {
        return result == nil
    }

    /**
     - Returns: `true` if the promise has resolved.
     */
    var isResolved: Bool {
        return !isPending
    }

    /**
     - Returns: `true` if the promise was fulfilled.
     */
    var isFulfilled: Bool {
        return value != nil
    }

    /**
     - Returns: `true` if the promise was rejected.
     */
    var isRejected: Bool {
        return error != nil
    }

    /**
     - Returns: The value with which this promise was fulfilled or `nil` if this promise is pending or rejected.
     */
    var value: T? {
        switch result {
        case .none:
            return nil
        case .some(.success(let value)):
            return value
        case .some(.failure):
            return nil
        }
    }
}

internal extension Thenable {
    /**
     Converts a Promise or Guarantee into a promise that can be cancelled.
     - Parameter thenable: The Thenable (Promise or Guarantee) to be made cancellable.
     - Returns: A CancellablePromise that is a cancellable variant of the given Promise or Guarantee.
     */
    func cancellize(cancelContext: CancelContext? = nil) -> CancellablePromise<T> {
        return CancellablePromise(self, cancelContext: cancelContext)
     }
}


internal extension Thenable where T: Sequence {
    /**
     `Promise<[T]>` => `T` -> `U` => `Promise<[U]>`

         firstly {
             .value([1,2,3])
         }.mapValues { integer in
             integer * 2
         }.done {
             // $0 => [2,4,6]
         }
     */
    func mapValues<U>(on: Dispatcher = conf.D.map, _ transform: @escaping(T.Iterator.Element) throws -> U) -> Promise<[U]> {
        return map(on: on) { try $0.map(transform) }
    }

    /**
     `Promise<[T]>` => `T` -> `[U]` => `Promise<[U]>`

         firstly {
             .value([1,2,3])
         }.flatMapValues { integer in
             [integer, integer]
         }.done {
             // $0 => [1,1,2,2,3,3]
         }
     */
    func flatMapValues<U: Sequence>(on: Dispatcher = conf.D.map, _ transform: @escaping(T.Iterator.Element) throws -> U) -> Promise<[U.Iterator.Element]> {
        return map(on: on){ (foo: T) in
            try foo.flatMap{ try transform($0) }
        }
    }

    /**
     `Promise<[T]>` => `T` -> `U?` => `Promise<[U]>`

         firstly {
             .value(["1","2","a","3"])
         }.compactMapValues {
             Int($0)
         }.done {
             // $0 => [1,2,3]
         }
     */

    func compactMapValues<U>(on: Dispatcher = conf.D.map, _ transform: @escaping(T.Iterator.Element) throws -> U?) -> Promise<[U]> {
        return map(on: on) { foo -> [U] in
            return try foo.compactMap(transform)
        }
    }

    /**
     `Promise<[T]>` => `T` -> `Promise<U>` => `Promise<[U]>`

         firstly {
             .value([1,2,3])
         }.thenMap { integer in
             .value(integer * 2)
         }.done {
             // $0 => [2,4,6]
         }
     */
    func thenMap<U: Thenable>(on: Dispatcher = conf.D.map, _ transform: @escaping(T.Iterator.Element) throws -> U) -> Promise<[U.T]> {
        return then(on: on) {
            when(fulfilled: try $0.map(transform))
        }
    }

    /**
     `Promise<[T]>` => `T` -> `Promise<[U]>` => `Promise<[U]>`

         firstly {
             .value([1,2,3])
         }.thenFlatMap { integer in
             .value([integer, integer])
         }.done {
             // $0 => [1,1,2,2,3,3]
         }
     */
    func thenFlatMap<U: Thenable>(on: Dispatcher = conf.D.map, _ transform: @escaping(T.Iterator.Element) throws -> U) -> Promise<[U.T.Iterator.Element]> where U.T: Sequence {
        return then(on: on) {
            when(fulfilled: try $0.map(transform))
        }.map(on: nil) {
            $0.flatMap{ $0 }
        }
    }

    /**
     `Promise<[T]>` => `T` -> Bool => `Promise<[T]>`

         firstly {
             .value([1,2,3])
         }.filterValues {
             $0 > 1
         }.done {
             // $0 => [2,3]
         }
     */
    func filterValues(on: Dispatcher = conf.D.map, _ isIncluded: @escaping (T.Iterator.Element) -> Bool) -> Promise<[T.Iterator.Element]> {
        return map(on: on) {
            $0.filter(isIncluded)
        }
    }
}

internal extension Thenable where T: Collection {
    /// - Returns: a promise fulfilled with the first value of this `Collection` or, if empty, a promise rejected with PMKError.emptySequence.
    var firstValue: Promise<T.Iterator.Element> {
        return map(on: nil) { aa in
            if let a1 = aa.first {
                return a1
            } else {
                throw PMKError.emptySequence
            }
        }
    }

    func firstValue(on: Dispatcher = conf.D.map, where test: @escaping (T.Iterator.Element) -> Bool) -> Promise<T.Iterator.Element> {
        return map(on: on) {
            for x in $0 where test(x) {
                return x
            }
            throw PMKError.emptySequence
        }
    }

    /// - Returns: a promise fulfilled with the last value of this `Collection` or, if empty, a promise rejected with PMKError.emptySequence.
    var lastValue: Promise<T.Iterator.Element> {
        return map(on: nil) { aa in
            if aa.isEmpty {
                throw PMKError.emptySequence
            } else {
                let i = aa.index(aa.endIndex, offsetBy: -1)
                return aa[i]
            }
        }
    }
}

internal extension Thenable where T: Sequence, T.Iterator.Element: Comparable {
    /// - Returns: a promise fulfilled with the sorted values of this `Sequence`.
    func sortedValues(on: Dispatcher = conf.D.map) -> Promise<[T.Iterator.Element]> {
        return map(on: on){ $0.sorted() }
    }
}
