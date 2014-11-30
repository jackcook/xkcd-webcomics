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
        
        var url = NSURL(string: "http://api.cosmicbyte.com/xkcd/xkcd.txt")!
        var request = NSURLRequest(URL: url)
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        titleLabel.text = "Loading..."
        numberLabel.text = ""
        
        searchBar.alpha = 0
        searchBar.userInteractionEnabled = false
        
        nextButton.alpha = 0
        nextButton.userInteractionEnabled = false
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            var list = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            var items = split(list) {$0 == "\n"}
            var pattern = NSRegularExpression(pattern: "\".*?\"", options: nil, error: nil)
            for item in items {
                var matches = pattern?.matchesInString(item, options: nil, range: NSMakeRange(0, countElements(item)))
                if matches?.count > 0 {
                    var title = NSString(string: item).substringWithRange(matches![0].range!)
                    title = title.stringByReplacingOccurrencesOfString("\"", withString: "", options: nil, range: nil)
                    
                    var imgurltxt = NSString(string: item).substringWithRange(matches![1].range!)
                    imgurltxt = imgurltxt.stringByReplacingOccurrencesOfString("\"", withString: "", options: nil, range: nil)
                    var imgurl = NSURL(string: imgurltxt)!
                    
                    var csv = split(item) {$0 == ","}
                    var num = csv[0].toInt()!
                    
                    var comic = Comic()
                    comic.number = num
                    comic.title = title
                    comic.url = imgurl
                    
                    comics.append(comic)
                }
            }
            
            self.loadComic(comics.count + 1)
        }
        
        nc.addObserver(self, selector: "keyboardOnScreen:", name: UIKeyboardDidShowNotification, object: nil)
        nc.addObserver(self, selector: "keyPressed:", name: UITextFieldTextDidChangeNotification, object: nil)
        nc.addObserver(self, selector: "comicTapped", name: tapNotification, object: nil)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "nextComic")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "previousComic")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
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
        loadComic(number - 1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifier = "SearchResult"
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
        cell.textLabel.text = tableData[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func search(query: NSString) -> [String] {
        var data = [String]()
        for comic in comics {
            var comicString = "\(comic.number): \(comic.title)"
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
            self.nextButton.alpha = !self.hidden && !(current + 1 == comics.last!.number) ? 1 : 0
        }
    }
    
    @IBAction func nextComic() {
        if current + 1 == comics.last!.number { return }
        
        var num = current + 1
        if num + 1 == 404 { num = 404 }
        if num + 1 == 1037 { num = 1037 }
        loadComic(num)
    }
    
    @IBAction func previousComic() {
        if current == 0 { return }
        
        var num = current - 1
        if num + 1 == 404 { num = 402 }
        if num + 1 == 1037 { num = 1035 }
        loadComic(num)
    }
    
    func loadComic(num: Int) {
        var n = num
        var comic: Comic!
        
        if n + 1 == 404 { n = 404 }
        if n + 1 == 1037 { n = 1037 }
        
        for c in comics {
            if c.number == n + 1 {
                comic = c
                break
            }
        }
        
        current = n
        
        titleLabel.text = comic.title
        numberLabel.text = "\(comic.number)"
        
        comicView.load(comic)
        
        var last = current + 1 == comics.last!.number
        nextButton.alpha = last ? 0 : 1
        nextButton.userInteractionEnabled = last ? false : true
        
        var first = current == 0
        previousButton.alpha = first ? 0 : 1
        previousButton.userInteractionEnabled = first ? false : true
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
        var rand = Int(arc4random_uniform(UInt32(comics.last!.number)))
        loadComic(rand)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}