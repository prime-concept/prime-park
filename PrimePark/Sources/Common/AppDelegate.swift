import UIKit
import OneSignal
import AppTrackingTransparency
import FBSDKCoreKit
//import YandexMobileMetrica
//import Firebase
//swiftlint:disable all

//swiftlint:disable trailing_whitespace
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        //FirebaseApp.configure()
        let libDefaults = UserDefaults.standard
        libDefaults.set(true, forKey: "LogsEnabled")
        libDefaults.set(true, forKey: "VirtualCardEnabled")
        libDefaults.set(false, forKey: "PersistedUserIdStore")
        libDefaults.set(MODE_HANDS_FREE.rawValue, forKey: "CardMode")
        libDefaults.synchronize()
        Logger.realTimeLog(true)
        if Logger.logsPaused() {
            Logger.pauseLogs()
        }
        BLEAdvertiser.backgroundProcessingEnabled(true)
        BLEAdvertiser.enableSendUserId()
        libKeyCard.hostAppDidFinishLaunching(options: launchOptions)
        print(libKeyCard.apiVersion() ?? "version unknown")
        self.requestTrackingAuthorization()
        //FirebaseApp.configure()
        //MetricService.shared.setupMetric()

        self.oneSignalSetup(launchOptions)
        self.setupAppearance()

        self.window = MainWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor(hex: 0x252525)
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = ApplicationContainerAssembly().make()
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        NotificationCenter.default.post(name: .willEnterForeground, object: nil, userInfo: nil)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
    }

    // MARK: - BLE
    func applicationDidBecomeActive(_ application: UIApplication) {
        libKeyCard.hostAppDidBecomeActive(application)
    }

    private func setupAppearance() {
        UITextField.appearance().keyboardAppearance = .dark
    }

    func applicationWillTerminate(_ application: UIApplication) {
        libKeyCard.hostAppDidWillTerminate(application)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        NotificationCenter.default.post(name: .didEnterBackground, object: nil, userInfo: nil)
        libKeyCard.hostAppDidEnterBackground(application)
    }
    
    private func requestTrackingAuthorization() {
        guard #available(iOS 14.5, *) else {
            return
        }
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    Settings.setAdvertiserTrackingEnabled(true)
                case .denied, .restricted:
                    Settings.setAdvertiserTrackingEnabled(false)
                case .notDetermined:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    // MARK: - OneSignal
    func oneSignalSetup(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // Remove this method to stop OneSignal Debugging
        //OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)

        // OneSignal initialization
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId(appId)
        // promptForPushNotifications will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
          print("User accepted notifications: \(accepted)")
        })
    }
}
