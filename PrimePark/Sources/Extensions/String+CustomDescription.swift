//swiftlint:disable leading_whitespace
extension Array where Element == Int {
    var customDescription: String {
        guard !isEmpty else { return "..." }
        var str = ""
        self.forEach { str += "\($0), " }
        str.removeSubrange(/*str.index(before: str.endIndex)*/str.index(str.endIndex, offsetBy: -2)..<str.endIndex)
        return str
    }
}
