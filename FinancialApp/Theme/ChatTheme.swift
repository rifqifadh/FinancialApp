//
//  ChatTheme.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//

import SwiftUI
import Foundation

struct ChatThemeKey: EnvironmentKey {
    public static let defaultValue = ChatTheme()
}

extension EnvironmentValues {
    @Entry var chatTheme = ChatTheme()
}

extension View {
    
    func chatTheme(_ theme: ChatTheme) -> some View {
        self.environment(\.chatTheme, theme)
    }
    
    func chatTheme(
        colors: ChatTheme.Colors = .init(),
        images: ChatTheme.Images = .init()
    ) -> some View {
        self.environment(\.chatTheme, ChatTheme(colors: colors, images: images))
    }
}


struct ChatTheme {
    public let colors: ChatTheme.Colors
    public let style: ChatTheme.Style
    public let images: ChatTheme.Images
    
    public init(
        colors: ChatTheme.Colors = .init(),
        images: ChatTheme.Images = .init(),
        style: ChatTheme.Style = .init()
    ) {
        self.style = style
        self.images = images
        
        // if background images have been set then override the mainBG color to be clear
        self.colors = if images.background != nil {
            ChatTheme.Colors(copy: colors, mainBG: .clear)
        } else {
            colors
        }
    }
    
    init(accentColor: Color, images: ChatTheme.Images) {
        self.init(
            colors: .init(
                mainTint: accentColor,
                messageMyBG: accentColor,
                messageMyTimeText: Color.white.opacity(0.5),
                sendButtonBackground: accentColor
            ),
            images: images
        )
    }
    
    init(accentColor: Color, background: ThemedBackgroundStyle = .mixedWithAccentColor(), improveContrast: Bool) {
        let backgroundColor: Color = background.getBackgroundColor(withAccent: accentColor, improveContrast: improveContrast)
        let friendMessageColor: Color = background.getFriendMessageColor(improveContrast: improveContrast, background: backgroundColor)
        self.init(
            colors: .init(
                mainBG: backgroundColor,
                mainTint: accentColor,
                messageMyBG: accentColor,
                messageMyText: Color.white,
                messageMyTimeText: Color.white.opacity(0.5),
                messageFriendBG: friendMessageColor,
                inputBG: friendMessageColor,
                menuBG: backgroundColor,
                sendButtonBackground: accentColor
            )
        )
    }
    
    struct Colors {
        public var mainBG: Color
        public var mainTint: Color
        public var mainText: Color
        public var mainCaptionText: Color
        
        public var messageMyBG: Color
        public var messageMyText: Color
        public var messageMyTimeText: Color
        
        public var messageFriendBG: Color
        public var messageFriendText: Color
        public var messageFriendTimeText: Color
        
        public var messageSystemBG: Color
        public var messageSystemText: Color
        public var messageSystemTimeText: Color
        
        public var inputBG: Color
        public var inputText: Color
        public var inputPlaceholderText: Color
        
        public var inputSignatureBG: Color
        public var inputSignatureText: Color
        public var inputSignaturePlaceholderText: Color
        
        public var menuBG: Color
        public var menuText: Color
        public var menuTextDelete: Color
        
        public var statusError: Color
        public var statusGray: Color
        
        public var sendButtonBackground: Color
        public var recordDot: Color
        
