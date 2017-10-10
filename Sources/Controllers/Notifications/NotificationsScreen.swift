////
///  NotificationsScreen.swift
//

@objc
protocol NotificationsScreenDelegate {
    func activatedCategory(_ filter: String)
}

class NotificationsScreen: UIView {

    private let filterAllButton = NotificationsScreen.filterButton(title: "All")
    private let filterCommentsButton = NotificationsScreen.filterButton(image: .comments)
    private let filterMentionButton = NotificationsScreen.filterButton(title: "@")
    private let filterHeartButton = NotificationsScreen.filterButton(image: .heart)
    private let filterRepostButton = NotificationsScreen.filterButton(image: .repost)
    private let filterInviteButton = NotificationsScreen.filterButton(image: .invite)

    private class func filterButton() -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = .defaultFont()
        button.setTitleColor(.white, for: .selected)
        button.setTitleColor(.greyA, for: .normal)
        button.setBackgroundImage(UIImage.imageWithColor(.black), for: .selected)
        button.setBackgroundImage(UIImage.imageWithColor(.greyE5), for: .normal)
        return button
    }
    private class func filterButton(image interfaceImage: InterfaceImage) -> UIButton {
        let button = filterButton()
        button.setImage(interfaceImage.normalImage, for: .normal)
        button.setImage(interfaceImage.whiteImage, for: .selected)
        button.imageView!.contentMode = .scaleAspectFit
        return button
    }
    private class func filterButton(title: String) -> UIButton {
        let button = filterButton()
        button.setTitle(title, for: .normal)
        return button
    }

    weak var delegate: NotificationsScreenDelegate?
    let filterBar = NotificationsFilterBar()
    let streamContainer = UIView()

    var navBarVisible = true

    override init(frame: CGRect) {

        filterMentionButton.titleLabel!.font = .defaultFont(16)

        super.init(frame: frame)
        backgroundColor = .white
        self.addSubview(streamContainer)

        for (button, action) in [
            (filterAllButton, "allButtonTapped:"),
            (filterCommentsButton, "commentsButtonTapped:"),
            (filterMentionButton, "mentionButtonTapped:"),
            (filterHeartButton, "heartButtonTapped:"),
            (filterRepostButton, "repostButtonTapped:"),
            (filterInviteButton, "inviteButtonTapped:"),
        ] {
            filterBar.addSubview(button)
            button.addTarget(self, action: Selector(action), for: .touchUpInside)
        }
        filterBar.selectButton(filterAllButton)
        self.addSubview(filterBar)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        positionFilterBar()
        streamContainer.frame = self.bounds.fromTop()
            .with(height: self.frame.height)
    }

    func allButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.all.rawValue)
    }

    func commentsButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.comments.rawValue)
    }

    func mentionButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.mention.rawValue)
    }

    func heartButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.heart.rawValue)
    }

    func repostButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.repost.rawValue)
    }

    func inviteButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.relationship.rawValue)
    }
}


// MARK: Filter Bar
extension NotificationsScreen {

    func selectFilterButton(_ filterType: NotificationFilterType) {
        switch filterType {
        case .all: filterBar.selectButton(filterAllButton)
        case .comments: filterBar.selectButton(filterCommentsButton)
        case .mention: filterBar.selectButton(filterMentionButton)
        case .heart: filterBar.selectButton(filterHeartButton)
        case .repost: filterBar.selectButton(filterRepostButton)
        case .relationship: filterBar.selectButton(filterInviteButton)
        }
    }

    private func positionFilterBar() {
        filterBar.frame = self.bounds.with(height: NotificationsFilterBar.Size.height)
        if navBarVisible {
            filterBar.frame.origin.y = 0
        }
        else {
            filterBar.frame.origin.y = -NotificationsFilterBar.Size.height
        }
    }

}
