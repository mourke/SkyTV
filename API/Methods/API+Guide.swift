//
//  API+Guide.swift
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
     Retrieves all the channels available in a region.
     
     - Parameter region:    The region from which to retrieve the channels. Defaults to the user's current region.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `Channel`s will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's `URLSessionTask` to be `resume()`ed.
     */
    static func channels(in region: Region = .current,
                         callback: @escaping (Error?, [Channel]) -> Void
        ) -> URLSessionDataTask {
        let session = URLSession.shared
        
        let url = URL(string: Endpoints.channels + "/\(region.bouquet)/\(region.subbouquet)")!
        
        let task = session.dataTask(with: url) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let channels = try JSONDecoder().decode([String: [Channel]].self, from: data).values.first
                    
                    OperationQueue.main.addOperation {
                        callback(nil, channels ?? [])
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
    
    /**
     Retrieves the shedules for specific channels on a specified date.
     
     - Parameter date:      The date for which to fetch shedules. This can be any date, but the contents returned may be empty if Sky has not sheduled that far ahead of time. Defaults to the current date.
     - Parameter channels:  The channels for which to fetch shedules. **MAX:19**.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `Shedule`s will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's `URLSessionTask` to be `resume()`ed.
     */
    static func shedules(on date: Date = Date(),
                         for channels: [Channel],
                         callback: @escaping (Error?, [Shedule]) -> Void
        ) -> URLSessionDataTask {
        assert(channels.count < 20, "Number of channels passed in must be less than 20.")
        let session = URLSession.shared
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        let dateString = formatter.string(from: date)
        let channelsString = channels.map({$0.sheduleId}).joined(separator: ",")
        
        let url = URL(string: Endpoints.shedule + "/\(dateString)/\(channelsString)")!
        
        let task = session.dataTask(with: url) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let shedules = try JSONDecoder().decode([Shedule].self, from: data)
                    
                    OperationQueue.main.addOperation {
                        callback(nil, shedules)
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
