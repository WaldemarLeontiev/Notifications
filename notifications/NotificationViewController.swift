//
//  NotificationViewController.swift
//  notifications
//
//  Created by Waldemar on 20/06/2018.
//  Copyright © 2018 h7.com. All rights reserved.
//

import UIKit
import Skeleton
import SnapKit

class NotificationViewController: UIViewController {
    
    let messageTitle: String?
    let messageText: String?
    init(title: String?, text: String?) {
        self.messageTitle = title
        self.messageText = text
        super.init(nibName: nil, bundle: nil)
    }
    func addAction(_ action: NotificationAction) {
        self.actions.append(action)
    }
    func show() {
        self.addButtons()
        self.fadeIn {}
        self.animateGradient { [weak self] in
            self?.animateToMessage()
        }
    }
    
    // MARK: - Settings
    private let fadeScale: CGFloat = 0.8
    private let slideDuration: TimeInterval = 1
    private let headerColor: UIColor = .blue
    private let buttonHeight: CGFloat = 48
    
    // MARK: - UI objects
    private(set) lazy var notificationView = self.makeNotificationView()
    private(set) lazy var headerView = self.makeHeaderView()
    private(set) lazy var gradientView1 = self.makeGradientView(lowColor: UIColor.white.withAlphaComponent(0.1),
                                                                highColor: UIColor.white.withAlphaComponent(0.6),
                                                                breakColor: self.headerColor,
                                                                breakStart: 0.2,
                                                                breakEnd: 0.3)
    private(set) lazy var gradientView2 = self.makeGradientView(lowColor: UIColor.white.withAlphaComponent(0),
                                                                highColor: UIColor.white.withAlphaComponent(0.6),
                                                                breakColor: self.headerColor,
                                                                breakStart: 0.5,
                                                                breakEnd: 0.6)
    private(set) lazy var gradientView3 = self.makeGradientView(lowColor: UIColor.black.withAlphaComponent(0.05),
                                                                highColor: UIColor.black.withAlphaComponent(0),
                                                                breakColor: nil,
                                                                breakStart: nil,
                                                                breakEnd: nil)
    private(set) lazy var gradientView4 = self.makeGradientView(lowColor: UIColor.black.withAlphaComponent(0.05),
                                                                highColor: UIColor.black.withAlphaComponent(0),
                                                                breakColor: .white,
                                                                breakStart: 0.4,
                                                                breakEnd: 0.45)
    private(set) lazy var gradientView5 = self.makeGradientView(lowColor: UIColor.black.withAlphaComponent(0.05),
                                                                highColor: UIColor.black.withAlphaComponent(0),
                                                                breakColor: nil,
                                                                breakStart: nil,
                                                                breakEnd: nil)
    private(set) lazy var messageTitleLabel = self.makeMessageTitleLabel()
    private(set) lazy var messageTextLabel = self.makeMessageTextLabel()
    
    // MARK: - Constraints
    private var headerHeightConstraint: Constraint?
    private var messageTextBottomConstraint: Constraint?
    private var buttonsHeightConstraint: Constraint?

    // MARK: - Settings
    private var actions: [NotificationAction] = []
    private var buttons: [UIButton] = []
    private var dividers: [UIView] = []
    
    // MARK: - UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    // MARK: - Stubs
    required init?(coder aDecoder: NSCoder) {
        self.messageTitle = nil
        self.messageText = nil
        super.init(coder: aDecoder)
    }
}

// MARK: - UI updates
extension NotificationViewController {
    private func hide() {
        self.fadeOut { [weak self] in
            self?.remove()
        }
    }
    private func addButtons() {
        self.buttons = self.actions.map({self.makeButton(title: $0.title)})
        for (index, button) in self.buttons.enumerated() {
            self.notificationView.add(button)
            button
                .makeSuperviewInsetConstraints(left: 0, right: 0)
                .snp.makeConstraints { (make) in
                    if index > 0 {
                        make.top.equalTo(self.buttons[index - 1].snp.bottom)
                        let dividerView = self.makeDividerView()
                        self.notificationView.add(dividerView)
                        dividerView
                            .makeSuperviewInsetConstraints(left: 0, right: 0)
                            .snp.makeConstraints({ (make) in
                                make.top.equalTo(button)
                            })
                        dividerView.alpha = 0
                        self.dividers.append(dividerView)
                    }
                    if index == (self.buttons.count - 1) {
                        make.bottom.equalToSuperview()
                    }
            }
            button.alpha = 0
        }
    }
    private func fadeIn(then completion: @escaping () -> Void) {
        self.notificationView.transform = CGAffineTransform(scaleX: self.fadeScale, y: self.fadeScale)
        UIView.animate(withDuration: 0.15,
                       animations: { [weak self] in
                        self?.view.alpha = 1
                        self?.notificationView.transform = CGAffineTransform.identity
            }, completion: { (_) in
                completion()
        })
    }
    private func fadeOut(then completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.15,
                       animations: { [weak self] in
                        guard let fadeScale = self?.fadeScale else {
                            return
                        }
                        self?.view.alpha = 0
                        self?.notificationView.transform = CGAffineTransform(scaleX: fadeScale, y: fadeScale)
            }, completion: { (_) in
                completion()
        })
    }
    private func animateGradient(then completion: @escaping () -> Void) {
        self.slide(to: .right) { [weak self] (animations) in
            animations.duration = self?.slideDuration ?? 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + self.slideDuration) {
            completion()
        }
    }
    private func animateToMessage() {
        self.headerHeightConstraint?.deactivate()
        self.messageTextBottomConstraint?.activate()
        self.buttonsHeightConstraint?.update(inset: CGFloat(self.buttons.count) * self.buttonHeight)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.gradientViews.forEach({$0.alpha = 0})
            self?.messageTitleLabel.alpha = 1
            self?.messageTextLabel.alpha = 1
            self?.buttons.forEach({$0.alpha = 1})
            self?.dividers.forEach({$0.alpha = 1})
            self?.view.layoutIfNeeded()
        })
    }
    var gradientViews: [GradientContainerView] {
        return self.view.allSubviews.compactMap({($0 as? GradientContainerView)})
    }
}

