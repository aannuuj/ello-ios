////
///  ProfileHeaderTotalCountAndBadgesCell.swift
//

import SnapKit
import PINRemoteImage

private let maxBadges = 3


class ProfileHeaderTotalCountAndBadgesCell: ProfileHeaderCell {
    static let reuseIdentifier = "ProfileHeaderTotalCountAndBadgesCell"

    private let totalCountContainer = Container()
    private let totalLabel = UILabel()
    private let badgesContainer = Container()
    private let badgeButtonsContainer = Container()
    private let moreBadgesButton = UIButton()
    private let midGrayLine = Line(orientation: .vertical, color: .greyE5)
    private var showBothConstraint: Constraint!
    private var showBadgesConstraint: Constraint!
    private var showCountConstraint: Constraint!

    struct Size {
        static let height: CGFloat = 60
        static let labelVerticalOffset: CGFloat = 3.5
        static let badgeSize = CGSize(width: 36, height: 44)
        static let imageEdgeInsets = UIEdgeInsets(top: 10, left: 6, bottom: 10, right: 6)
    }

    private var badges: [Badge] = []
    private var badgeButtons: [UIButton] = []

    func update(count: String, badges: [Badge]) {
        var showBoth = false
        var showBadges = false
        var showCount = false
        if count.isEmpty {
            midGrayLine.isVisible = false
            showBadges = true
        }
        else if badges.isEmpty {
            midGrayLine.isVisible = false
            showCount = true
        }
        else {
            midGrayLine.isVisible = true
            showBoth = true
        }
        showBothConstraint.set(isActivated: showBoth)
        showBadgesConstraint.set(isActivated: showBadges)
        showCountConstraint.set(isActivated: showCount)

        updateAttributedCountText(count)
        updateBadgeViews(badges)
    }

    override func style() {
        clipsToBounds = true
        backgroundColor = .white
        totalLabel.textAlignment = .center
    }

    override func bindActions() {
        // the badgesContainer is "swallowing" tap events, but the entire badges area *other* than
        // the badge icons should open the "all badges" view.
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(moreBadgesTapped))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        badgesContainer.addGestureRecognizer(recognizer)

        moreBadgesButton.addTarget(self, action: #selector(moreBadgesTapped), for: .touchUpInside)
    }

    override func setText() {
    }

    override func arrange() {
        contentView.addSubview(totalCountContainer)
        contentView.addSubview(badgesContainer)
        contentView.addSubview(midGrayLine)

        totalCountContainer.addSubview(totalLabel)
        badgesContainer.addSubview(moreBadgesButton)
        badgesContainer.addSubview(badgeButtonsContainer)

        totalCountContainer.snp.makeConstraints { make in
            make.leading.centerY.height.equalTo(contentView)
            make.trailing.equalTo(midGrayLine.snp.leading)
        }

        totalLabel.snp.makeConstraints { make in
            make.centerX.equalTo(totalCountContainer)
            make.centerY.equalTo(totalCountContainer).offset(Size.labelVerticalOffset)
        }

        badgesContainer.snp.makeConstraints { make in
            make.trailing.centerY.height.equalTo(contentView)
            make.leading.equalTo(midGrayLine.snp.trailing)
        }

        badgeButtonsContainer.snp.makeConstraints { make in
            make.center.height.equalTo(badgesContainer).priority(Priority.required)
        }

        moreBadgesButton.snp.makeConstraints { make in
            make.center.equalTo(badgesContainer)
        }

        midGrayLine.snp.makeConstraints { make in
            make.centerY.height.equalTo(contentView)
            showBothConstraint = make.centerX.equalTo(contentView).constraint
            showBadgesConstraint = make.leading.equalTo(contentView).constraint
            showCountConstraint = make.trailing.equalTo(contentView).constraint
        }
        showBadgesConstraint.set(isActivated: false)
        showCountConstraint.set(isActivated: false)
    }
}

extension ProfileHeaderTotalCountAndBadgesCell {

    private func updateAttributedCountText(_ count: String) {
        guard !count.isEmpty else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributedCount = NSAttributedString(count + " ", color: .black)
        let totalViewsText = NSAttributedString(InterfaceString.Profile.TotalViews, color: UIColor.greyA)
        totalLabel.attributedText = attributedCount + totalViewsText
    }

    private func updateBadgeViews(_ badges: [Badge]) {
        for view in badgeButtonsContainer.subviews {
            view.removeFromSuperview()
        }

        self.badges = badges
        badgeButtons = badges.safeRange(0 ..< maxBadges).compactMap { (badge: Badge) -> UIButton? in
            let button = UIButton()
            let imageView = PINAnimatedImageView()
            button.addTarget(self, action: #selector(badgeTapped(_:)), for: .touchUpInside)
            button.snp.makeConstraints { make in
                make.size.equalTo(Size.badgeSize)
            }
            button.imageEdgeInsets = Size.imageEdgeInsets

            if let imageURL = badge.imageURL {
                imageView.pin_setImage(from: imageURL)
            }
            else if let interfaceImage = badge.interfaceImage {
                imageView.interfaceImage = interfaceImage
            }

            button.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.edges.equalTo(button).inset(Size.imageEdgeInsets)
            }

            return button
        }
        var badgeViews: [UIView] = badgeButtons

        if badges.count > maxBadges {
            let view = UILabel()
            let remaining = badges.count - maxBadges
            view.font = UIFont.defaultFont()
            view.text = "+\(remaining.numberToHuman())"
            view.textColor = .greyA
            badgeViews.append(view)
        }

        var prevView: UIView?
        for view in badgeViews {
            badgeButtonsContainer.addSubview(view)

            view.snp.makeConstraints { make in
                make.centerY.equalTo(badgeButtonsContainer)

                if let prevView = prevView {
                    make.leading.equalTo(prevView.snp.trailing)
                }
                else {
                    make.leading.equalTo(badgeButtonsContainer)
                }
            }

            prevView = view
        }

        if let prevView = prevView {
            prevView.snp.makeConstraints { make in
                make.trailing.equalTo(badgeButtonsContainer)
            }
        }
    }
}

extension ProfileHeaderTotalCountAndBadgesCell {

    @objc
    func badgeTapped(_ sender: UIButton) {
        guard
            let buttonIndex = badgeButtons.firstIndex(of: sender)
        else { return }

        let badge = badges[buttonIndex]
        let responder: ProfileHeaderResponder? = findResponder()
        if badge.slug == "featured" {
            responder?.onCategoryBadgeTapped()
        }
        else {
            responder?.onBadgeTapped(badge.slug)
        }
    }

    @objc
    func moreBadgesTapped() {
        let responder: ProfileHeaderResponder? = findResponder()
        responder?.onMoreBadgesTapped()
    }

}
