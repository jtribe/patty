//
//  NavigationController.swift
//  Patty
//
//  Created by Ben on 22/12/2015.
//  Copyright © 2015 Ben Deckys @ jTribe. All rights reserved.
//

//  <INSERT MIT LICENCE CRAP>

import UIKit

class NavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
	
	private var allowSameScreenSelection: Bool = true
	private var allowSwipeGesture: Bool = true
	private var allowShadow: Bool =  true
	private var slideOffset: CGFloat = UIScreen.mainScreen().bounds.size.width * 0.25
	private var panGestureOffset: CGFloat = UIScreen.mainScreen().bounds.size.width * 0.25
	private var leftMenu: UIViewController?
	private var rightMenu: UIViewController?
	private var topMenu: UIViewController?
	private var leftBarButtonItem: UIBarButtonItem?
	private var animator: NavigationControllerAnimator = FadeAnimation()
	
	private var tapGesture: UITapGestureRecognizer?
	private var panGesture: UIPanGestureRecognizer?
	private var draggingPoint: CGPoint = CGPoint(x: 0, y: 0)
	private var lastRevealedMenu: Menu?
	private var menuNeedsLayout: Bool?
	private var currentMenu: Menu?
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		delegate = self
		
		restoreNavigationBar()
		setAllowShadow(allowShadow)
		setupMenus()
		setupGestures()
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		allowCloseMenuTapGesture(false)
		if menuNeedsLayout == true {
			updateFrameAccordingToOrientation()
			
			if menuOpen() {
				let menu: Menu = .Left
				openMenu(menu, withDuration: 0, completion: nil)
			}
			menuNeedsLayout = false
		}
	}
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		
		menuNeedsLayout = true
	}
	
	private func restoreNavigationBar() {
		let backgroundImage = UIImage.imageTintedWithColor(UIImage(named: "navbackground.png")!, color: UIColor(red: 188.0/255.0, green: 182.0/255.0, blue: 254.0/255.0, alpha: 1.0))
		
		navigationBar.setBackgroundImage(backgroundImage, forBarMetrics: .Default)
		navigationBar.translucent = false
		navigationBar.barStyle = UIBarStyle.Default
		navigationBar.shadowImage = UIImage()
		navigationBar.tintColor = UIColor(red: 111.0/255.0, green: 178.0/255.0, blue: 224.0/255.0, alpha: 1.0)
		navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
	}
	
	func updateFrameAccordingToOrientation() {
		let transform: CGAffineTransform = view.transform
		leftMenu?.view.transform = transform
		leftMenu?.view.frame = initialRectForMenu()
	}
	
	func initialRectForMenu() -> CGRect {
		var rect = view.frame
		rect.origin.x = 0
		rect.origin.y = 0
		
		return rect
	}
	
	func verticalSize() -> CGFloat {
		let rect = view.frame
		return rect.size.height
	}
	
	func horizontalSize() -> CGFloat {
		let rect = view.frame
		return rect.size.width
	}
	
	func horizontalLocation() -> CGFloat {
		let rect = view.frame
		return rect.origin.x
	}
	
	func verticalLocation() -> CGFloat {
		let rect = view.frame
		return rect.origin.y
	}
	
	func setAllowShadow(allow: Bool) {
		allowShadow = allow
		
		if allow {
			view.layer.shadowColor = UIColor.blackColor().CGColor
			view.layer.shadowRadius = 0.0 // HARD SHADOW
			view.layer.shadowOpacity = 0.6
			view.layer.shadowOffset = CGSizeMake(-3, 0)
			view.layer.shadowPath = UIBezierPath(rect: view.bounds).CGPath
			view.layer.shouldRasterize = true
			view.layer.rasterizationScale = UIScreen.mainScreen().scale
		} else {
			view.layer.shadowOpacity = 0.0
			view.layer.shadowRadius = 0.0
			view.layer.shadowColor = nil
			view.layer.shadowPath = nil
			view.layer.shouldRasterize = false
			view.layer.contentsScale = UIScreen.mainScreen().scale
		}
	}
	
	func shouldDisplayMenu(menu: Menu, forViewController vc: UIViewController) -> Bool {
		if menu == .Left {
			if vc.respondsToSelector("shouldShowLeftMenu") {
				return true
			}
		} else if menu == .Right {
			
			if vc.respondsToSelector("shouldShowRightMenu") {
				return true
			}
		} else {
			if vc.respondsToSelector("shouldShowAccessoryMenu") {
				return true
			}
		}
		
		return false
	}
}

