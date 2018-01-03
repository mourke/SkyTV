//
//  API+Programme.swift
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

extension API {
    
    /**
     Returns detailed info about a programme
     
     - Parameter id:        The uuid of the programme
     - Parameter type:      The type of the programme
     - Parameter region:    The region from which to fetch information about the programme. Differing regions will give different descriptions. Some may not contain the programme. Defaults to the user's current region.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `Programme` will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's `URLSessionTask` to be `resume()`ed.
     */
    static func programmeInfo(for id: String,
                              of type: SearchType,
                              in region: Region = .current,
                              callback: @escaping (Error?, Programme?) -> Void
        ) -> URLSessionDataTask {
        let session = URLSession.shared
        var components = URLComponents(string: "http://entity.search.sky.com/entity/search/v1/skygo/home/\(region.bouquet)/\(region.subbouquet)/user/\(type)/\(id)")!
        
        components.queryItems = [URLQueryItem(name: "src", value: "svod"),
                                 URLQueryItem(name: "src", value: "cup"),
                                 URLQueryItem(name: "src", value: "ott"),
                                 URLQueryItem(name: "order", value: "sea")]
        
        let request = URLRequest(url: components.url!)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let programme = try JSONDecoder().decode(Programme.self, from: data)
                    
                    callback(nil, programme)
                } catch let e {
                    error = e
                }
            }
            
            if let error = error {
                OperationQueue.main.addOperation {
                    callback(error, nil)
                }
            }
        }
        
        return task
    }
}
