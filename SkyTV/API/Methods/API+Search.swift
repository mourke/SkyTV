//
//  API+Search.swift
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

enum SearchType: String, Codable {
    case programme
    case sport
    case series
    case person
    case team
    case competition
}

extension API {
    
    /**
     Returns suggestions based on the user's seatch request.
     
     - Parameter term:      The user's search request.
     - Parameter region:    The region from which to retrieve the results. Defaults to the user's current region.
     - Parameter types:     The type of the search results to be returned.
     - Parameter limit:     The maximum number of search results to be returned. **MAX: 255**.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `SearchResult`s will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's `URLSessionTask` to be `resume()`ed.
     */
    static func search(for term: String,
                       in region: Region = .current,
                       types: SearchType...,
                       limit: Int = 255,
                       callback: @escaping (Error?, [SearchResult]) -> Void
        ) -> URLSessionDataTask {
        assert(limit <= 255, "Limit cannot be greater than 255")
        
        let session = URLSession.shared
        var components = URLComponents(string: Endpoints.suggest + "/\(region.bouquet)/\(region.subbouquet)/F4624E62-2E95-40CF-9105-9DC97841F84E")!
        
        components.queryItems = [URLQueryItem(name: "limit", value: "\(limit)"),
                                 URLQueryItem(name: "term", value: term),
                                 URLQueryItem(name: "src", value: "svod"),
                                 URLQueryItem(name: "src", value: "cup"),
                                 URLQueryItem(name: "src", value: "ott")]
        
        let request = URLRequest(url: components.url!)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let searchResults = try JSONDecoder().decode([String: [SearchResult]].self, from: data)
                    let values = searchResults.values.first ?? []
                    
                    OperationQueue.main.addOperation {
                        callback(nil, values.filter({types.contains($0.type)}))
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
