import Foundation

extension Date {
    var formattedString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm:ss"
        formatter.timeZone = .current
        return formatter.string(from: self)
    }
}
