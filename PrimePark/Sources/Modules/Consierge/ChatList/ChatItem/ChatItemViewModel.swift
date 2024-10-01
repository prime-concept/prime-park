import Foundation

struct ChatItemViewModel {
    let id: String
    let name: String
    let message: String
    let phone: String
    let date: String
    let unreadMessageCount: Int?

    // swiftlint:disable line_length
    static let data = [
        ChatItemViewModel(id: "3 - 506А.", name: "Майоров Евгений", message: "Краткое описание роли из нескольких строчек. Например, владелец - это основное преимущество отдыхающихё", phone: "+7 999 999 99 99", date: "12 июля, 22:03", unreadMessageCount: 3),
        ChatItemViewModel(id: "6 - 340E.", name: "Петрова Анна", message: "Краткое описание роли из нескольких строчек. Например, владелец - это основное преимущество отдыхающихё", phone: "+7 999 999 99 99", date: "12 июля, 22:03", unreadMessageCount: 3),
        ChatItemViewModel(id: "1 - 090C.", name: "Кантимирова Алисия", message: "Краткое описание роли из нескольких строчек. Например, владелец - это основное преимущество отдыхающихё", phone: "+7 999 999 99 99", date: "12 июля, 22:03", unreadMessageCount: nil),
        ChatItemViewModel(id: "4 - 496У.", name: "Вертрухин Иван", message: "Краткое описание роли из нескольких строчек. Например, владелец - это основное преимущество отдыхающихё", phone: "+7 999 999 99 99", date: "12 июля, 22:03", unreadMessageCount: nil),
        ChatItemViewModel(id: "8 - 2800Е.", name: "Самойлова Ольга", message: "Краткое описание роли из нескольких строчек. Например, владелец - это основное преимущество отдыхающихё", phone: "+7 999 999 99 99", date: "12 июля, 22:03", unreadMessageCount: nil),
        ChatItemViewModel(id: "1 - 307Л.", name: "Кудеси Мария", message: "Краткое описание роли из нескольких строчек. Например, владелец - это основное преимущество отдыхающихё", phone: "+7 999 999 99 99", date: "12 июля, 22:03", unreadMessageCount: nil)
    ]
}
