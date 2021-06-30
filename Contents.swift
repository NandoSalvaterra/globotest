import Foundation
import UIKit
import PlaygroundSupport

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
            let taskRangeNumbers = generateRange(maxNumber: maxNumber, taskNumber: taskNumber, numberOfTasks: numberOfTasks)
            group.async { await getCollatzHighestNumber(startNumber: taskRangeNumbers.0, endNumber: taskRangeNumbers.1) }
        }
        for await value in group {
            if value > number {
                number = value
            }
        }
        return number
    }
    return highestSequenceNumber
}

func generateRange(maxNumber: Int, taskNumber: Int, numberOfTasks: Int) -> (Int, Int) {
    let partialNumber =  maxNumber / numberOfTasks
    if taskNumber.isFirstTask() {
        return (0, partialNumber)
    } else if taskNumber.isLastTask(taskNumber: numberOfTasks) {
        return (((partialNumber * taskNumber) - partialNumber), maxNumber)
    } else {
        return (((partialNumber * taskNumber) - partialNumber), (partialNumber * taskNumber))
    }
}

async {
    PlaygroundPage.current.needsIndefiniteExecution = true
    let highestSequenceNumber = await execute(maxNumber: 1_000_000, numberOfTasks: 4)
    print("O maior numero gerador de sequencias é o: \(highestSequenceNumber)")
    PlaygroundPage.current.finishExecution()
}
