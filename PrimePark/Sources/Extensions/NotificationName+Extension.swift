//
//  NotificationName+Extension.swift
//  NotificationName+Extension
//
//  Created by Vanjo Lutik on 18.11.2021.
//

import Foundation

extension Notification.Name {
    static let didEnterBackground = Notification.Name(rawValue: "didEnterBackgroundNotification")
    static let willEnterForeground = Notification.Name(rawValue: "willEnterForegroundNotification")
}
