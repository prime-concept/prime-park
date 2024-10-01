//
//  Channel.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 28.04.2021.
//
//swiftlint:disable trailing_whitespace
import Foundation

final class Channel: Decodable {
    let unread: Int
    let channelId: String
    
    let content: [Channel]
    
    enum CodingKeys: String, CodingKey {
        case unread
        case channelId
        
        case content = "channels"
    }
    
    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        content = (try? container?.decode([Channel].self, forKey: .content)) ?? []
        
        unread = (try? container?.decode(Int.self, forKey: .unread)) ?? 0
        channelId = (try? container?.decode(String.self, forKey: .channelId)) ?? "nil"
    }
}

extension Channel {
    var allUnreadCount: Int {
        var count = 0
        content.forEach { count += $0.unread > 0 ? 1 : 0 }
        return count
    }
    
    var channelForIssueId: String {
        channelId.replacingOccurrences(of: "PPI", with: "")
    }
    
    func integrateWithIssues(issues: [Issue]) -> [Issue] {
        let result = issues
        for one in result {
            if let searchedChannel = content.first(where: { $0.channelForIssueId == one.id }) {
                one.channelUnreadComments = searchedChannel.unread
            }
        }
        return result
    }
}
