import UIKit
import ChatSDK

class ChatPalette: ThemePalette {
    static let brownColor = UIColor(hex: 0x807371)
    static let goldColor = UIColor(hex: 0xb3987a)
    static let darkBrownColor = UIColor(hex: 0x382823)
    static let lightGoldColor = UIColor(hex: 0xddcfbe)
    static let darkGoldColor = UIColor(hex: 0xaa8f59)

    var bubbleOutcomeBackground: UIColor { UIColor(hex: 0xad9478) }
    var bubbleOutcomeText: UIColor { UIColor.white.withAlphaComponent(0.8) }
    var bubbleOutcomeInfoTime: UIColor { UIColor.white.withAlphaComponent(0.8) }

    var bubbleIncomeBorder: UIColor { .clear }
    var bubbleOutcomeBorder: UIColor { .clear }

    var bubbleIncomeBackground: UIColor { UIColor(hex: 0x313131) }
    var bubbleIncomeText: UIColor { UIColor.white.withAlphaComponent(0.8) }
    var bubbleIncomeInfoTime: UIColor { UIColor(hex: 0x828082) }

    var bubbleBorder: UIColor { UIColor(hex: 0xd5d0cc) }
    var bubbleInfoPadBackground: UIColor { Self.darkBrownColor.withAlphaComponent(0.3) }
    var bubbleInfoPadText: UIColor { .white }

    var timeSeparatorText: UIColor { UIColor(hex: 0xDDDDDD) }
    var timeSeparatorBackground: UIColor { UIColor(hex: 0x282828) }

    var voiceMessageRecordingCircleTint: UIColor { .white }
    var voiceMessageRecordingCircleBackground: UIColor { UIColor(hex: 0x513932).withAlphaComponent(0.5) }
    var voiceMessageRecordingTime: UIColor { Self.darkBrownColor }
    var voiceMessageRecordingIndicator: UIColor { UIColor(hex: 0xcc2a21) }
    var voiceMessageRecordingDismissTitle: UIColor { Self.brownColor }
    var voiceMessageRecordingDismissIndicator: UIColor { Self.brownColor }

    var senderButton: UIColor { Self.goldColor }
    var senderBorderShadow: UIColor { .clear }
    var senderBackground: UIColor { UIColor(hex: 0x363636) }
    var senderPlaceholderColor: UIColor { UIColor(hex: 0x828082) }
    var senderTextColor: UIColor { .white }

    var contactIconIncomeBackground: UIColor { Self.lightGoldColor }
    var contactIconOutcomeBackground: UIColor { UIColor.white.withAlphaComponent(0.25) }
    var contactIcon: UIColor { UIColor.white }
    var contactIncomeTitle: UIColor { Self.darkBrownColor }
    var contactOutcomeTitle: UIColor { .white }
    var contactIncomePhone: UIColor { Self.brownColor }
    var contactOutcomePhone: UIColor { .white }

    var locationPickBackground: UIColor { .white }
    var locationPickTitle: UIColor { Self.darkBrownColor }
    var locationPickSubtitle: UIColor { Self.brownColor }
    var locationControlBackground: UIColor { UIColor.white.withAlphaComponent(0.5) }
    var locationControlButton: UIColor { Self.darkGoldColor }
    var locationControlBorder: UIColor { Self.lightGoldColor }
    var locationMapTint: UIColor { Self.darkGoldColor }
    var locationBubbleEmpty: UIColor { UIColor(white: 0.9, alpha: 1.0) }

    var scrollToBottomButtonTint: UIColor { Self.goldColor }
    var scrollToBottomButtonBorder: UIColor { Self.goldColor }
    var scrollToBottomButtonBackground: UIColor { .white }

    var voiceMessagePlayButton: UIColor { .white }
    var voiceMessageIncomePlayBackground: UIColor { Self.lightGoldColor }
    var voiceMessageOutcomePlayBackground: UIColor { UIColor.white.withAlphaComponent(0.25) }
    var voiceMessageIncomeTime: UIColor { Self.brownColor }
    var voiceMessageOutcomeTime: UIColor { UIColor.white.withAlphaComponent(0.8) }
    var voiceMessageIncomeProgressMain: UIColor { Self.darkGoldColor }
    var voiceMessageIncomeProgressSecondary: UIColor { Self.brownColor.withAlphaComponent(0.25) }
    var voiceMessageOutcomeProgressMain: UIColor { .white }
    var voiceMessageOutcomeProgressSecondary: UIColor { UIColor.white.withAlphaComponent(0.3) }

