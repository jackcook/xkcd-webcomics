//
//  Common.swift
//  xkcd webcomics
//
//  Created by Jack Cook on 11/29/14.
//  Copyright (c) 2014 CosmicByte. All rights reserved.
//

import Foundation
import UIKit

let screen = UIScreen.mainScreen().bounds

let nc = NSNotificationCenter.defaultCenter()
let loadFromNotificationNotification = "LoadFromNotificationNotification"
let tapNotification = "TapNotification"

var current: Comic!
var latest = 0

var searchable = [Int:String]()
