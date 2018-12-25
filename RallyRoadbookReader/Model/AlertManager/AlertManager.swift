//
//  Alert.swift
//  RallyRoadbookReader
//
//  Created by Eliot Gravett on 2018/12/24.
//  Copyright © 2018 C205. All rights reserved.
//

import Foundation
import UIKit
import SwiftEntryKit

@objc @objcMembers class AlertManager: NSObject {
    private var isDarkTheme: Bool = false

    private static var buttonFont: UIFont {
        return messageFont.withSize(messageFont.pointSize - 2)
    }
    private static var titleFont: UIFont {
        return messageFont.withSize(messageFont.pointSize + 4)
    }
    private static var messageFont: UIFont {
        let width = CGFloat.minimum(UIScreen.main.bounds.width, UIScreen.main.bounds.height);

        var fontSize: CGFloat = 16
        switch width {
        case 0..<375: fontSize = 16
        case 375..<500: fontSize = 20
        case 500..<1000: fontSize = 26
        default: fontSize = 36
        }
        return UIFont(name: "RussoOne", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    private static var maxWidth: CGFloat {
        let width = CGFloat.minimum(UIScreen.main.bounds.width, UIScreen.main.bounds.height);
        switch width {
        case 0..<375: return 260
        case 375..<500: return 320
        case 500..<1000: return 480
        default: return 850
        }
    }
    private static var ekAttributes: EKAttributes {
        var attributes = EKAttributes()

        attributes.positionConstraints.safeArea = .empty(fillSafeArea: false)
        attributes.windowLevel = .alerts
        attributes.displayDuration = .infinity
        attributes.hapticFeedbackType = .success
        attributes.positionConstraints = .float
        attributes.position = .center
        attributes.roundCorners = .all(radius: 10)
        attributes.entryBackground = .color(color: .black)
        attributes.screenBackground = .color(color: UIColor(white: 100.0 / 255.0, alpha: 0.5))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10))
        attributes.border = .value(color: .red, width: 5)
        attributes.scroll = .disabled
        attributes.entranceAnimation = .init(scale: .init(from: 0.9, to: 1, duration: 0.3, spring: .init(damping: 1, initialVelocity: 0)), fade: .init(from: 0, to: 1, duration: 0.3))
        attributes.exitAnimation = .init(fade: .init(from: 1, to: 0, duration: 0.2))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.65, spring: .init(damping: 0.8, initialVelocity: 0))))
        attributes.positionConstraints.size = .init(width: .offset(value: 24), height: .intrinsic)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: maxWidth), height: .intrinsic)

        return attributes
    }

    public static func dismiss() {
        SwiftEntryKit.dismiss()
    }

    public static func toast(_ message: String, title: String? = nil, image: String? = nil) {
        let title = EKProperty.LabelContent(text: title?.uppercased() ?? "", style: .init(font: buttonFont, color: .white))
        let description = EKProperty.LabelContent(text: message, style: .init(font: buttonFont.withSize(buttonFont.pointSize - 2), color: .lightGray))
        var imageContent: EKProperty.ImageContent?
        if let imageName = image {
            imageContent = .init(image: UIImage(named: imageName)!, size: CGSize(width: 35, height: 35))
        }

        let simpleMessage = EKSimpleMessage(image: imageContent, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        let contentView = EKNotificationMessageView(with: notificationMessage)

        var attributes = ekAttributes
        attributes.position = .top
        attributes.screenBackground = .clear
        attributes.roundCorners = .none
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
        attributes.border = .none
        attributes.entranceAnimation = .init(translate: .init(duration: 0.2, anchorPosition: .top))
        attributes.exitAnimation = .init(translate: .init(duration: 0.2, anchorPosition: .top))
        attributes.positionConstraints.size = .init(width: .fill, height: .intrinsic)
        attributes.positionConstraints.maxSize = .screen
        attributes.displayDuration = 2

        SwiftEntryKit.display(entry: contentView, using: attributes)
    }

    public static func alert(_ message: String, title: String? = nil, imageName: String? = nil) {
        var image: EKProperty.ImageContent?
        if let imageName = imageName {
            image = EKProperty.ImageContent(imageName: imageName, size: CGSize(width: 25, height: 25), contentMode: .scaleAspectFit)
        }
        let title = EKProperty.LabelContent(text: title?.uppercased() ?? "", style: .init(font: titleFont, color: .white, alignment: .center))
        let description = EKProperty.LabelContent(text: message.uppercased(), style: .init(font: messageFont, color: .lightGray, alignment: .center))

        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)

        let okButtonLabel = EKProperty.LabelContent(text: "OKAY", style: .init(font: buttonFont, color: .white))
        let okButton = EKProperty.ButtonContent(label: okButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: UIColor.white.withAlphaComponent(0.1)) {
            SwiftEntryKit.dismiss()
        }
        let buttonsBarContent = EKProperty.ButtonBarContent(with: okButton, separatorColor: .red, expandAnimatedly: false)

        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)
        let contentView = EKAlertMessageView(with: alertMessage)

        var attributes = ekAttributes
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches

        SwiftEntryKit.display(entry: contentView, using: attributes)
    }

    public static func confirm(_ message: String, title: String? = nil, negative: String? = "CANCEL", positive: String? = "OKAY", confirmed: (() -> Void)? = nil) {
        let title = EKProperty.LabelContent(text: title?.uppercased() ?? "", style: .init(font: titleFont, color: .white, alignment: .center))
        let description = EKProperty.LabelContent(text: message.uppercased(), style: .init(font: messageFont, color: .lightGray, alignment: .center))

        let simpleMessage = EKSimpleMessage(title: title, description: description)

        let cancelButtonLabel = EKProperty.LabelContent(text: negative?.uppercased() ?? "CANCEL", style: .init(font: buttonFont, color: .lightGray))
        let cancelButton = EKProperty.ButtonContent(label: cancelButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: UIColor.white.withAlphaComponent(0.1)) {
            SwiftEntryKit.dismiss()
        }

        let okButtonLabel = EKProperty.LabelContent(text: positive?.uppercased() ?? "OKAY", style: .init(font: buttonFont, color: .white))
        let okButton = EKProperty.ButtonContent(label: okButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: UIColor.white.withAlphaComponent(0.1)) {
            confirmed?()
            SwiftEntryKit.dismiss()
        }
        let buttonsBarContent = EKProperty.ButtonBarContent(with: cancelButton, okButton, separatorColor: .red, expandAnimatedly: false)

        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)
        let contentView = EKAlertMessageView(with: alertMessage)

        var attributes = ekAttributes
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches

        SwiftEntryKit.display(entry: contentView, using: attributes)
    }

    public static func input(_ message: String, title: String? = nil, placeHolder: String? = nil, image: String? = nil, negative: String? = "CANCEL", positive: String? = "SUBMIT", confirmed: ((_ text: String?) -> Void)? = nil) {

        let title = EKProperty.LabelContent(text: title?.uppercased() ?? "", style: .init(font: titleFont, color: .white))
        let description = EKProperty.LabelContent(text: message.uppercased(), style: .init(font: messageFont, color: .lightGray))

        let simpleMessage = EKSimpleMessage(title: title, description: description)

        let emailPlaceholder = EKProperty.LabelContent(text: placeHolder ?? "EMAIL ADDRESS", style: .init(font: buttonFont, color: .lightGray))
        let textField = EKProperty.TextFieldContent(
            keyboardType: .emailAddress,
            placeholder: emailPlaceholder,
            textStyle: .init(font: buttonFont, color: .white),
            leadingImage: image == nil ? nil : UIImage(named: image!),
            bottomBorderColor: .clear)

        let cancelButtonLabel = EKProperty.LabelContent(text: negative?.uppercased() ?? "CANCEL", style: .init(font: buttonFont, color: .lightGray))
        let cancelButton = EKProperty.ButtonContent(label: cancelButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: UIColor.white.withAlphaComponent(0.1)) {
            SwiftEntryKit.dismiss()
        }

        let okButtonLabel = EKProperty.LabelContent(text: positive?.uppercased() ?? "SEND", style: .init(font: buttonFont, color: .white))
        let okButton = EKProperty.ButtonContent(label: okButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: UIColor.white.withAlphaComponent(0.1)) {
            confirmed?(textField.textContent)
        }
        let buttonsBarContent = EKProperty.ButtonBarContent(with: cancelButton, okButton, separatorColor: .red, expandAnimatedly: false)

        let contentView = FormMessageView(with: simpleMessage, textFieldsContent: [textField], buttonBarContent: buttonsBarContent, estimatedWidth: maxWidth)

        var attributes = ekAttributes
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.positionConstraints.keyboardRelation = .bind(offset: .init(bottom: 15, screenEdgeResistance: 0))
        attributes.lifecycleEvents.didAppear = {
            contentView.becomeFirstResponder(with: 0)
        }

        SwiftEntryKit.display(entry: contentView, using: attributes, presentInsideKeyWindow: true)
    }
}