    var attachmentBadgeText: UIColor { .white }
    var attachmentBadgeBorder: UIColor { .clear }
    var attachmentBadgeBackground: UIColor { Self.goldColor }

    var imagePickerCheckMark: UIColor { Self.goldColor }
    var imagePickerCheckMarkBackground: UIColor { .white }
    var imagePickerSelectionOverlay: UIColor { Self.goldColor.withAlphaComponent(0.2) }
    var imagePickerPreviewBackground: UIColor { UIColor(white: 0.9, alpha: 1.0) }
    var imagePickerAlbumTitle: UIColor { .white }
    var imagePickerAlbumCount: UIColor { UIColor(hex: 0x828082) }
    var imagePickerBottomButtonTint: UIColor { Self.goldColor }
    var imagePickerBottomButtonDisabledTint: UIColor { Self.goldColor }
    var imagePickerButtonsBackground: UIColor { UIColor(hex: 0x363636) }
    var imagePickerBackground: UIColor { UIColor(hex: 0x363636) }
    var imagePickerButtonsBorderShadow: UIColor { .clear }
    var imagePickerAlbumsSeparator: UIColor { UIColor(hex: 0xe6e6e6) }

    var imageBubbleEmpty: UIColor { UIColor(white: 0.9, alpha: 1.0) }
    var imageBubbleProgress: UIColor { .white }
    var imageBubbleProgressUntracked: UIColor { UIColor.white.withAlphaComponent(0.5) }
    var imageBubbleBlurColor: UIColor { Self.darkBrownColor.withAlphaComponent(0.5) }

    var documentButtonTint: UIColor { .white }
    var documentIncomeButtonBackground: UIColor { Self.lightGoldColor }
    var documentButtonOutcomeBackground: UIColor { UIColor.white.withAlphaComponent(0.25) }
    var documentIncomeProgressBackground: UIColor { Self.brownColor }
    var documentProgressIncome: UIColor { .white }
    var documentIncomeProgressUntracked: UIColor { UIColor.white.withAlphaComponent(0.5) }
    var documentOutcomeProgressBackground: UIColor { UIColor.white.withAlphaComponent(0.9) }
    var documentOutcomeProgress: UIColor { Self.goldColor }
    var documentOutcomeProgressUntracked: UIColor { Self.goldColor.withAlphaComponent(0.5) }

    var videoInfoBackground: UIColor { Self.darkBrownColor.withAlphaComponent(0.3) }
    var videoInfoMain: UIColor { .white }

    var replySwipeBackground: UIColor { Self.brownColor.withAlphaComponent(0.2) }
    var replySwipeIcon: UIColor { Self.goldColor }

    var attachmentsPreviewRemoveItemTint: UIColor { .white }

    var replyPreviewIcon: UIColor { Self.lightGoldColor }
    var replyPreviewNameText: UIColor { Self.goldColor }
    var replyPreviewReplyText: UIColor { UIColor(hex: 0xDDDDDD) }
    var replyPreviewRemoveButton: UIColor { Self.goldColor }

    var navigationBarBackground: UIColor { UIColor(hex: 0x252525) }
    var navigationBarText: UIColor { .white }
    var navigationBarTint: UIColor { Self.goldColor }

    var replyIncomeLineBackground: UIColor { Self.goldColor }
    var replyIncomeNameText: UIColor { Self.goldColor }
    var replyIncomeContentText: UIColor { Self.darkBrownColor }
    var replyOutcomeLineBackground: UIColor { .white }
    var replyOutcomeNameText: UIColor { .white }
    var replyOutcomeContentText: UIColor { .white }

    init() { }
}

class ChatImageSet: ThemeImageSet {
    lazy var chatBackground = UIImage.pch_fromColor(UIColor(hex: 0x121212))
}

class ChatStyleProvider: StyleProvider {
    var messagesCell: MessagesCellStyleProvider.Type { ChatMessagesCellStyleProvider.self }
}

