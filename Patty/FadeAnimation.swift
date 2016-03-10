//
//  SlideAnimation.swift
//  Patty
//
//  Created by Ben on 22/12/2015.
//  Copyright © 2015 Ben Deckys @ jTribe. All rights reserved.
//

//  <INSERT MIT LICENCE CRAP>

import UIKit
import Foundation

class FadeAnimation: NSObject, NavigationControllerAnimator {
	
	let width: CGFloat = UIScreen.mainScreen().bounds.size.width
	
	var slideMovement: CGFloat = 0
	var offsetAdjustment: CGFloat = 0
	
	override convenience init() {
		self.init(slideMovement: 100)
	}
	
	init(slideMovement: CGFloat) {
		super.init()
		
		self.slideMovement = slideMovement
		
		offsetAdjustment = ((width-(width * 0.25))/width)*100
	}
	
	func prepareForAnimation(viewController: UIViewController) {
		viewController.view.alpha = 0.0
	}
	
	func animate(viewController: UIViewController, withProgress: CGFloat) {
		let alpha = slideMovement*(withProgress/offsetAdjustment)
		viewController.view.alpha = alpha
	}
	
	func cleanUp(viewController: UIViewController) {
		viewController.view.alpha = 1.0
	}
	
}
