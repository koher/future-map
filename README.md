# FutureMap

_FutureMap_ provides operators for `Future` which return a `Future` instead of a `Publisher`.

```swift
let future: Future<Int, Never> = ...
let mapped: Future<Int, Never> = future.futureMap { $0 * $0 }
let cancellable = mapped.sink { value in
    print(value)
}
```

## License

[MIT](LICENSE)