        public init(
            mainBG: Color = Color("mainBG"),
            mainTint: Color = Color("inputPlaceholderText"),
            mainText: Color = Color("mainText"),
            mainCaptionText: Color = Color("mainCaptionText"),
            messageMyBG: Color = Color("messageMyBG"),
            messageMyText: Color = Color.white,
            messageMyTimeText: Color = Color("messageMyTimeText"),
            messageFriendBG: Color = Color("messageFriendBG"),
            messageFriendText: Color = Color("mainText"),
            messageFriendTimeText: Color = Color("messageFriendTimeText"),
            messageSystemBG: Color = Color("messageFriendBG"),
            messageSystemText: Color = Color("mainText"),
            messageSystemTimeText: Color = Color("messageFriendTimeText"),
            inputBG: Color = Color("inputBG"),
            inputText: Color = Color("mainText"),
            inputPlaceholderText: Color = Color("inputPlaceholderText"),
            inputSignatureBG: Color = Color("inputBG"),
            inputSignatureText: Color = Color("mainText"),
            inputSignaturePlaceholderText: Color = Color("inputPlaceholderText"),
            menuBG: Color = Color("menuBG"),
            menuText: Color = Color("menuText"),
            menuTextDelete: Color = Color("menuTextDelete"),
            statusError: Color = Color("statusError"),
            statusGray: Color = Color("statusGray"),
            sendButtonBackground: Color = Color("messageMyBG"),
            recordDot: Color = Color("menuTextDelete")
        ) {
            self.mainBG = mainBG
            self.mainTint = mainTint
            self.mainText = mainText
            self.mainCaptionText = mainCaptionText
            self.messageMyBG = messageMyBG
            self.messageMyText = messageMyText
            self.messageMyTimeText = messageMyTimeText
            self.messageFriendBG = messageFriendBG
            self.messageFriendText = messageFriendText
            self.messageFriendTimeText = messageFriendTimeText
            self.messageSystemBG = messageSystemBG
            self.messageSystemText = messageSystemText
            self.messageSystemTimeText = messageSystemTimeText
            self.inputBG = inputBG
            self.inputText = inputText
            self.inputPlaceholderText = inputPlaceholderText
            self.inputSignatureBG = inputSignatureBG
            self.inputSignatureText = inputSignatureText
            self.inputSignaturePlaceholderText = inputSignaturePlaceholderText
            self.menuBG = menuBG
            self.menuText = menuText
            self.menuTextDelete = menuTextDelete
            self.statusError = statusError
            self.statusGray = statusGray
            self.sendButtonBackground = sendButtonBackground
            self.recordDot = recordDot
        }
        
        public init(copy: Colors, mainBG: Color) {
            self.mainBG = mainBG
            self.mainTint = copy.mainTint
            self.mainText = copy.mainText
            self.mainCaptionText = copy.mainCaptionText
            self.messageMyBG = copy.messageMyBG
            self.messageMyText = copy.messageMyText
            self.messageMyTimeText = copy.messageMyTimeText
            self.messageFriendBG = copy.messageFriendBG
            self.messageFriendText = copy.messageFriendText
            self.messageFriendTimeText = copy.messageFriendTimeText
            self.messageSystemBG = copy.messageSystemBG
            self.messageSystemText = copy.messageSystemText
            self.messageSystemTimeText = copy.messageSystemTimeText
            self.inputBG = copy.inputBG
            self.inputText = copy.inputText
            self.inputPlaceholderText = copy.inputPlaceholderText
            self.inputSignatureBG = copy.inputSignatureBG
            self.inputSignatureText = copy.inputSignatureText
            self.inputSignaturePlaceholderText = copy.inputSignaturePlaceholderText
            self.menuBG = copy.menuBG
            self.menuText = copy.menuText
            self.menuTextDelete = copy.menuTextDelete
            self.statusError = copy.statusError
            self.statusGray = copy.statusGray
            self.sendButtonBackground = copy.sendButtonBackground
            self.recordDot = copy.recordDot
        }
    }
    
    public struct Images {
        
        public struct Background {
            
            let safeAreaRegions: SafeAreaRegions
            let safeAreaEdges: Edge.Set
            let portraitBackgroundLight: Image
            let portraitBackgroundDark: Image
            let landscapeBackgroundLight: Image
            let landscapeBackgroundDark: Image
            
