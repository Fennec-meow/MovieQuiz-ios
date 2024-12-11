import Foundation



extension DateFormatter {
    static let defaultDateTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY hh:mm"
        return dateFormatter
    }()
    
    extension Date {
        var dateTimeString: String { DateFormatter.defaultDateTime.string(from: self) }
    }
}
