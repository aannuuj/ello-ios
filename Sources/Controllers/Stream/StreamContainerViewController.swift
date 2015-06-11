//
//  StreamContainerViewController.swift
//  Ello
//
//  Created by Sean on 1/17/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import SVGKit

public class StreamContainerViewController: StreamableViewController {

    private var noiseLoaded = false

    enum Notifications : String {
        case StreamDetailTapped = "StreamDetailTappedNotification"
    }

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.svgItem("circbig") }
        set { self.tabBarItem = newValue }
    }

    @IBOutlet weak public var scrollView: UIScrollView!
    @IBOutlet weak public var navigationBar: ElloNavigationBar!
    @IBOutlet weak public var navigationBarTopConstraint: NSLayoutConstraint!

    public var streamsSegmentedControl: UISegmentedControl!
    public var streamControllerViews:[UIView] = []

    private var childStreamControllers: [StreamViewController] {
        return childViewControllers as! [StreamViewController]
    }

    override public func backGestureAction() {
        hamburgerButtonTapped()
    }

    override func setupStreamController() { /* intentially left blank */ }

    override public func viewDidLoad() {
        super.viewDidLoad()
//        println("---------PROFILING: StreamContainerVC viewDidLoad: \(NSDate().timeIntervalSinceDate(LaunchDate))")
        setupStreamsSegmentedControl()
        setupChildViewControllers()
        navigationItem.titleView = streamsSegmentedControl
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: SVGKImage(named: "burger_normal.svg").UIImage!, style: .Done, target: self, action: Selector("hamburgerButtonTapped"))
        addSearchButton()
        navigationBar.items = [navigationItem]

        let initialStream = childStreamControllers[0]
        scrollLogic.prevOffset = initialStream.collectionView.contentOffset
        initialStream.collectionView.scrollsToTop = true

        let stream = StreamKind.streamValues[0]
        Tracker.sharedTracker.streamAppeared(stream.name)
    }

    private func updateInsets() {
        for controller in self.childViewControllers as! [StreamViewController] {
            updateInsets(navBar: navigationBar, streamController: controller)
        }
    }

    override public func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationBar, visible: true, withConstraint: navigationBarTopConstraint)
        updateInsets()

        if scrollToBottom {
            for controller in childStreamControllers {
                self.scrollToBottom(controller)
            }
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationBar, visible: false, withConstraint: navigationBarTopConstraint)
        updateInsets()
    }

    public class func instantiateFromStoryboard() -> StreamContainerViewController {
        let navController = UIStoryboard.storyboardWithId(.StreamContainer) as! UINavigationController
        let streamsController = navController.topViewController
        return streamsController as! StreamContainerViewController
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let width:CGFloat = scrollView.frame.size.width
        let height:CGFloat = scrollView.frame.size.height
        var x : CGFloat = 0

        for view in streamControllerViews {
            view.frame = CGRect(x: x, y: 0, width: width, height: height)
            x += width
        }

        scrollView.contentSize = CGSize(width: width * CGFloat(count(StreamKind.streamValues)), height: height)
    }

    private func setupChildViewControllers() {
        scrollView.scrollEnabled = false
        scrollView.scrollsToTop = false
        let width:CGFloat = scrollView.frame.size.width
        let height:CGFloat = scrollView.frame.size.height

        for (index, kind) in enumerate(StreamKind.streamValues) {
            let vc = StreamViewController.instantiateFromStoryboard()
            vc.currentUser = currentUser
            vc.streamKind = kind
            vc.createCommentDelegate = self
            vc.postTappedDelegate = self
            vc.userTappedDelegate = self
            vc.streamScrollDelegate = self
            vc.collectionView.scrollsToTop = false


            vc.willMoveToParentViewController(self)

            let x = CGFloat(index) * width
            let frame = CGRect(x: x, y: 0, width: width, height: height)
            vc.view.frame = frame
            scrollView.addSubview(vc.view)
            streamControllerViews.append(vc.view)

            self.addChildViewController(vc)
            vc.didMoveToParentViewController(self)
            ElloHUD.showLoadingHudInView(vc.view)

            switch kind {
            case .Friend:
                let noResultsTitle = NSLocalizedString("Welcome to your Friends Stream!", comment: "No friend results title")
                let noResultsBody = NSLocalizedString("You aren't following anyone in Friends yet.\n\nWhen you follow someone as a Friend their posts will show up here. Ello is way more rad when you're following lots of people.\n\nUse Discover to find people you're interested in, and to find or invite your friends.", comment: "No friend results body.")
                vc.noResultsMessages = (title: noResultsTitle, body: noResultsBody)
                vc.loadInitialPage()
            case .Noise:
                let noResultsTitle = NSLocalizedString("Welcome to your Noise Stream!", comment: "No noise results title")
                let noResultsBody = NSLocalizedString("You aren't following anyone in Noise yet.\n\nWhen you follow someone as Noise their posts will show up here. Ello is way more rad when you're following lots of people.\n\nUse Discover to find people you're interested in, and to find or invite your friends.", comment: "No noise results body.")
                vc.noResultsMessages = (title: noResultsTitle, body: noResultsBody)
            default:
                break
            }
        }
    }

    private func setupStreamsSegmentedControl() {
        let control = UISegmentedControl(items: StreamKind.streamValues.map{ $0.name })
        control.addTarget(self, action: Selector("streamSegmentTapped:"), forControlEvents: .ValueChanged)
        control.frame.size.height = 19.0
        control.layer.borderWidth = 1.0
        control.selectedSegmentIndex = 0
        control.tintColor = .blackColor()
        streamsSegmentedControl = control
    }

    // MARK: - IBActions

    @IBAction func hamburgerButtonTapped() {
        let index = streamsSegmentedControl.selectedSegmentIndex
        let relationship = StreamKind.streamValues[index].relationship
        let drawer = DrawerViewController()

        self.navigationController?.pushViewController(drawer, animated: true)
    }

    @IBAction func streamSegmentTapped(sender: UISegmentedControl) {
        for controller in childStreamControllers {
            controller.collectionView.scrollsToTop = false
        }

        childStreamControllers[sender.selectedSegmentIndex].collectionView.scrollsToTop = true

        let width:CGFloat = view.bounds.size.width
        let height:CGFloat = view.bounds.size.height
        let x = CGFloat(sender.selectedSegmentIndex) * width
        let rect = CGRect(x: x, y: 0, width: width, height: height)
        scrollView.scrollRectToVisible(rect, animated: true)

        let stream = StreamKind.streamValues[sender.selectedSegmentIndex]
        Tracker.sharedTracker.streamAppeared(stream.name)

        if sender.selectedSegmentIndex == 1 && !noiseLoaded {
            noiseLoaded = true
            childStreamControllers[1].loadInitialPage()
        }
    }
}
