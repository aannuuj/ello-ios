//
//  ElloNavigationController.swift
//  Ello
//
//  Created by Sean on 1/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

let externalWebNotification = TypedNotification<String>(name: "externalWebNotification")

class ElloNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    var interactionController: UIPercentDrivenInteractiveTransition?
    var externalWebObserver: NotificationObserver?
    let externalWebController: UINavigationController = KINWebBrowserViewController.navigationControllerWithWebBrowser()
    var rootViewControllerName : String?
    var currentUser : User? {
        didSet { didSetCurrentUser() }
    }
    var profileResponseConfig: ResponseConfig?

    var backGesture: UIScreenEdgePanGestureRecognizer?

    enum RootViewControllers: String {
        case Notifications = "NotificationsViewController"
        case Profile = "ProfileViewController"
        case Omnibar = "OmnibarViewController"
        case Discover = "DiscoverViewController"

        func controllerInstance(user: User, responseConfig: ResponseConfig) -> BaseElloViewController {
            switch self {
            case Notifications: return NotificationsViewController()
            case Profile: return ProfileViewController(user: user, responseConfig: responseConfig)
            case Omnibar: return OmnibarViewController()
            case Discover: return DiscoverViewController()
            }
        }
    }

    func setProfileData(currentUser: User, responseConfig: ResponseConfig) {
        self.currentUser = currentUser
        self.profileResponseConfig = responseConfig
        if self.viewControllers.count == 0 {
            if let rootViewControllerName = rootViewControllerName {
                if let controller = RootViewControllers(rawValue:rootViewControllerName)?.controllerInstance(currentUser, responseConfig: responseConfig) {
                    controller.currentUser = currentUser
                    self.viewControllers = [controller]
                }
            }
        }
    }

    func didSetCurrentUser() {
        if self.viewControllers.count > 0 {
            var controllers = self.viewControllers as! [BaseElloViewController]
            for controller in controllers {
                controller.currentUser = currentUser
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)

        transitioningDelegate = self
        delegate = self

        backGesture = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleBackGesture:"))
        backGesture.map(self.view.addGestureRecognizer)

        externalWebObserver = NotificationObserver(notification: externalWebNotification) { url in
            self.showExternalWebView(url)
        }
    }

    func showExternalWebView(url: String) {
        presentViewController(externalWebController, animated: true, completion: nil)
        if let externalWebView = externalWebController.rootWebBrowser() {
            externalWebView.loadURLString(url)
        }
    }

    func handleBackGesture(gesture: UIScreenEdgePanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            interactionController = UIPercentDrivenInteractiveTransition()
            topViewController.backGestureAction()
        case .Changed:
            interactionController?.updateInteractiveTransition(gesture.percentageThroughView)
        case .Ended, .Cancelled:
            if gesture.percentageThroughView > 0.5 {
                interactionController?.finishInteractiveTransition()
            } else {
                interactionController?.cancelInteractiveTransition()
            }
            interactionController = nil
        default:
            interactionController = nil
        }
    }

}

extension ElloNavigationController: UIGestureRecognizerDelegate {

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

extension ElloNavigationController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ForwardAnimator()
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BackAnimator()
    }

    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

}

extension ElloNavigationController: UINavigationControllerDelegate {


    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        backGesture?.edges = viewController.backGestureEdges
    }

    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        switch (toVC, fromVC) {
        case (is DrawerViewController, is ProfileViewController): return defaultAnimatorForOperation(operation)
        case (is ProfileViewController, is DrawerViewController): return defaultAnimatorForOperation(operation)
        case (is DrawerViewController, _): return drawerAnimatorForOperation(operation)
        case (_, is DrawerViewController): return drawerAnimatorForOperation(operation)
        default: return defaultAnimatorForOperation(operation)
        }
    }

    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func defaultAnimatorForOperation(operation: UINavigationControllerOperation) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .Push: return ForwardAnimator()
        case .Pop: return BackAnimator()
        default: return .None
        }
    }

    func drawerAnimatorForOperation(operation: UINavigationControllerOperation) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .Push: return BackAnimator()
        case .Pop: return ForwardAnimator()
        default: return .None
        }
    }

}