            public init(
                safeAreaRegions: SafeAreaRegions = .all,
                safeAreaEdges: Edge.Set = .all,
                portraitBackgroundLight: Image,
                portraitBackgroundDark: Image,
                landscapeBackgroundLight: Image,
                landscapeBackgroundDark: Image
            ) {
                self.safeAreaRegions = safeAreaRegions
                self.safeAreaEdges = safeAreaEdges
                self.portraitBackgroundLight = portraitBackgroundLight
                self.portraitBackgroundDark = portraitBackgroundDark
                self.landscapeBackgroundLight = landscapeBackgroundLight
                self.landscapeBackgroundDark = landscapeBackgroundDark
            }
        }
        
        public struct AttachMenu {
            public var camera: Image
            public var contact: Image
            public var document: Image
            public var location: Image
            public var photo: Image
            public var pickDocument: Image
            public var pickLocation: Image
            public var pickPhoto: Image
        }
        
        public struct InputView {
            public var add: Image
            public var arrowSend: Image
            public var sticker: Image
            public var attach: Image
            public var attachCamera: Image
            public var microphone: Image
        }
        
        public struct FullscreenMedia {
            public var play: Image
            public var pause: Image
            public var mute: Image
            public var unmute: Image
        }
        
        public struct MediaPicker {
            public var chevronDown: Image
            public var chevronRight: Image
            public var cross: Image
        }
        
        public struct Message {
            public var attachedDocument: Image
            public var error: Image
            public var muteVideo: Image
            public var pauseAudio: Image
            public var pauseVideo: Image
            public var playAudio: Image
            public var playVideo: Image
            public var read: Image
            public var sending: Image
            public var sent: Image
        }
        
        public struct MessageMenu {
            public var delete: Image
            public var edit: Image
            public var forward: Image
            public var retry: Image
            public var save: Image
            public var select: Image
        }
        
        public struct RecordAudio {
            public var cancelRecord: Image
            public var deleteRecord: Image
            public var lockRecord: Image
            public var pauseRecord: Image
            public var playRecord: Image
            public var sendRecord: Image
            public var stopRecord: Image
        }
        
        public struct Reply {
            public var cancelReply: Image
            public var replyToMessage: Image
        }
        
        public var background: Background? = nil
        
        public var backButton: Image
        public var scrollToBottom: Image
        
        public var attachMenu: AttachMenu
        public var inputView: InputView
        public var fullscreenMedia: FullscreenMedia
        public var mediaPicker: MediaPicker
        public var message: Message
        public var messageMenu: MessageMenu
        public var recordAudio: RecordAudio
        public var reply: Reply
        
