//
//  BLEService.swift
//  PrimePark
// swiftlint:disable all
import Foundation

protocol PPLogger {
    func log(event: String, showTime: Bool)
    func showLog()
    func clearLog()
    var fullString: String { get }
}

extension PPLogger {
    func log(event: String, showTime: Bool = false) {
        log(event: event, showTime: showTime)
    }
}

class PLogger: PPLogger {
    private var log = String()
    var fullString: String { log }
    func showLog() {
        print(log)
    }
    func clearLog() {
        log = String()
    }
    func log(event: String, showTime: Bool) {
        if showTime {
            log.append("BLEt: [\(Date().description)] \(event)\n")
        } else {
            log.append("BLEt: \(event)\n")
        }
        showLog()
    }
}

extension CBManagerState {
    func printLog() {
        print("*** Getting BLE state...")
        switch self {
        case .unknown:
            print(" -- Unknown state")
        case .resetting:
            print(" -- Resetting")
        case .unsupported:
            print(" -- Unsupported")
        case .unauthorized:
            print(" -- Unauthorized")
        case .poweredOff:
            print(" -- PoweredOff")
        case .poweredOn:
            print(" -- PoweredOn")
        @unknown default:
            print(" -- Unknown default")
        }
        print("*** END")
    }
}

enum BLEvent: String {
    case poverOn = "POWER_ON"
    case poverOff = "POWER_OFF"
    case poverReset = "POWER_RESET"
    case refreshReaderList = "REFRESH_READERS_LIST"
    case showNotification = "SHOW_NOTIFICATION"
    case hideNotification = "HIDE_NOTIFICATION"
    case advStarted = "ADVERTISEMENT_STARTED"
    case updateState = "READER_UPDATE_STATE"
    case RSSICahnged = "RSSI_CHANGED"
    case needUserIdForGroup = "USERID_FOR_GROUP_REQUIRED"
    case reaederEvent = "READER_EVENT"
    case groupSuspended = "GROUP_SUSPENDED"
    case `import` = "IMPORT"
    case groupExpared = "GROUP_EXPIRED"
    case canSendUserId = "CAN_MANUAL_SEND_USERID"
    case groupDisabled = "GROUP_DISABLED"
    case advState = "ADVERTISEMENT_STATE"
}

class BLEService: NSObject {
    var logger: PPLogger
    
    private var knownReaders: [AnyHashable : Any]
    
    private static var currentTemporaryDirectory: String?

