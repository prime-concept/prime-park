import Foundation

final class IssuesTypeService {
    enum IssueName: String {
        case furniture = "Мебель в коридор"
        case wifi = "Интернет и IP-телевидение"
        case smartHome = "Умный дом"
        case gsm = "Усиление сотовой связи"
        case repair = "Ремонт квартиры"
        case primeParkFurniture = "Мебель PrimePark"
        case pantries = "Кладовые"
        case dryWash = "Химчистка"
        case cleaning = "Клининг"
        case carWash = "Автомойка"
        
        case creationPrivateValetParking = "Private Valet Parking, создание"
    }
    
    static var shared: IssuesTypeService = {
        let instance = IssuesTypeService()
        return instance
    }()

    init() {}

    private(set) var types: [IssueType] = []
    
    func deleteIssuesTypes() {
        types = []
    }

    func addTypes(list: [IssueType]) {
        self.types = list
    }

    func getDrycleaningType() -> IssueType? {
        let drycleaningTypes = types.filter({ $0.name == "Химчистка" })
        if !drycleaningTypes.isEmpty {
            return drycleaningTypes.first
        }
        return nil
    }

    func getCleaningType() -> IssueType? {
        let cleaningTypes = types.filter({ $0.name == "Клининг" })
        if !cleaningTypes.isEmpty {
            return cleaningTypes.first
        }
        return nil
    }

    func getCarwashType() -> IssueType? {
        let carwashTypes = types.filter({ $0.name == "Автомойка" })
        if !carwashTypes.isEmpty {
            return carwashTypes.first
        }
        return nil
    }
    
    func getSomeType(_ name: IssueName) -> IssueType? {
        var all = types.map { $0.subtypes }.flatMap { $0 }
        all.append(contentsOf: types)
        let someTypes = all.filter { $0.name.contains(name.rawValue) }
        if !someTypes.isEmpty {
            return someTypes.first
        }
        return nil
    }

    func getType(at id: String) -> IssueType? {
        for type in types {
            if type.id == id {
                return type
            }
            for subtype in type.subtypes
            where subtype.id == id {
                return subtype
            }
        }
        return nil
    }
}
