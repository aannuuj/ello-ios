////
///  ArtistInvitesScreen.swift
//

class ArtistInvitesScreen: StreamableScreen, ArtistInvitesScreenProtocol {
    weak var delegate: ArtistInvitesScreenDelegate?
    fileprivate var usage: ArtistInvitesViewController.Usage

    init(usage: ArtistInvitesViewController.Usage) {
        self.usage = usage
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(frame: CGRect) {
        self.usage = .loggedOut
        super.init(frame: frame)
    }

    override func style() {
        super.style()
        navigationBar.sizeClass = .large
    }

    override func arrange() {
        super.arrange()

        arrangeHomeScreenNavBar(type: .editorials(loggedIn: usage == .loggedIn), navigationBar: navigationBar)
    }
}

extension ArtistInvitesScreen: HomeScreenNavBar {

    @objc
    func homeScreenScrollToTop() {
        delegate?.scrollToTop()
    }

    @objc
    func homeScreenFollowingTapped() {
        let responder: HomeResponder? = self.findResponder()
        responder?.showFollowingViewController()
    }

    @objc
    func homeScreenDiscoverTapped() {
        let responder: HomeResponder? = self.findResponder()
        responder?.showDiscoverViewController()
    }

}
