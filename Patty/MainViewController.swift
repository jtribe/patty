//
//  MainViewController.swift
//  Patty
//
//  Created by Ben on 24/02/2016.
//  Copyright © 2016 Ben. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, NavigationControllerDelegate {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor(red: 250.0/255.0, green: 215.0/255.0, blue: 17.0/255.0, alpha: 1.0)
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func shouldShowLeftMenu() {}
	func shouldShowRightMenu() {}
	func shouldShowAccessoryMenu() {}
	
}
