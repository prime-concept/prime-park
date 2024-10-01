import UIKit

enum AuthNumberPadType {
    case number(Int), empty, delete

    var value: String? {
        switch self {
        case .number(let value):
            return "\(value)"
        default:
            return nil
        }
    }

    var image: UIImage? {
        switch self {
        case .delete:
            return UIImage(named: "number-pad-delete-icon")
        default:
            return nil
        }
    }
}
