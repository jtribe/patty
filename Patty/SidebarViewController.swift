//
//  SidebarViewController.swift
//  Patty
//
//  Created by Ben on 22/12/2015.
//  Copyright © 2015 Ben Deckys @ jTribe. All rights reserved.
//

//  <INSERT MIT LICENCE CRAP>

import UIKit

class SidebarViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView?
	
	private var selectedView: UIView?
	private var footerView: UIView?
	private var headerView: UIView?
	
	let userDefaults = NSUserDefaults.standardUserDefaults()
	
	private var dataSource: [String] = ["Main", "Secondary"]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView?.scrollIndicatorInsets = UIEdgeInsets(top: 44.0, left: 0.0, bottom: 60.0, right: UIScreen.mainScreen().bounds.size.width * 0.25)
		
		footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView!.frame.size.width, height: 60.0))
		headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView!.frame.size.width, height: 44.0))
		
		tableView?.tableFooterView = footerView
		tableView?.tableHeaderView = headerView
		tableView?.backgroundColor = UIColor.clearColor()
		tableView?.separatorStyle = .None
		tableView?.separatorInset = UIEdgeInsetsZero
		
		tableView?.registerNib(UINib(nibName: "SidebarTableViewCell", bundle: nil), forCellReuseIdentifier: "SidebarCell")
		
		view.backgroundColor = UIColor(red: 209.0/255.0, green: 154.0/255.0, blue: 213.0/255.0, alpha: 1.0)
		
		selectedView = UIView(frame: .zero)
		selectedView?.backgroundColor = UIColor(red: 150.0/255.0, green: 110.0/255.0, blue: 153.0/255.0, alpha: 1.0)
	}
	
}

extension SidebarViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
			
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
			
		cell.textLabel?.text = dataSource[indexPath.row]
			
		return cell
		
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		let cell = tableView.cellForRowAtIndexPath(indexPath)
		
		if cell?.textLabel?.text == "Main" {
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let viewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController")
			
			(view.window?.rootViewController as? NavigationController)?.switchToViewController(viewController, withCompletion: nil)
		} else if cell?.textLabel?.text == "Secondary" {
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let viewController = storyboard.instantiateViewControllerWithIdentifier("SecondaryViewController")
			
			(view.window?.rootViewController as? NavigationController)?.switchToViewController(viewController, withCompletion: nil)
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 60.0
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource.count
	}
	
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		
		cell.textLabel?.textColor = .whiteColor()
		cell.textLabel?.font = UIFont.boldSystemFontOfSize(18)
		cell.backgroundColor = UIColor.clearColor()
		cell.contentView.backgroundColor = UIColor.clearColor()
		cell.selectedBackgroundView = selectedView
	}
	
}
