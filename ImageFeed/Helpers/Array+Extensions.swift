import Foundation

extension Array {
    mutating func withReplaced(itemAt index: Int, newValue: Element) {
        guard index < count else { return }
        self[index] = newValue
    }
}
