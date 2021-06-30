import Foundation

public struct CollatzGenerator: AsyncSequence {

    public let value: Int
    public typealias Element = Int

    public init(value: Int) {
        self.value = value
    }

    public struct AsyncIterator: AsyncIteratorProtocol {

        var initalCheck = true
        var value: Int
        var current: Int = 0

        public mutating func next() async -> Int? {
            if value != current && initalCheck {
                current = value
                initalCheck = false
                return current
            }

            if !current.isValidCollatzNumber {
                return nil
            }
            
            if current.isOdd {
                current = processOdd(number: current)
                return current
            } else if current.isEven {
                current = processEven(number: current)
                return current
            } else {
                return nil
            }
        }

        func processOdd(number: Int) -> Int {
            return (number * 3) + 1
        }

        func processEven(number: Int) -> Int {
            return number / 2
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(value: value)
    }
}

public extension Int {

    var isValidCollatzNumber: Bool {
        return self > 1
    }

    var isEven: Bool {
        return (self % 2 == 0)
    }

    var isOdd: Bool {
        return (self % 2 != 0)
    }

    func isFirstTask() -> Bool {
        return self == 1
    }

    func isLastTask(taskNumber: Int) -> Bool {
        return self == taskNumber
    }
}