    init(logger: PPLogger = PLogger()) {
        self.logger = logger
        self.knownReaders = [AnyHashable : Any]()
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEsmartLibraryEvent(notification:)),
            name: Notification.Name.init("ESMART_VIRTUAL_CARD_EVENT"),
            object: nil
        )
    }

    func startLibrary() {
        if BLEAdvertiser.isAdvertising() {
            return
        }
        BLEAdvertiser.startAdvertising()
        print(BLEAdvertiser.currentBTMState().printLog())
    }

    func stopLibrary() {
        if BLEAdvertiser.isAdvertising() {
            BLEAdvertiser.stopAdvertising()
            print(BLEAdvertiser.currentBTMState().printLog())
        }
    }

    func reboot() {
        stopLibrary()
        startLibrary()
    }
    
    static func clearSettings() {
        clearGroups()
    }

    func updateConfig(config: BLEConfig?) {
        stopLibrary()
        BLEService.clearGroups()
        removeCurrentTemporaryDirectory()
        if config == nil {
            logger.log(event: "ERROR: Trying to set empty config", showTime: true)
        } else {
            logger.log(event: "Set config: \(config!.configFile)\n\nwith AES_KEY: \(config!.aesKey)", showTime: true)
        }
        importConfig(config: config)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension BLEService {
    private static func clearGroups() {
        if let groups = GroupsManager.groupsList() {
            groups.forEach { print("Deleted: \(GroupsManager.deleterGroup($0))") }
        }
    }
}

extension BLEService {
    @objc
    private func handleEsmartLibraryEvent(notification: Notification) {
        let eventInfo: Dictionary = notification.userInfo ?? Dictionary()
        let eventTask: String = eventInfo["EVT"] as? String ?? ""
        let reader: ReaderProfile? = eventInfo["READER"] as? ReaderProfile
        let state: String? = eventInfo["STATE"] as? String
        let group: Group? = eventInfo["GROUP"] as? Group
        guard let event = BLEvent(rawValue: eventTask) else {
            logger.log(event: "BLE Unknown event: \(eventTask)", showTime: true)
            return
        }
        logger.log(event: event.rawValue, showTime: true)
        switch event {
        case .poverOn:
            logger.log(event: "poverOn", showTime: true)
        case .poverOff:
            logger.log(event: "Power Off", showTime: true)
        case .poverReset:
            reboot()
        case .refreshReaderList:
            logger.log(event: "refreshReaderList", showTime: true)
        case .showNotification:
            logger.log(event: "ShowNotification", showTime: true)
            if let reader = reader {
                logger.log(event: "Reader: \(reader.rssi)", showTime: true)
            }
        case .hideNotification:
            logger.log(event: "User ID sent: \(eventInfo["USERID_SENT"] ?? "NO INFOMATION") ")
        case .advStarted:
            if let error = eventInfo["ERROR"] as? String {
                logger.log(event: error)
            } else {
                logger.log(event: "DEV_ERROR: Test .advStarted implemention")
            }
        case .updateState:
            guard let state = state else {
                logger.log(event: "DEV_ERROR: State undefined")
                return
            }
            logger.log(event: "new state: \(state)")
        case .RSSICahnged:
//            guard let read = reader else {
//                logger.log(event: "DEV_ERROR: Reader undefined")
//                return
//            }
            let readerId = eventInfo["READER_IDENTIFIER"] as? String
                let reader = ReadersManager.getInstance().getReaderProfile(byId: readerId)
                var readerType: String? = nil
                if let identifier = reader?.identifier {
                    readerType = knownReaders[identifier] as? String
                }
                if readerType == nil {
                    ReaderController.determineReaderVersion(reader)
                    readerType = reader?.identifier
                }
                let flags = eventInfo["FLAGS"] as? NSNumber
                if let rssi = reader?.rssi {
                    print("RSSI[\(readerType ?? "")]: \(rssi) FLAG:\(flags?.uint32Value ?? 0)")
                }
            
            logger.log(event: "RSSI:\(reader?.rssi)")
        case .needUserIdForGroup:
            guard let grp = group else {
                logger.log(event: "Group undefined")
                return
            }
            logger.log(event: "For group: \(grp))")
        case .reaederEvent:
            guard let eventType = eventInfo["TYPE"] as? String else {
                logger.log(event: "Event type is empty")
                return
            }
            logger.log(event: "Type: \(eventType), reader: \(reader?.identifier ?? "unknown")")
        case .groupSuspended:
            guard let grp = group else {
                logger.log(event: "Group undefined")
                return
            }
            logger.log(event: "For group: \(grp))")
        case .import:
            guard let state = state else {
                logger.log(event: "Unknown state")
                return
            }
            logger.log(event: "State: \(state)")
            if state == "FINISH", let result = eventInfo["RESULT"] as? Bool {
                logger.log(event: "Import finished without error: \(result)")
                reboot()
            }
        case .groupExpared:
            guard let grp = group else {
                logger.log(event: "Unknown group expired")
                return
            }
            logger.log(event: "Group id: \(grp.groupId ?? "- none -") expired")
        case .canSendUserId:
            logger.log(event: "canSendUserId")
            break
        case .groupDisabled:
            guard let grp = group else {
                logger.log(event: "Unknown group disabled")
                return
            }
            logger.log(event: "GroupId: \(grp.groupId ?? "- none -") enabled: \(grp.enabled)")
        case .advState:
            guard let state = state else {
                logger.log(event: "Unknown state")
                return
            }
            logger.log(event: "State: \(state)")
        }
    }
}

extension BLEService {
    private func importConfig(config: BLEConfig?) {
        logger.log(event: "Start testing BLE", showTime: true)
        guard let config = config else {
            logger.log(event: "Finish testing BLE. Config is empty.", showTime: true)
            return
        }
        // Change activationID for each random import
        config.upgradeWithDefaultValues()
        logger.log(event: "Updated config: \(config.configFile.toBase64())", showTime: true)
        let aesKey = config.aesKeyData
        logger.log(event: "AESKey: \(aesKey)", showTime: true)
        KeyChain.save(key: "K_AES", data: aesKey)
        let temporaryFilename = UUID().uuidString
        let tmpDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        BLEService.currentTemporaryDirectory = tmpDirURL.absoluteString
        let fileURL = tmpDirURL.appendingPathComponent(temporaryFilename).appendingPathExtension("ESIF")
        do {
            try config.configData.write(to: fileURL, options: .atomic)
            let importResult = Importer.importFile(fileURL, batchOperation: false)
            logger.log(event: "Config saved: \(fileURL.absoluteString)", showTime: true)
            if importResult != nil {
                logger.log(event: "ImportResult = \(importResult!)", showTime: false)
            }
        } catch {
            logger.log(event: "Config saving error: \(error.localizedDescription)", showTime: true)
        }
    }
    
    private func removeCofig(by path: String?) {
        guard let validPathStr = path,
              let validUrl = URL(string: validPathStr) else { return }
        do {
            try FileManager.default.removeItem(at: validUrl)
            logger.log(event: "Remove current tmp folder before update with new one by path: \(validUrl.absoluteString)", showTime: true)
        } catch {
            logger.log(event: "Tmp folder removing error: \(error.localizedDescription)", showTime: true)
        }
    }
    
    func removeCurrentTemporaryDirectory() {
        removeCofig(by: BLEService.currentTemporaryDirectory)
    }
}

extension BLEConfig {
    /// <#Description#>
    func upgradeWithDefaultValues() {
        let configData = self.configData
        let keyData = self.aesKeyData
        let decryptedConfig = NSData.decryptedData(for: configData, withKey: keyData, error: nil)
        let decryptedString = String(data: decryptedConfig, encoding: .utf8) ?? ""
        let regexIdentifier = try! NSRegularExpression(
            pattern: #"identifier=".+""#,
            options: NSRegularExpression.Options.caseInsensitive
        )
        let regexActivationID = try! NSRegularExpression(
            pattern: #"activationID=".+""#,
            options: NSRegularExpression.Options.caseInsensitive
        )
        let regexDefaultTapArea = try! NSRegularExpression(
            pattern: #"defaultTapArea=".+""#,
            options: NSRegularExpression.Options.caseInsensitive
        )
        let regexDefaultNotificationArea = try! NSRegularExpression(
            pattern: #"defaultNotificationArea=".+""#,
            options: NSRegularExpression.Options.caseInsensitive
        )
        let range = NSMakeRange(0, decryptedString.count)
        var updatedConfig = regexActivationID.stringByReplacingMatches(
            in: decryptedString,
            options: [],
            range: range,
            withTemplate: "activationID=\"\(UUID().uuidString)\""
        )
        updatedConfig = regexDefaultTapArea.stringByReplacingMatches(
            in: updatedConfig,
            options: [],
            range: range,
            withTemplate: "defaultTapArea=\"254\""
        )
        updatedConfig = regexDefaultNotificationArea.stringByReplacingMatches(
            in: updatedConfig,
            options: [],
            range: range,
            withTemplate: "defaultNotificationArea=\"253\""
        )
        updatedConfig = regexIdentifier.stringByReplacingMatches(
            in: updatedConfig,
            options: [],
            range: range,
            withTemplate: "identifier=\"645EB172140000000000\""
        )
        guard let updatedConfigData = updatedConfig.data(using: .utf8) else { return }
        let updatedEncryptedData = NSData.encryptData(updatedConfigData, withKey: keyData)
        print(updatedEncryptedData.hexEncodedString())
        self.configFile = updatedEncryptedData.hexEncodedString()
    }
}

fileprivate extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