// MARK: - Setup Methods
// Expand `setupMenus()` to add a right-hand Menu.

extension NavigationController {
	private func setupMenus() {
		let menu: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SidebarViewController")
		leftMenu = menu
	}
	
	private func setupGestures() {
		hidesBarsOnSwipe = false
		interactivePopGestureRecognizer?.delegate = nil
		
		panGesture = UIPanGestureRecognizer(
			target:self,
			action: "panDetected:"
		)
		panGesture?.delegate = self
		view.addGestureRecognizer(panGesture!)
		
		tapGesture = UITapGestureRecognizer(
			target: self,
			action: "tapDetectedOnThePoppedViewController:"
		)
	}
}

// MARK: - Switch View Controller Method
// This is the function that replaces the view controller you were looking at, with the one you choose in the Sidebar

extension NavigationController {
	func switchToViewController(viewController: UIViewController, withCompletion: ((Void) -> (Void))?) {
		setViewControllers([viewController], animated: false)
		closeMenu(0.3, completion: nil)
	}
}

// MARK: - Opening & Closing Hamburger Menu
// These handle the animation of opening and closing.
// Expand `prepareMenuForDisplay()` to handle a right-hand Menu.

extension NavigationController {
	func openMenu(menu: Menu, withDuration: CGFloat, completion: ((Void) -> (Void))?) {
		allowCloseMenuTapGesture(true)
		prepareMenuForDisplay(menu)
		
		UIView.animateWithDuration(
			0.3,
			delay: 0.0,
			options: .CurveEaseOut,
			animations: { [weak self] in
				let width = self!.horizontalSize()
				let height = self!.verticalSize()
				var rect = self!.view.frame
				
				if menu == .Left {
					rect.origin.x = width - self!.slideOffset
					self?.moveHorizontallyToLocation(rect.origin.x)
				} else if menu == .Right {
					rect.origin.x = (-width) + (self!.slideOffset)
					self?.moveHorizontallyToLocation(rect.origin.x)
				} else {
					rect.origin.y = height - (self!.slideOffset)
					self?.moveVerticallyToLocation(rect.origin.y)
				}
				self?.leftMenu?.view.alpha = 1.0
			}, completion: { finished in
				if completion != nil {
					completion!()
				}
		})
	}
	
	func closeMenu(duration: CGFloat, completion: ((Void) -> (Void))?) {
		allowCloseMenuTapGesture(false)
		
		UIView.animateWithDuration(
			NSTimeInterval(duration),
			delay: 0.0,
			options: .CurveEaseOut,
			animations: { [weak self] in
				var rect = self?.view.frame
				rect?.origin.x = 0
				rect?.origin.y = 0
				self?.moveHorizontallyToLocation(rect!.origin.x)
				self?.moveVerticallyToLocation(rect!.origin.y)
				self?.leftMenu?.view.alpha = 0.0
			}, completion: { finished in
				if completion != nil {
					completion!()
				}
		})
	}
	
	func prepareMenuForDisplay(menu: Menu) {
		if menu == lastRevealedMenu {
			return
		}
		
		let menuViewController: UIViewController = leftMenu! // Change this for right-hand Menus
		let removingMenuViewController: UIViewController = leftMenu! // Change this for right-hand Menus
		
		lastRevealedMenu = menu
		
		removingMenuViewController.view.removeFromSuperview()
		menuViewController.view.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width*0.75, height: menuViewController.view.frame.size.height)
		view.window?.insertSubview(menuViewController.view, atIndex: 0)
		menuViewController.view.alpha = 0.0
		updateFrameAccordingToOrientation()
		animator.prepareForAnimation(menuViewController)
	}
	
	func menuOpen() -> Bool {
		return horizontalLocation() == 0 ? false : true
	}
	
	func menuVerticallyOpen() -> Bool {
		return verticalLocation() == 0 ? false : true
	}
	
	func moveVerticallyToLocation(location: CGFloat) {
		var rect = view.frame
		let menu: Menu = .Left
		
		rect.origin.x = 0
		rect.origin.y = location
		view.frame = rect
		updateMenuAnimation(menu)
	}
	
	func moveHorizontallyToLocation(location: CGFloat) {
		var rect = view.frame
		let menu: Menu = .Left
		
		rect.origin.x = location
		rect.origin.y = 0
		view.frame = rect
		updateMenuAnimation(menu)
	}
	
	func updateMenuAnimation(menu: Menu) {
		let progress: CGFloat = (horizontalLocation() / horizontalSize())
		animator.animate(leftMenu!, withProgress: progress)
	}
	
	func toggleMenu(menu: Menu, withCompletion completion: ((Void) -> (Void))?) {
		if menuOpen() {
			closeMenu(0.3, completion: completion)
		} else {
			openMenu(menu, withDuration: 0.3, completion: completion)
		}
	}
}

