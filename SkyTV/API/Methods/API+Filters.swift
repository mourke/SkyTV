//
//  API+Filters.swift
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

private enum CatalogueType: String {
    case cinema = "Sky Cinema"
    case boxSets = "Sky Box Sets"
    case catchUp = "Catch Up"
    case sports = "Sky Sports"
}

extension API {
    
    /**
     Returns the possible filters that the user can choose from in order to only see certain sports fixtures.
     
     - Parameter region:    The region from which to retrieve the filters. Defaults to the user's current region.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `Filters`s will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's `URLSessionTask` to be `resume()`ed.
     */
    static func sportsFilters(in region: Region = .current,
                              callback: @escaping (Error?, [Filter]) -> Void
        ) -> URLSessionDataTask {
        let session = URLSession.shared
        let url = URL(string: Endpoints.onDemand + "/\(region.bouquet)/\(region.subbouquet)/cataloguenode")!
        
        let task = session.dataTask(with: url) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let catalogue = try JSONDecoder().decode(Catalogue<Catalogue<Catalogue<Filter>>>.self, from: data)
                    let catchUpCatalogue = catalogue.childNodes.first(where: {$0.name == CatalogueType.catchUp.rawValue})
                    let sportsCatalogue = catchUpCatalogue?.childNodes.first(where: {$0.name == CatalogueType.sports.rawValue})
                    
                    let filters = sportsCatalogue?.childNodes ?? []
                    
                    return OperationQueue.main.addOperation {
                        callback(nil, filters)
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
     Returns the possible filters that the user can choose from in order to only see certain movies.
     
     - Parameter region:    The region from which to retrieve the filters. Defaults to the user's current region.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `Filters`s will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's `URLSessionTask` to be `resume()`ed.
     */
    static func cinemaFilters(in region: Region = .current,
                              callback: @escaping (Error?, [Filter]) -> Void
        ) -> URLSessionDataTask {
        return filters(for: .cinema, in: region, callback: callback)
    }
    
    /**
     Returns the possible filters that the user can choose from in order to only see certain Box Sets.
     
     - Parameter region:    The region from which to retrieve the filters. Defaults to the user's current region.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `Filters`s will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's `URLSessionTask` to be `resume()`ed.
     */
    static func boxSetFilters(in region: Region = .current,
                              callback: @escaping (Error?, [Filter]) -> Void
        ) -> URLSessionDataTask {
        return filters(for: .boxSets, in: region, callback: callback)
    }
    
    private static func filters(for type: CatalogueType,
                                in region: Region = .current,
                                callback: @escaping (Error?, [Filter]) -> Void
        ) -> URLSessionDataTask {
        let session = URLSession.shared
        let url = URL(string: Endpoints.onDemand + "/\(region.bouquet)/\(region.subbouquet)/cataloguenode")!
        
        let task = session.dataTask(with: url) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let catalogue = try JSONDecoder().decode(Catalogue<Catalogue<Filter>>.self, from: data)
                    let filters = catalogue.childNodes.first(where: {$0.name == type.rawValue})?.childNodes ?? []
                    
                    return OperationQueue.main.addOperation {
                        callback(nil, filters)
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
