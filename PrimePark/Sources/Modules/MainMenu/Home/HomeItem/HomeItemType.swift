import UIKit

enum HomeItemType {
    case security
    case pass
    case parking
    case charges
    case carwash
    case cleaning
    case drycleaning
    case services
    case help
    case news
    case restaurants
    case market
    case different

    var title: String {
        switch self {
        case .security:
            return "home.item.security"
        case .pass:
            return "home.item.pass"
        case .parking:
            return "home.item.parking"
        case .charges:
            return "home.item.charges"
        case .carwash:
            return "home.item.carwash"
        case .cleaning:
            return "home.item.cleaning"
        case .drycleaning:
            return "home.item.drycleaning"
        case .services:
            return "home.item.services"
        case .help:
            return "home.item.help"
        case .news:
            return "home.item.news"
        case .restaurants:
            return "home.item.restaurants"
        case .market:
            return "home.item.market"
        case .different:
            return "home.item.different"
        }
    }

    var image: UIImage? {
        UIImage(named: "home-item-\(self)")
    }
}