// MARK: - UI actions
extension NotificationViewController {
    @objc private func buttonPressed(_ sender: UIButton) {
        self.hide()
        if let index = self.buttons.index(of: sender) {
            self.actions[index].handler?()
        }
    }
}

// MARK: - UI
extension NotificationViewController {
    private func setupUI() {
        self.view.alpha = 0
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.add(self.notificationView)
        self.notificationView.makeSuperviewCenterConstraints(xOffset: 0, yOffset: 0)
    }
    // MARK: Constructors
    private func makeNotificationView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.makeSizeConstraints(width: 280)
        view.add(self.headerView, self.gradientView3, self.gradientView4, self.gradientView5)
        self.headerView
            .makeSuperviewInsetConstraints(top: 0, left: 0, right: 0)
            .snp.makeConstraints { (make) in
                self.buttonsHeightConstraint = make.bottom.equalToSuperview().inset(96).constraint
        }
        self.gradientView3
            .makeSuperviewInsetConstraints(left: 32, right: 80)
            .snp.makeConstraints { (make) in
                make.top.equalTo(self.headerView.snp.bottom).offset(16)
        }
        self.gradientView4
            .makeSuperviewInsetConstraints(left: 32, right: 32)
            .snp.makeConstraints { (make) in
                make.top.equalTo(self.gradientView3.snp.bottom).offset(16)
        }
        self.gradientView5
            .makeSuperviewInsetConstraints(left: 32, right: 128)
            .snp.makeConstraints { (make) in
                make.top.equalTo(self.gradientView4.snp.bottom).offset(16)
        }
        return view
    }
    private func makeHeaderView() -> UIView {
        let view = UIView()
        view.backgroundColor = self.headerColor
        view.snp.makeConstraints { (make) in
            self.headerHeightConstraint = make.height.equalTo(80).constraint
        }
        view.add(self.gradientView1, self.gradientView2, self.messageTitleLabel, self.messageTextLabel)
        self.gradientView1.makeSuperviewInsetConstraints(top: 32, left: 32, right: 64)
        self.gradientView2
            .makeSuperviewInsetConstraints(left: 32, right: 32)
            .snp.makeConstraints { (make) in
                make.top.equalTo(self.gradientView1.snp.bottom).offset(16)
        }
        self.messageTitleLabel.makeSuperviewInsetConstraints(top: 16, left: 16, right: 16)
        let spacing: CGFloat = ((self.messageTitle == nil) || (self.messageText == nil)) ? 0 : 8
        self.messageTextLabel
            .makeSuperviewInsetConstraints(left: 16, right: 16)
            .snp.makeConstraints { (make) in
                make.top.equalTo(self.messageTitleLabel.snp.bottom).offset(spacing)
                self.messageTextBottomConstraint = make.bottom.equalToSuperview().inset(16).constraint
        }
        self.messageTitleLabel.alpha = 0
        self.messageTextLabel.alpha = 0
        self.messageTextBottomConstraint?.deactivate()
        return view
    }
    private func makeGradientView(lowColor: UIColor,
                                  highColor: UIColor,
                                  breakColor: UIColor? = nil,
                                  breakStart: CGFloat? = nil,
                                  breakEnd: CGFloat? = nil) -> GradientContainerView {
        let view = GradientContainerView(frame: CGRect())
        view.backgroundColor = lowColor
        view.gradientLayer.colors = [lowColor.cgColor, highColor.cgColor, lowColor.cgColor]
        if let breakColor = breakColor, let breakStart = breakStart, let breakEnd = breakEnd {
            let dummyView = UIView()
            let breakView = UIView()
            breakView.backgroundColor = breakColor
            view.add(dummyView, breakView)
            dummyView
                .makeSuperviewInsetConstraints(top: 0, bottom: 0, left: 0)
                .snp.makeConstraints { (make) in
                    make.width.equalToSuperview().multipliedBy(breakStart)
            }
            breakView
                .makeSuperviewInsetConstraints(top: 0, bottom: 0)
                .snp.makeConstraints { (make) in
                    make.left.equalTo(dummyView.snp.right)
                    make.width.equalToSuperview().multipliedBy(breakEnd - breakStart)
            }
        }
        view.makeSizeConstraints(height: 8)
        return view
    }
    private func makeMessageTitleLabel() -> UIView {
        let label = UILabel()
        label.text = self.messageTitle
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    private func makeMessageTextLabel() -> UIView {
        let label = UILabel()
        label.text = self.messageText
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    private func makeButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.makeSizeConstraints(height: self.buttonHeight)
        button.addTarget(self, action: #selector(self.buttonPressed(_:)), for: .touchUpInside)
        return button
    }
    private func makeDividerView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        view.makeSizeConstraints(height: 1)
        return view
    }
}

// MARK: - GradientsOwner
extension NotificationViewController: GradientsOwner {
    var gradientLayers: [CAGradientLayer] {
        return self.gradientViews.map({$0.gradientLayer})
    }
}

// MARK: - NotificationAction
struct NotificationAction {
    let title: String
    let handler: (() -> Void)?
}
