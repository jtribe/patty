## Patty
A reusable component for iOS apps that supports a left, right and top Hamburger menu. Written in Swift.

## Intro
This here's Patty. Y'all know her from The Simpsons. She's pretty...

![Oh God Why](/images/bitchin.gif)

And here she is, in all her Simpsons palette glory:

![Worst Colour Scheme ever](/images/menu.png)

![Top](/images/top_open.png)

## Usage
- Ensure you have yourself a Navigation-based iOS app setup in Xcode.

- Copy in Patty to your project _no I will not use Pods_

- Open up the Storyboard and change the Navigation Controller to `NavigationController`
-- _P.S. I was told to remove the prefix I had on all the class files_

- Add in a View Controller, and set the class to `SidebarViewController`. Also, set the Storyboard Identifier to `SidebarViewController`. You can change the in-code requirement if you want to break standards in naming those however.

- You can basically do whatever you want to the `SidebarViewController`. It can have a `UITableView`, or some buttons or if you're thinking in the mindset of an OS X Dev circa 2005, you'll pop a ~~UI~~NSTextView in there and use it to house your "About This App" info text.

- The next step is to make sure each View Controller that should access the Sidebar conforms to `NavigationControllerDelegate.`

## Control

- Each class that wants a Sidebar should implement one, or all, of the following methods. For the sake of convenience I made these empty, and of course in the future I'll make it better.

```swift
func shouldShowLeftMenu() {}
func shouldShowRightMenu() {}
func shouldShowAccessoryMenu() {}
```

- The `NavigationController` class asks the View Controller if it responds to any of these selectors, and if it does, shows the relevant button and allows you to show the associated Sidebar, or Topbar.

## Lastly

- This is being released under the MIT... blah blah... which means you can edit and change and use it free of charge... blah blah.

- I only ask that if you use this, @ me on Twitter (@cocotutch) or submit a PR with improvements :joy:

## Thanks!
