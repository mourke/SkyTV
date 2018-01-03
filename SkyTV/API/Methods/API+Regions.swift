//
//  API+Regions.swift
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
     The list of possible regions the user can possibly reside in and still be a BSkyB customer. Choosing a region will alter the content displayed to you within the app.
     
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `Region`s will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's `URLSessionTask` to be `resume()`ed.
     */
    static func regions(callback: @escaping (Error?, [Region]) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        let url = URL(string: Endpoints.region)!
        
        let task = session.dataTask(with: url) { (data, response, error) in
            var error = error
            if let data = data {
                do {
                    let dictionary = try JSONDecoder().decode([String: [Region]].self, from: data)
                    
                    OperationQueue.main.addOperation {
                        callback(nil, Array(dictionary.values).flatMap({$0}))
                    }
                } catch let e {
                    error = e
                }
            }
            
            if let error = error {
                OperationQueue.main.addOperation {
                    callback(error, [])
                }
            }
        }
        
        return task
    }
}
