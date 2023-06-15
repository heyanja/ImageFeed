import Foundation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()

func stringToDateFormatter(string: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    let date = formatter.date(from: string)
    return date
}

func dateToStringFormatter(date: Date?) -> String {
    guard let date = date else { return ""}
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    let string = dateFormatter.string(from: date)
    return string
}

extension Date {
    var currentDate: String { dateFormatter.string(from: Date()) }
}
