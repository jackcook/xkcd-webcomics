//
//  ComicViewController.swift
//  xkcd webcomics
//
//  Created by Jack Cook on 11/29/14.
//  Copyright (c) 2014 CosmicByte. All rights reserved.
//

import UIKit

class ComicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var statusBarBackground: UIView!
    
    @IBOutlet var topBar: UIImageView!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var searchBar: UITextField!
    @IBOutlet var randomButton: UIButton!
    
    @IBOutlet var bottomBar: UIImageView!
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet var comicView: ComicView!
    
    var hidden = false
    
    var tableView: UITableView!
    var tableData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadComics()
        
        titleLabel.text = "Loading..."
        numberLabel.text = ""
        
        searchBar.alpha = 0
        nextButton.alpha = 0
        
        nc.addObserver(self, selector: "keyboardOnScreen:", name: UIKeyboardDidShowNotification, object: nil)
        nc.addObserver(self, selector: "keyPressed:", name: UITextFieldTextDidChangeNotification, object: nil)
        nc.addObserver(self, selector: "orientationChanged", name: UIDeviceOrientationDidChangeNotification, object: nil)
        nc.addObserver(self, selector: "loadFromNotification", name: loadFromNotificationNotification, object: nil)
        nc.addObserver(self, selector: "comicTapped", name: tapNotification, object: nil)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "nextComic")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "previousComic")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        var url = NSURL(string: "http://api.cosmicbyte.com/xkcd/xkcd.txt")!
        var request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            var list = NSString(data: data, encoding: NSUTF8StringEncoding) as String
            var items = split(list) {$0 == "\n"}
            for item in items {
                var csv = split(item) {$0 == ","}
                var num = csv[0].toInt()!
                
                csv.removeAtIndex(0)
                var title = ",".join(csv)
                
                searchable[num] = title
            }
        }
    }
    
    func orientationChanged() {
        if (UIDevice.currentDevice().userInterfaceIdiom != .Pad) {
            var l = UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)
            statusBarBackground.alpha = l ? 0 : 1
        }
    }
    
    func loadFromNotification() {
        titleLabel.text = "Loading..."
        numberLabel.text = ""
        nextButton.alpha = 0
        comicView.imageView.image = UIImage()
        loadComics()
    }
    
    func loadComics() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        var url = NSURL(string: "http://xkcd.com/info.0.json")!
        var request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if let comicData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
                if let num = comicData["num"] as? Int {
                    latest = num
                    self.loadComic(num)
                }
            }
        }
    }
    
    func keyboardOnScreen(notification: NSNotification) {
        var info = notification.userInfo! as NSDictionary
        var value = info[UIKeyboardFrameEndUserInfoKey] as NSValue
        
        var rawFrame = value.CGRectValue()
        var keyboardFrame = self.view.convertRect(rawFrame, fromView: nil)
        
        var tableFrame = CGRectMake(0, topBar.frame.origin.y + topBar.frame.size.height, screen.width, screen.height - topBar.frame.origin.y - topBar.frame.size.height - keyboardFrame.size.height)
        tableView.frame = tableFrame
    }
    
    func keyPressed(notification: NSNotification) {
        tableData = search(searchBar.text)
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var comicData = tableData[indexPath.row]
        var parts = split(comicData) {$0 == ":"}
        var number = parts[0].toInt()!
        
        searchButton(UIButton())
        loadComic(number)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifier = "SearchResult"
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
        cell.textLabel!.text = tableData[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func search(query: NSString) -> [String] {
        var data = [String]()
        for (number, comic) in searchable {
            var comicString = "\(number): \(comic)"
            if comicString.rangeOfString(query) != nil {
                data.append(comicString)
            }
        }
        
        return data
    }
    
    func comicTapped() {
        if self.topBar.alpha == 1 {
            searchBar.resignFirstResponder()
        }
        
        hidden = !hidden
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.topBar.alpha = self.hidden ? 0 : 1
            self.searchButton.alpha = self.hidden ? 0 : 1
            self.titleLabel.alpha = self.hidden ? 0 : 1
            self.searchBar.alpha = 0
            self.randomButton.alpha = self.hidden ? 0 : 1
            
            self.bottomBar.alpha = self.hidden ? 0 : 1
            self.previousButton.alpha = !self.hidden && !(current == 0) ? 1 : 0
            self.numberLabel.alpha = self.hidden ? 0 : 1
            self.nextButton.alpha = !self.hidden && !(current == latest) ? 1 : 0
        }
    }
    
    @IBAction func nextComic() {
        loadComic(current.number + (current.number == 403 ? 2 : 1))
    }
    
    @IBAction func previousComic() {
        loadComic(current.number - (current.number == 405 ? 2 : 1))
    }
    
    func loadComic(comic: Comic) {
        titleLabel.text = comic.title
        numberLabel.text = "\(comic.number)"
        
        comicView.load(comic)
        
        var last = current.number == latest
        nextButton.alpha = last ? 0 : 1
        nextButton.userInteractionEnabled = last ? false : true
        
        var first = current.number == 0
        previousButton.alpha = first ? 0 : 1
        previousButton.userInteractionEnabled = first ? false : true
    }
    
    func loadComic(number: Int) {
        var url = NSURL(string: "http://xkcd.com/\(number)/info.0.json")!
        var request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if let comicData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
                if let num = comicData["num"] as? Int {
                    if let title = comicData["safe_title"] as? String {
                        if let image = comicData["img"] as? String {
                            var comic = Comic()
                            comic.number = num
                            comic.title = title
                            comic.url = NSURL(string: image)!
                            
                            current = comic
                            
                            self.loadComic(comic)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func searchButton(sender: AnyObject) {
        if tableView == nil {
            titleLabel.alpha = 0
            searchBar.alpha = 1
            searchBar.userInteractionEnabled = true
            searchBar.returnKeyType = UIReturnKeyType.Search
            searchBar.becomeFirstResponder()
            
            var tableFrame = CGRectMake(0, topBar.frame.origin.y + topBar.frame.size.height, screen.width, screen.height - topBar.frame.origin.y - topBar.frame.size.height)
            tableView = UITableView(frame: tableFrame, style: UITableViewStyle.Plain)
            tableView.delegate = self
            tableView.dataSource = self
            
            self.view.addSubview(tableView)
        } else {
            titleLabel.alpha = 1
            searchBar.alpha = 0
            searchBar.userInteractionEnabled = false
            searchBar.resignFirstResponder()
            tableView.removeFromSuperview()
            tableView = nil
        }
    }
    
    @IBAction func randomButton(sender: AnyObject) {
        var rand = Int(arc4random_uniform(UInt32(searchable.count)))
        if rand != 404 {
            loadComic(rand)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}