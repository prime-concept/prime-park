import Foundation
import OneSignal

extension Notification.Name {
    static let loggedIn = Notification.Name("loggedIn")
    static let changeBLEConfiguration = Notification.Name("changeBLEConfiguration")
    static let languageHasChanged = Notification.Name("languageHasChanged")
}

final class LocalAuthService {
    private static let accessTokenKey = "accessTokenKey"
    private static let authorizedUserKey = "authorizedUserJSONKey"
    private static let configurationsKey = "configurationsKey"
    private static let defaultRoomKey = "defaultRoomKey"
    private static let helpChatIDKey = "helpChatIDKey"
    private static let securityChatIDKey = "securityChatIDKey"
    private static let choosenLanguage = "choosenLanguage"

    static var shared: LocalAuthService = {
        let instance = LocalAuthService()
        return instance
    }()

    private lazy var defaults = UserDefaults.standard
    private var privateUser: User?
    private var privateAccessToken: AccessToken?
    private var privateConfig: [BLEConfig]?
    private var privateRoom: Room?
    private var privateHelpChatID: String?
    private var privateSecurityChatID: String?
    private var privateChoosenLanguage: Language?

    private var authorizedUser: User? {
        get {
            if let user = privateUser {
                return user
            }
            guard let jsonData = self.defaults.value(forKey: Self.authorizedUserKey) as? Data else {
                return nil
            }
            let jsonDecoder = JSONDecoder()
            return try? jsonDecoder.decode(User.self, from: jsonData)
        }
        set {
            self.privateUser = newValue
            let jsonEncoder = JSONEncoder()
            let jsonData = try? jsonEncoder.encode(newValue)
            self.defaults.set(jsonData, forKey: Self.authorizedUserKey)
        }
    }

    private var accessToken: AccessToken? {
        get {
            if let token = privateAccessToken {
                return token
            }
            guard let jsonData = self.defaults.value(forKey: Self.accessTokenKey) as? Data else {
                return nil
            }
            let jsonDecoder = JSONDecoder()
            return try? jsonDecoder.decode(AccessToken.self, from: jsonData)
        }
        set {
            self.privateAccessToken = newValue
            let jsonEncoder = JSONEncoder()
            let jsonData = try? jsonEncoder.encode(newValue)
            self.defaults.set(jsonData, forKey: Self.accessTokenKey)
        }
    }

    private var bleConfigurations: [BLEConfig]? {
        get {
            if let config = privateConfig {
                return config
            }
            guard let jsonData = self.defaults.value(forKey: Self.configurationsKey) as? Data else {
                return nil
            }
            let jsonDecoder = JSONDecoder()
            return try? jsonDecoder.decode([BLEConfig].self, from: jsonData)
        }
        set {
            self.privateConfig = newValue
            let jsonEncoder = JSONEncoder()
            let jsonData = try? jsonEncoder.encode(newValue)
            self.defaults.set(jsonData, forKey: Self.configurationsKey)
        }
    }

    private var choosenRoom: Room? {
        get {
            if let room = privateRoom {
                return room
            }
            guard let jsonData = self.defaults.value(forKey: Self.defaultRoomKey) as? Data else {
                return nil
            }
            let jsonDecoder = JSONDecoder()
            return try? jsonDecoder.decode(Room.self, from: jsonData)
        }
        set {
            self.privateRoom = newValue
            let jsonEncoder = JSONEncoder()
            let jsonData = try? jsonEncoder.encode(newValue)
            self.defaults.set(jsonData, forKey: Self.defaultRoomKey)
        }
    }

    private var helpChatIDValue: String? {
        get {
            if let id = privateHelpChatID {
                return id
            }
            guard let jsonData = self.defaults.value(forKey: Self.helpChatIDKey) as? Data else {
                return nil
            }
            let jsonDecoder = JSONDecoder()
            return try? jsonDecoder.decode(String.self, from: jsonData)
        }
        set {
            self.privateHelpChatID = newValue
            let jsonEncoder = JSONEncoder()
            let jsonData = try? jsonEncoder.encode(newValue)
            self.defaults.set(jsonData, forKey: Self.helpChatIDKey)
        }
    }

    private var securityChatIDValue: String? {
        get {
            if let id = privateSecurityChatID {
                return id
            }
            guard let jsonData = self.defaults.value(forKey: Self.securityChatIDKey) as? Data else {
                return nil
            }
            let jsonDecoder = JSONDecoder()
            return try? jsonDecoder.decode(String.self, from: jsonData)
        }
        set {
            self.privateSecurityChatID = newValue
            let jsonEncoder = JSONEncoder()
            let jsonData = try? jsonEncoder.encode(newValue)
            self.defaults.set(jsonData, forKey: Self.securityChatIDKey)
        }
    }
    
    private var choosenLanguageValue: Language? {
        get {
            if let language = privateChoosenLanguage {
                return language
            }
            guard let jsonData = self.defaults.value(forKey: Self.choosenLanguage) as? Data else {
                guard let currentLanguageStr = Locale.current.languageCode else { return nil }
                return Language.convertToLanguage(currentLanguageStr)
            }
            let jsonDecoder = JSONDecoder()
            return try? jsonDecoder.decode(Language.self, from: jsonData)
        }
        set {
            self.privateChoosenLanguage = newValue
            let jsonEncoder = JSONEncoder()
            let jsonData = try? jsonEncoder.encode(newValue)
            self.defaults.set(jsonData, forKey: Self.choosenLanguage)
            self.defaults.synchronize()
        }
    }

