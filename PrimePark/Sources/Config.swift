import Foundation

// swiftlint:disable force_unwrapping
enum Config {
	/**
	 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥
	 💥 SET TO FALSE TO DISABLE DEBUG MODE + LOGS IN PRODUCTION BUILDS 💥
	 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥
	 */

	static var isDebugEnabled = Bundle.isTestFlightOrSimulator

	static let storage = UserDefaults.standard

	private static let logUDKey = "IS_LOG_ENABLED"
	private static let debugUDKey = "IS_DEBUG_ENABLED"
	private static let prodUDKey = "IS_PROD_ENABLED"
	private static let alertsUDKey = "ARE_DEBUG_ALERTS_ENABLED"
	private static let verboseLogUDKey = "IS_VERBOSE_LOG_ENABLED"

	static let endpoint = resolve(
		prod: "https://api.primeconcept.co.uk/v3",
		stage: "https://demo.primeconcept.co.uk/v3"
	)

	static let clientID = resolve(prod: "MBiI7pUGiwg=", stage: "cHJpbWVwYXJrLmlvcw==")
	
	static let clientSecret = resolve(
		prod: "GiiK1ZQoem3wbNxCiDvKcj49BofqYQFCkqvplC8etLI=",
		stage: "cHJpbWVwYXJrLmlvcy5hc2RmdGVy"
	)

	static let chatBaseURL = resolve(
		prod: URL(string: "https://chat.primeconcept.co.uk/chat-server/v3")!,
		stage: URL(string: "https://demo.primeconcept.co.uk/chat-server/v3")!
	)

	static let chatStorageURL = resolve(
		prod: URL(string: "https://demo.primeconcept.co.uk/storage")!,
		stage: URL(string: "https://chat.primeconcept.co.uk/storage")!
	)

    static let carWashURL = resolve(
        prod: URL(string: "https://api.primeconcept.co.uk/artoflife/v4/api/primepark/yclients")!,
        stage: URL(string: "https://demo.primeconcept.co.uk/artoflife/v4/api/primepark/yclients")!
    )

	static let chatClientAppID = resolve("primeParkiOS")
	static let valetBase = resolve("https://www.o-valet.com/pub-aprs/v1?a=startReqTid")

	static var isLogEnabled: Bool {
		get { self.bool(for: logUDKey, or: isDebugEnabled)}
		set { storage.setValue(newValue, forKey: debugUDKey) }
	}

	static var isProdEnabled: Bool {
		get { self.bool(for: prodUDKey, or: true) }
		set { storage.set(newValue, forKey: prodUDKey) }
	}

	static var areDebugAlertsEnabled: Bool {
		get { self.bool(for: alertsUDKey) }
		set { storage.set(newValue, forKey: alertsUDKey) }
	}

	static var isVerboseLogEnabled: Bool {
		get { self.bool(for: verboseLogUDKey) }
		set { storage.set(newValue, forKey: verboseLogUDKey) }
	}

	static func bool(for key: String, or defaultValue: Bool = false) -> Bool {
		let value: Bool? = storage.value(forKey: key) as? Bool
		return value ?? defaultValue
	}

	static func resolve<T>(_ same: T) -> T {
		resolve(prod: same, stage: same)
	}

	static func resolve<T>(prod: T, stage: T) -> T {
		isProdEnabled ? prod : stage
	}
}
