//
//  ComicView.swift
//  xkcd webcomics
//
//  Created by Jack Cook on 11/29/14.
//  Copyright (c) 2014 CosmicByte. All rights reserved.
//

import UIKit

class ComicView: UIView, NSURLConnectionDataDelegate {
    
    var imageView: UIImageView!
    var mutableData: NSMutableData!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        var tap = UITapGestureRecognizer(target: self, action: "tap")
        self.addGestureRecognizer(tap)
    }
    
    func load(comic: Comic) {
        var request = NSURLRequest(URL: comic.url)
        var connection = NSURLConnection(request: request, delegate: self)
        connection?.start()
    }
    
    func tap() {
        nc.postNotificationName(tapNotification, object: nil)
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        mutableData = NSMutableData()
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        mutableData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        var image = UIImage(data: mutableData)
        imageView.image = image
        
        var actualSize = image!.size
        var size = CGSizeMake(self.bounds.width, self.bounds.width / (actualSize.width / actualSize.height))
        
        if size.height > self.frame.size.height {
            size = CGSizeMake(self.bounds.height / (actualSize.height / actualSize.width), self.bounds.height)
        }
        
        imageView.frame = CGRectMake((self.bounds.width - size.width) / 2, (self.bounds.height - size.height) / 2, size.width, size.height)
        
        MBProgressHUD.hideHUDForView(self.superview, animated: true)
    }
}