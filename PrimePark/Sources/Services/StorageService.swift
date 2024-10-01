//
//  StorageService.swift
//  StorageService
//
//  Created by Vanjo Lutik on 17.11.2021.
//

import Foundation


final class StorageService {
    
    private init() {}
    
    private static let storage = UserDefaults(suiteName: "PrimePark.StorageService")
    
    static var shared: StorageService {
        return StorageService()
    }
    
    var didEnterBackgroundSeconds: Int? {
        get { StorageService.storage?.integer(forKey: "didEnterBackgroundSeconds") }
        set { StorageService.storage?.set(newValue, forKey: "didEnterBackgroundSeconds") }
    }
    
}
