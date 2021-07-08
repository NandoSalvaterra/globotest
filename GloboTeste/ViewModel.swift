//
//  ViewModel.swift
//  GloboTeste
//
//  Created by Luiz Fernando Salvaterra on 30/06/21.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject {

    func executeCollatzSequence(number: Int) async -> [Int] {
        var collatzNumbers: [Int] = []
        for await collatzNumber in CollatzGenerator(value: number) {
            collatzNumbers.append(collatzNumber)
        }
        return collatzNumbers
    }

    func getCollatzHighestNumber(startNumber: Int, endNumber: Int) async -> Int {
        print(Thread.current)
        var highestSequence: [Int] = []
        var highestSequenceNumber: Int = 0
        for number in startNumber...endNumber {
            let collatzCollection = await executeCollatzSequence(number: number)
            print("Sequencia Collatz gerada para o numero \(number) e contem \(collatzCollection.count) elementos.")
            if collatzCollection.count > highestSequence.count {
                highestSequence = collatzCollection
                highestSequenceNumber = number
            }
        }
        return highestSequenceNumber
    }

    func execute(maxNumber: Int, numberOfTasks: Int) async -> Int {
        let highestSequenceNumber = await withTaskGroup(of: Int.self) { group -> Int in
            var number: Int = 0
            for taskNumber in 1...numberOfTasks {
                let taskRangeNumbers = getRangeNumbers(maxNumber: maxNumber, taskNumber: taskNumber, numberOfTasks: numberOfTasks)
                group.async { await self.getCollatzHighestNumber(startNumber: taskRangeNumbers.0, endNumber: taskRangeNumbers.1) }
            }
            for await value in group {
                if value > number {
                    print("Maior valor da task é : \(value)")
                    number = value
                }
            }
            return number
        }
        print("Maior valor do grupo de tasks é : \(highestSequenceNumber)")
        return highestSequenceNumber
    }

    func getRangeNumbers(maxNumber: Int, taskNumber: Int, numberOfTasks: Int) -> (Int, Int) {
        let partialNumber =  maxNumber / numberOfTasks
        if taskNumber.isFirstTask() {
            return (0, partialNumber)
        } else if taskNumber.isLastTask(taskNumber: numberOfTasks) {
            return (((partialNumber * taskNumber) - partialNumber), maxNumber)
        } else {
            return (((partialNumber * taskNumber) - partialNumber), (partialNumber * taskNumber))
        }
    }
}



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