// MARK: - Overriding UINavigationController Methods

extension NavigationController {
	override func popToRootViewControllerAnimated(animated: Bool) -> [UIViewController]? {
		if menuOpen() {
			closeMenu(0.3, completion: {
				super.popToRootViewControllerAnimated(animated)
			})
		} else {
			return super.popToRootViewControllerAnimated(animated)
		}
		
		return nil
	}
	
	override func pushViewController(viewController: UIViewController, animated: Bool) {
		if menuOpen() {
			closeMenu(0.3, completion: {
				super.pushViewController(viewController, animated: animated)
			})
		} else {
			super.pushViewController(viewController, animated: animated)
		}
	}
	
	override func popToViewController(viewController: UIViewController, animated: Bool) -> [UIViewController]? {
		if menuOpen() {
			closeMenu(0.3, completion: {
				super.popToViewController(viewController, animated: animated)
			})
		} else {
			return super.popToViewController(viewController, animated: animated)
		}
		
		return nil
	}
	
	func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
		
		var buttons: [UIBarButtonItem] = []
		
		if shouldDisplayMenu(.Left, forViewController: viewController) {
			buttons.append(generateNavigationButtonForMenu(.Left))
		}
		
		if shouldDisplayMenu(.Right, forViewController: viewController) {
			buttons.append(generateNavigationButtonForMenu(.Right))
		}
		
		if shouldDisplayMenu(.Top, forViewController: viewController) {
			buttons.append(generateNavigationButtonForMenu(.Top))
		}
		
		viewController.navigationItem.leftBarButtonItems = buttons
	}
}

// MARK: - Hamburger Button Item

extension NavigationController {
	func generateNavigationButtonForMenu(menu: Menu) -> UIBarButtonItem {
		var selector: Selector = ""
		var buttonName: String = ""
		
		switch menu {
		case .Left:
			selector = "leftMenuSelected:"
			buttonName = "Left"
		case .Right:
			selector = "rightMenuSelected:"
			buttonName = "Right"
		case .Top:
			selector = "topMenuSelected:"
			buttonName = "Top"
		}
		
		let returnable = UIBarButtonItem(title: buttonName, style: .Done, target: self, action: selector)
		return returnable
	}
	
	func leftMenuSelected(sender: AnyObject) {
		currentMenu = .Left
		
		if menuOpen() {
			closeMenu(0.3, completion: nil)
		} else {
			openMenu(.Left, withDuration: 0.3, completion: nil)
		}
	}
	
	func rightMenuSelected(sender: AnyObject) {
		currentMenu = .Right
		
		if menuOpen() {
			closeMenu(0.3, completion: nil)
		} else {
			openMenu(.Right, withDuration: 0.3, completion: nil)
		}
	}
	
	func topMenuSelected(sender: AnyObject) {
		currentMenu = .Top
		
		if menuVerticallyOpen() {
			closeMenu(0.3, completion: nil)
		} else {
			openMenu(.Top, withDuration: 0.3, completion: nil)
		}
	}
}

// MARK: - Gesture Recognizers