class ChatFontProvider: FontProvider {
    var timeSeparator: UIFont { .primeParkFont(ofSize: 11) }
    var locationPickTitle: UIFont { .primeParkFont(ofSize: 16) }
    var locationPickSubtitle: UIFont { .primeParkFont(ofSize: 12, weight: .light) }
    var badge: UIFont { .primeParkFont(ofSize: 17) }
    var pickerVideoDuration: UIFont { .primeParkFont(ofSize: 12) }
    var pickerAlbumTitle: UIFont { .primeParkFont(ofSize: 14) }
    var pickerAlbumCount: UIFont { .primeParkFont(ofSize: 16, weight: .medium) }
    var pickerActionsButton: UIFont { .primeParkFont(ofSize: 14, weight: .medium) }
    var previewVideoDuration: UIFont { .primeParkFont(ofSize: 12) }
    var voiceMessageRecordingTime: UIFont { .primeParkFont(ofSize: 16, weight: .light) }
    var voiceMessageRecordingTitle: UIFont { .primeParkFont(ofSize: 16, weight: .light) }
    var replyName: UIFont { .primeParkFont(ofSize: 12, weight: .medium) }
    var replyText: UIFont { .primeParkFont(ofSize: 16, weight: .light) }
    var senderPlaceholder: UIFont { .primeParkFont(ofSize: 14) }
    var senderBadge: UIFont { .primeParkFont(ofSize: 12) }
    var documentName: UIFont { .primeParkFont(ofSize: 16, weight: .light) }
    var documentSize: UIFont { .primeParkFont(ofSize: 12, weight: .light) }
    var videoInfoTime: UIFont { .primeParkFont(ofSize: 11, weight: .light) }
    var contactTitle: UIFont { .primeParkFont(ofSize: 16, weight: .light) }
    var contactPhone: UIFont { .primeParkFont(ofSize: 12, weight: .light) }
    var voiceMessageDuration: UIFont { .primeParkFont(ofSize: 11, weight: .light) }
    var messageText: UIFont { .primeParkFont(ofSize: 16) }
    var messageInfoTime: UIFont { .primeParkFont(ofSize: 11) }
    var messageReplyName: UIFont { .primeParkFont(ofSize: 12, weight: .medium) }
    var messageReplyText: UIFont { .primeParkFont(ofSize: 13, weight: .light) }
    var navigationTitle: UIFont { .primeParkFont(ofSize: 17, weight: .medium) }
    var navigationButton: UIFont { .primeParkFont(ofSize: 17) }
}

final class ChatLayoutProvider: LayoutProvider {
}

final class ChatMessagesCellStyleProvider: MessagesCellStyleProvider {
    static func updateStyle(
        of bubbleView: UIView,
        bubbleBorderLayer: CAShapeLayer,
        for meta: MessageContainerModelMeta
    ) {
        if bubbleView.bounds.isEmpty {
            return
        }

        let cornerRadiusDefault: CGFloat = 12
        let cornerRadiusSmall: CGFloat = 6

        let cornerPath: UIBezierPath
        switch meta.author {
        case .me:
            cornerPath = UIBezierPath.pch_make(
                with: bubbleView.bounds,
                topLeftRadius: cornerRadiusDefault,
                topRightRadius: cornerRadiusDefault,
                bottomLeftRadius: cornerRadiusDefault,
                bottomRightRadius: meta.isNextMessageOfSameUser ? cornerRadiusDefault : cornerRadiusSmall
            )
        case .anotherUser:
            cornerPath = UIBezierPath.pch_make(
                with: bubbleView.bounds,
                topLeftRadius: cornerRadiusDefault,
                topRightRadius: cornerRadiusDefault,
                bottomLeftRadius: meta.isNextMessageOfSameUser ? cornerRadiusDefault : cornerRadiusSmall,
                bottomRightRadius: cornerRadiusDefault
            )
        }

        let pathMask = CAShapeLayer()
        pathMask.path = cornerPath.cgPath

        bubbleView.layer.mask = pathMask
        bubbleBorderLayer.path = cornerPath.cgPath
    }
}
// swiftlint:enable force_unwrapping
