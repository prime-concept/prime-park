//
//  MetricService.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 19.02.2021.
//
//swiftlint:disable all
import YandexMobileMetrica
import YandexMobileMetricaCrashes

final class MetricService {
    static var shared: MetricService = {
        return MetricService()
    }()
    
    private init() {}
    
    private let profile = YMMMutableUserProfile()
    
    
    //MARK: - Setup Methods
    
    func setupMetric() {
        let configuration = YMMYandexMetricaConfiguration.init(apiKey: "48917a0d-b391-4514-a6d2-3e4b0d541dc6")
        YMMYandexMetrica.activate(with: configuration!)
    }
    
    func setupReportConfiguration() {
        //...
    }
    
    
    //MARK: - Action Method
    
    func reportEvent(_ event: MetricEvent) {
        YMMYandexMetrica.reportEvent(event.rawValue, onFailure: { (error) in
            print("DID FAIL REPORT EVENT: %@", event.rawValue)
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    func reportEvent(
        _ event: MetricEvent,
        with params: [String: AnyHashable]
    ) {
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { (error) in
            print("DID FAIL REPORT EVENT: %@", event.rawValue)
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    func sendRegisterProfile(
        with phone: String,
        with name: String
    ) {
        let phoneAttribute: YMMCustomStringAttribute = YMMProfileAttribute.customString("phone")
        profile.apply(phoneAttribute.withValue("+" + phone))
        
        profile.apply(from: [
            YMMProfileAttribute.name().withValue(name)
        ])
        
        YMMYandexMetrica.setUserProfileID("id")
        
        report()
    }
    
    func report() {
        YMMYandexMetrica.report(profile, onFailure: { (error) in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}

extension MetricService {
    func reportErrorRefreshTokenEvent(_ error: Error) {
        reportEvent(.errorRefreshToken, with: ["ERROR WHILE ACCESS TOKEN REFRESH": error.localizedDescription])
    }
}

extension MetricService {
    
    enum MetricEventParam: String {
        case code
        case isUserVerified = "is user verified"
        case authToken
        case xmlFilesCount  = "xml files count"
        
        case successMessage = "success message"
        case errorMessage   = "error message"
    }
    
    enum MetricEvent: String {
        // Metric Outside Events
        // Register Module
        case register       // register account with phone
        
        // Verifications Module
        case codeNotVerified         // verifieng app with code
        case userVerified   //
        case authToken      // fetching auth token with code
        case xml            // downloading xml configuration
        
        case loadIssues     // consierge screen
        
        case errorRefreshToken
        
        // Settings Module
        case exit           // exit account
        
        // Metric Live Events
        //...
        
    }
}

extension MetricService.MetricEventParam: CustomStringConvertible {
    var description: String {
        return self.rawValue
    }
}