    var isAuthorized: Bool {
        self.accessToken != nil
    }

    var user: User? {
        self.authorizedUser
        /*let tempUser = self.authorizedUser
        if let rooms = tempUser?.rooms {
            self.defaultApartment(rooms)
        }
        return tempUser*/
    }

    var token: AccessToken? {
        self.accessToken
    }

	var room: Room? {
		Config.resolve(
		   prod: self.apartment,
		   stage: self.user?.defaultRoom
	   )
	}

    var apartment: Room? {
        self.choosenRoom
    }

    var bleConfiguration: BLEConfig? {
        guard let room = choosenRoom else { return nil }
        let array = self.bleConfigurations?.filter({ $0.room == room.id })
        return array?.first
    }

    var helpChatID: String? {
        self.helpChatIDValue
    }

    var securityChatID: String? {
        self.securityChatIDValue
    }
    // swiftlint:disable all
    var choosenLanguage: Language? {
        self.choosenLanguageValue
    }

    init() {
        //self.defaults = UserDefaults.standard
    }

    func auth(user: User, accessToken: AccessToken) {
        self.authorizedUser = user
        self.accessToken = accessToken

        NotificationCenter.default.post(name: .loggedIn, object: nil)
    }

    func auth(user: User, accessToken: AccessToken, configs: [BLEConfig]) {
        self.authorizedUser = user
        self.accessToken = accessToken
        self.bleConfigurations = configs.filter { $0.dateExit == nil }
		
        if self.choosenRoom == nil {
            self.defaultApartment(user.parcingRooms)
        }
        
        NotificationCenter.default.post(name: .loggedIn, object: nil)
    }
    
    func changeRoomImmediately(_ room: Room) {
        choosenRoom = room
    }
    
    func updateAllWhenRoomChanged(
        configs: [BLEConfig],
        accessToken: AccessToken,
        room: Room
    ) {
        initialUpdate(configs: configs, accessToken: accessToken)
        changeRoomWithBLEUpdating(room)
    }
    
    func initialUpdate(
        configs: [BLEConfig],
        accessToken: AccessToken
    ) {
        self.bleConfigurations = configs
        updateToken(accessToken: accessToken)
    }

    func updateToken(accessToken: AccessToken) {
        self.accessToken = accessToken
    }

    private func changeRoomWithBLEUpdating(_ room: Room) {
        self.choosenRoom = room
        NotificationCenter.default.post(name: .changeBLEConfiguration, object: nil)
    }

    func deleteUser() {
        self.defaults.removeObject(forKey: Self.authorizedUserKey)
        self.defaults.removeObject(forKey: Self.accessTokenKey)
        self.defaults.removeObject(forKey: Self.configurationsKey)
        self.defaults.removeObject(forKey: Self.choosenLanguage)
        self.defaults.removeObject(forKey: Self.defaultRoomKey)
        self.defaults.removeObject(forKey: Self.helpChatIDKey)
        self.defaults.removeObject(forKey: Self.securityChatIDKey)
        privateRoom = nil
        privateUser = nil
        privateConfig = nil
        privateAccessToken = nil
        privateChoosenLanguage = nil
        privateHelpChatID = nil
        privateSecurityChatID = nil
        IssuesTypeService.shared.deleteIssuesTypes()
        BLEService.clearSettings()
        BLEService().removeCurrentTemporaryDirectory()
        OneSignal.deleteTag("id")
    }

    func addHelpChatID(_ chatID: String) {
        self.helpChatIDValue = chatID
    }

    func addSecurityChatID(_ chatID: String) {
        self.securityChatIDValue = chatID
    }
    
    func updateUser(user: User) {
        self.authorizedUser = user
    }
    
    func changeChoosenLanguage(_ language: Language) {
        self.choosenLanguageValue = language
        NotificationCenter.default.post(name: .languageHasChanged, object: nil, userInfo: ["numberOfLanguage": language.rawValue])
    }
    
    func getCurrentLocale() -> Locale {
        let language = choosenLanguage?.rawValue
        if language == 0 {
            return Locale(identifier: "ru_RU")
        } else {
            return Locale(identifier: "en_US")
        }
    }

    private func defaultApartment(_ rooms: [Room]) {
        let inhabitantArray = rooms.filter { $0.getRole == .resident }
        if !inhabitantArray.isEmpty {
            self.privateRoom = inhabitantArray[0]
            self.choosenRoom = self.privateRoom
            return
        }
        let cohabitantArray = rooms.filter { $0.getRole == .cohabitant }
        if !cohabitantArray.isEmpty {
            #warning("Индекс 1 действителен только для номера 96, для остальных 0")
            self.choosenRoom = cohabitantArray[0]
            self.choosenRoom = self.privateRoom
            return
        }
        self.choosenRoom = rooms[0]
        self.choosenRoom = self.privateRoom
    }
}
