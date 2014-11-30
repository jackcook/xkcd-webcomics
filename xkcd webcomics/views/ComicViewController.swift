//
//  ComicViewController.swift
//  xkcd webcomics
//
//  Created by Jack Cook on 11/29/14.
//  Copyright (c) 2014 CosmicByte. All rights reserved.
//

import UIKit

class ComicViewController: UIViewController {
    
    @IBOutlet var statusBarBackground: UIView!
    
    @IBOutlet var topBar: UIImageView!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var randomButton: UIButton!
    
    @IBOutlet var bottomBar: UIImageView!
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet var comicView: ComicView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var url = NSURL(string: "http://api.cosmicbyte.com/xkcd/xkcd.txt")!
        var request = NSURLRequest(URL: url)
        
        MBProgressHUD.showHUDAddedTo(comicView, animated: true)
        
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
            
            self.comicView.load(comics.last!)
        }
        
        nc.addObserver(self, selector: "comicTapped", name: tapNotification, object: nil)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeLeft")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeRight")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    func comicTapped() {
        UIView.animateWithDuration(0.5) { () -> Void in
            self.topBar.alpha = self.topBar.alpha == 0 ? 1 : 0
            self.searchButton.alpha = self.searchButton.alpha == 0 ? 1 : 0
            self.titleLabel.alpha = self.titleLabel.alpha == 0 ? 1 : 0
            self.randomButton.alpha = self.randomButton.alpha == 0 ? 1 : 0
            
            self.bottomBar.alpha = self.bottomBar.alpha == 0 ? 1 : 0
            self.previousButton.alpha = self.previousButton.alpha == 0 ? 1 : 0
            self.numberLabel.alpha = self.numberLabel.alpha == 0 ? 1 : 0
            self.nextButton.alpha = self.nextButton.alpha == 0 ? 1 : 0
        }
    }
    
    func swipeLeft() {

    }
    
    func swipeRight() {

    }
    
    @IBAction func searchButton(sender: AnyObject) {
        
    }
    
    @IBAction func randomButton(sender: AnyObject) {
        
    }
    
    @IBAction func previousButton(sender: AnyObject) {
        
    }
    
    @IBAction func nextButton(sender: AnyObject) {
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}