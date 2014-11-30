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
        
        var url = NSURL(string: "http://imgs.xkcd.com/comics/fmri.png")!
        comicView.load(url)
        
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
        var url = NSURL(string: "http://imgs.xkcd.com/comics/jurassic_world.png")!
        comicView.load(url)
    }
    
    func swipeRight() {
        var url = NSURL(string: "http://imgs.xkcd.com/comics/background_screens.png")!
        comicView.load(url)
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