extension NavigationController {
	func tapDetectedOnThePoppedViewController(recogniser: UITapGestureRecognizer) {
		closeMenu(0.3, completion: nil)
	}
	
	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
		return (touch.locationInView(view).x <= panGestureOffset) || (touch.locationInView(view).y <= panGestureOffset) ? true : false
	}
	
	// MARK: - Pan
	// ADD YOUR PANNING CODE IN HERE
	// SAMPLE CODE PROVIDED WILL PAN FOR A LEFT SIDE MENU
	
	func panDetected(panRecogniser: UIPanGestureRecognizer) {
		/*
		let translation = panRecogniser.translationInView(panRecogniser.view)
		let velocity = panRecogniser.velocityInView(panRecogniser.view)
		let movement = translation.x - draggingPoint.x
		
		if panRecogniser.state == .Began {
		draggingPoint = translation
		} else if panRecogniser.state == .Changed {
		
		var newLocationHorizontal = horizontalLocation()
		newLocationHorizontal += movement
		
		if Int(newLocationHorizontal) >= minXForDragging() && Int(newLocationHorizontal) <= maxXForDragging() {
		moveHorizontallyToLocation(newLocationHorizontal)
		}
		
		if (Int(newLocationHorizontal) > 0) {
		prepareMenuForDisplay(.Left)
		} else if (Int(newLocationHorizontal) < 0) {
		prepareMenuForDisplay(.Right)
		}
		
		draggingPoint = translation
		} else if panRecogniser.state == .Ended {
		let currentXPosition = horizontalLocation()
		let currentXOffset = currentXPosition > 0 ? currentXPosition : currentXPosition * -1
		let positiveVelocity = velocity.x > 0 ? velocity.x : velocity.x * -1
		let menu: Menu = .Left
		
		if positiveVelocity >= 1200 {
		if velocity.x > 0 {
		if currentXPosition > 0 {
		if shouldDisplayMenu(menu, forViewController: visibleViewController!) {
		openMenu(.Left, withDuration: 0.3
		, completion: nil)
		}
		} else {
		closeMenu(0.3, completion: nil)
		}
		} else {
		if currentXPosition > 0 {
		closeMenu(0.3, completion: nil)
		} else {
		if shouldDisplayMenu(menu, forViewController: visibleViewController!) {
		openMenu(menu, withDuration: 0.3, completion: nil)
		}
		}
		}
		} else {
		if currentXOffset < (horizontalSize() - slideOffset)/2 {
		closeMenu(0.3, completion: nil)
		} else {
		openMenu(.Left, withDuration: 0.3, completion: nil)
		}
		}
		}
		*/
	}
	
	// MARK: - Drag offset
	// Change this to allow for a right-hand Menu
	
	func minXForDragging() -> Int {
		return 0
	}
	
	func minYForDragging() -> Int {
		return 0
	}
	
	// MARK: - Drag limit
	// Change this to allow for a right-hand Menu
	
	func maxXForDragging() -> Int {
		guard let topViewController = topViewController else { return 0 }
		
		if shouldDisplayMenu(.Left, forViewController: topViewController) {
			return (Int(horizontalSize()) - Int(slideOffset))
		} else if shouldDisplayMenu(.Right, forViewController: topViewController) {
			return (Int(slideOffset))
		}
		
		return 0
	}
	
	func maxYForDragging() -> Int {
		guard let topViewController = topViewController else { return 0 }
		
		if shouldDisplayMenu(.Top, forViewController: topViewController) {
			return (Int(verticalSize()) - Int(slideOffset))
		}
		
		return 0
	}
	
	func allowCloseMenuTapGesture(allow: Bool) {
		guard let tapGesture = tapGesture else { return }
		
		if allow {
			interactivePopGestureRecognizer?.enabled = false
			topViewController?.view.userInteractionEnabled = false
			view.addGestureRecognizer(tapGesture)
		} else {
			interactivePopGestureRecognizer?.enabled = true
			topViewController?.view.userInteractionEnabled = true
			view.removeGestureRecognizer(tapGesture)
		}
	}
}

extension UIImage {
	class func imageTintedWithColor(imageToTint: UIImage, color: UIColor! = UIColor.whiteColor()) -> UIImage {
		var image: UIImage?
		UIGraphicsBeginImageContextWithOptions(imageToTint.size, false, UIScreen.mainScreen().scale)
		
		var rect: CGRect = CGRectZero
		rect.size = imageToTint.size
		color.set()
		
		UIRectFill(rect)
		
		image?.drawInRect(rect, blendMode: .DestinationIn, alpha: 1.0)
		image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image!
	}
}


// MARK: - Animator Protocol

protocol NavigationControllerAnimator {
	func prepareForAnimation(viewController: UIViewController)
	func animate(viewController: UIViewController, withProgress: CGFloat)
	func cleanUp(viewController: UIViewController)
}

// MARK: - Delegate

@objc protocol NavigationControllerDelegate {
	// Give an empty implementation in your View Controller for one or both of these.
	
	optional func shouldShowLeftMenu()
	optional func shouldShowRightMenu()
	optional func shouldShowAccessoryMenu()
}

// MARK: - Enums

enum Menu: Int {
	case Left = 0
	case Right = 1
	case Top = 2
}