        public init(
            camera: Image? = nil,
            contact: Image? = nil,
            document: Image? = nil,
            location: Image? = nil,
            photo: Image? = nil,
            pickDocument: Image? = nil,
            pickLocation: Image? = nil,
            pickPhoto: Image? = nil,
            add: Image? = nil,
            arrowSend: Image? = nil,
            sticker: Image? = nil,
            attach: Image? = nil,
            attachCamera: Image? = nil,
            microphone: Image? = nil,
            fullscreenPlay: Image? = nil,
            fullscreenPause: Image? = nil,
            fullscreenMute: Image? = nil,
            fullscreenUnmute: Image? = nil,
            chevronDown: Image? = nil,
            chevronRight: Image? = nil,
            cross: Image? = nil,
            attachedDocument: Image? = nil,
            error: Image? = nil,
            muteVideo: Image? = nil,
            pauseAudio: Image? = nil,
            pauseVideo: Image? = nil,
            playAudio: Image? = nil,
            playVideo: Image? = nil,
            read: Image? = nil,
            sending: Image? = nil,
            sent: Image? = nil,
            delete: Image? = nil,
            edit: Image? = nil,
            forward: Image? = nil,
            retry: Image? = nil,
            save: Image? = nil,
            select: Image? = nil,
            cancelRecord: Image? = nil,
            deleteRecord: Image? = nil,
            lockRecord: Image? = nil,
            pauseRecord: Image? = nil,
            playRecord: Image? = nil,
            sendRecord: Image? = nil,
            stopRecord: Image? = nil,
            cancelReply: Image? = nil,
            replyToMessage: Image? = nil,
            backButton: Image? = nil,
            scrollToBottom: Image? = nil,
            background: Background? = nil
        ) {
            self.backButton = backButton ?? Image("backArrow")
            self.scrollToBottom = scrollToBottom ?? Image(systemName: "chevron.down")
            
            self.background = background
            
            self.attachMenu = AttachMenu(
                camera: camera ?? Image("camera"),
                contact: contact ?? Image("contact"),
                document: document ?? Image("document"),
                location: location ?? Image("location"),
                photo: photo ?? Image("photo"),
                pickDocument: pickDocument ?? Image("pickDocument"),
                pickLocation: pickLocation ?? Image("pickLocation"),
                pickPhoto: pickPhoto ?? Image("pickPhoto")
            )
            
            self.inputView = InputView(
                add: add ?? Image("add"),
                arrowSend: arrowSend ?? Image("arrowSend"),
                sticker: sticker ?? Image("sticker"),
                attach: attach ?? Image("attach"),
                attachCamera: attachCamera ?? Image("attachCamera"),
                microphone: microphone ?? Image("microphone")
            )
            
            self.fullscreenMedia = FullscreenMedia(
                play: fullscreenPlay ?? Image(systemName: "play.fill"),
                pause: fullscreenPause ?? Image(systemName: "pause.fill"),
                mute: fullscreenMute ?? Image(systemName: "speaker.slash.fill"),
                unmute: fullscreenUnmute ?? Image(systemName: "speaker.fill")
            )
            
            self.mediaPicker = MediaPicker(
                chevronDown: chevronDown ?? Image("chevronDown"),
                chevronRight: chevronRight ?? Image("chevronRight"),
                cross: cross ?? Image(systemName: "xmark")
            )
            
            self.message = Message(
                attachedDocument: attachedDocument ?? Image("attachedDocument"),
                error: error ?? Image(systemName: "exclamationmark.circle.fill"),
                muteVideo: muteVideo ?? Image("muteVideo"),
                pauseAudio: pauseAudio ?? Image("pauseAudio"),
                pauseVideo: pauseVideo ?? Image(systemName: "pause.circle.fill"),
                playAudio: playAudio ?? Image("playAudio"),
                playVideo: playVideo ?? Image(systemName: "play.circle.fill"),
                read: read ?? Image(systemName: "checkmark.circle.fill"),
                sending: sending ?? Image(systemName: "clock"),
                sent: sent ?? Image(systemName: "checkmark.circle")
            )
            
            self.messageMenu = MessageMenu(
                delete: delete ?? Image("delete"),
                edit: edit ?? Image("edit"),
                forward: forward ?? Image("forward"),
                retry: retry ?? Image("retry"),
                save: save ?? Image("save"),
                select: select ?? Image("select")
            )
            
            self.recordAudio = RecordAudio(
                cancelRecord: cancelRecord ?? Image("cancelRecord"),
                deleteRecord: deleteRecord ?? Image("deleteRecord"),
                lockRecord: lockRecord ?? Image("lockRecord"),
                pauseRecord: pauseRecord ?? Image(systemName: "pause.fill"),
                playRecord: playRecord ?? Image(systemName: "play.fill"),
                sendRecord: sendRecord ?? Image("sendRecord"),
                stopRecord: stopRecord ?? Image("stopRecord")
            )
            
            self.reply = Reply(
                cancelReply: cancelReply ?? Image(systemName: "x.circle"),
                replyToMessage: replyToMessage ?? Image(systemName: "arrow.uturn.left")
            )
        }
    }
    
    public struct Style {
        public var replyOpacity: Double
        
        public init(replyOpacity: Double = 0.8) {
            self.replyOpacity = replyOpacity
        }
    }
}
