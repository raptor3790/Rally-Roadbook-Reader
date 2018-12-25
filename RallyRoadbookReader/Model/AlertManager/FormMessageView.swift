//
//  FormMessageView.swift
//  RallyRoadbookReader
//
//  Created by Eliot Gravett on 2018/12/24.
//  Copyright © 2018 C205. All rights reserved.
//

import UIKit
import SwiftEntryKit

@objc @objcMembers class FormMessageView: UIView {
    private let margin: CGFloat = 20

    // MARK: Props

    private var estimatedWidth: CGFloat = 0
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let scrollView = UIScrollView()
    private var textFieldsContent: [EKProperty.TextFieldContent]
    private var textFieldViews: [EKTextField] = []
    private var buttonBarView: EKButtonBarView!

    // MARK: Setup

    public init(with simpleMessage: EKSimpleMessage, textFieldsContent: [EKProperty.TextFieldContent], buttonBarContent: EKProperty.ButtonBarContent, estimatedWidth: CGFloat) {
        self.estimatedWidth = estimatedWidth
        self.textFieldsContent = textFieldsContent
        super.init(frame: UIScreen.main.bounds)
        setupScrollView()
        setupSimpleMessage(with: simpleMessage)
        setupTextFields(with: textFieldsContent)
        setupButton(with: buttonBarContent)
        setupTapGestureRecognizer()
        scrollView.layoutIfNeeded()
        set(.height, of: scrollView.contentSize.height + margin, priority: .defaultHigh)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup tap gesture
    private func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized))
        tapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.set(.width, of: estimatedWidth)
        scrollView.layoutToSuperview(.centerX, .bottom)
        scrollView.layoutToSuperview(.top, offset: margin)
        scrollView.layoutToSuperview(.height, offset: -margin)
    }

    private func setupSimpleMessage(with simpleMessage: EKSimpleMessage) {
        if !simpleMessage.title.text.isEmpty {
            scrollView.addSubview(titleLabel)
            titleLabel.layoutToSuperview(.top)
            titleLabel.layoutToSuperview(axis: .horizontally, offset: margin)
            titleLabel.layoutToSuperview(.width, offset: -margin * 2)
            titleLabel.forceContentWrap(.vertically)
            titleLabel.text = simpleMessage.title.text
            titleLabel.font = simpleMessage.title.style.font
            titleLabel.textColor = simpleMessage.title.style.color
            titleLabel.textAlignment = simpleMessage.title.style.alignment
            titleLabel.numberOfLines = simpleMessage.title.style.numberOfLines
        }
        if !simpleMessage.description.text.isEmpty {
            scrollView.addSubview(messageLabel)
            if simpleMessage.title.text.isEmpty {
                messageLabel.layoutToSuperview(.top)
            } else {
                messageLabel.layout(.top, to: .bottom, of: titleLabel, offset: margin)
            }
            messageLabel.layoutToSuperview(axis: .horizontally, offset: margin)
            messageLabel.layoutToSuperview(.width, offset: -margin * 2)
            messageLabel.forceContentWrap(.vertically)
            messageLabel.text = simpleMessage.description.text
            messageLabel.font = simpleMessage.description.style.font
            messageLabel.textColor = simpleMessage.description.style.color
            messageLabel.textAlignment = simpleMessage.description.style.alignment
            messageLabel.numberOfLines = simpleMessage.description.style.numberOfLines
        }
    }

    private func setupTextFields(with textFieldsContent: [EKProperty.TextFieldContent]) {
        guard !textFieldsContent.isEmpty else {
            return
        }

        var textFieldIndex = 0
        textFieldViews = textFieldsContent.map { content -> EKTextField in
            let textField = EKTextField(with: content)
            scrollView.addSubview(textField)
            textField.tag = textFieldIndex
            textField.layer.cornerRadius = 4
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.lightGray.cgColor
            textFieldIndex += 1
            return textField
        }

        if !(messageLabel.text?.isEmpty ?? true) {
            textFieldViews.first!.layout(.top, to: .bottom, of: messageLabel, offset: margin)
        } else if !(titleLabel.text?.isEmpty ?? true) {
            textFieldViews.first!.layout(.top, to: .bottom, of: titleLabel, offset: margin)
        } else {
            textFieldViews.first!.layoutToSuperview(.top)
        }
        textFieldViews.spread(.vertically, offset: 5)
        textFieldViews.layoutToSuperview(axis: .horizontally, offset: margin)
    }

    private func setupButton(with buttonBarContent: EKProperty.ButtonBarContent) {
        let buttonContents: [EKProperty.ButtonContent] = buttonBarContent.content.map {
            var buttonContent = $0
            let action = $0.action
            buttonContent.action = { [unowned self] in
                if buttonContent.label.text.lowercased() == "cancel" || self.extractTextFieldsContent() {
                    action?()
                }
            }
            return buttonContent
        }

        var buttonBarContent = buttonBarContent
        buttonBarContent.content = buttonContents

        buttonBarView = EKButtonBarView(with: buttonBarContent)
        buttonBarView.clipsToBounds = true
        scrollView.addSubview(buttonBarView)
        buttonBarView.expand()
        buttonBarView.layout(.top, to: .bottom, of: textFieldViews.last!, offset: 20)
        buttonBarView.layoutToSuperview(.width, .leading, .trailing, .bottom)
    }

    private func extractTextFieldsContent() -> Bool {
        var validate = true
        for (index, textField) in textFieldViews.enumerated() {
            textFieldsContent[index].textContent = textField.text

            let text = NSString(string: textFieldsContent[index].textContent)
            validate = validate && !text.isEmpty() && text.isValidEmail()
            textField.layer.borderColor = validate ? UIColor.lightGray.cgColor : UIColor.red.cgColor
        }
        return validate
    }

    /** Makes a specific text field the first responder */
    public func becomeFirstResponder(with textFieldIndex: Int) {
        textFieldViews[textFieldIndex].makeFirstResponder()
    }

    // Tap Gesture
    @objc func tapGestureRecognized() {
        endEditing(true)
    }
}
