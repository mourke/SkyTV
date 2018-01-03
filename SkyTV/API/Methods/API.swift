//
//  API.swift
//  SkyTV
//
//  Copyright © 2018 Mark Bourke.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE
//

import Foundation

struct API {
    
    struct Endpoints {
        static let signIn = "https://skyid.sky.com/api/1/token/ethan"
        static let authorise = "https://skyid.sky.com/authorise/skygo"
        static let onDemand = "https://awk.epgsky.com/hawk/ondemand"
        static let region = "https://epgservices.sky.com/80.1.1/api/2.0/regions/json"
        static let suggest = "http://entity.search.sky.com/suggest/v1/skygo/BENQMSHomePageContainerViewController"
        static let programmeInfo = "http://entity.search.sky.com/entity/search/v1/skygo/home"
        static let images = "https://images.metadata.sky.com"
        static let menu = "https://config.ethan.interactive.sky.com/config-content/r4/menu"
        static let channels = "https://awk.epgsky.com/hawk/linear/services"
        static let shedule = "https://awk.epgsky.com/hawk/linear/schedule"
    }
}
