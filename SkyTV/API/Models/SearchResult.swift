//
//  SearchResult.swift
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

enum ProgrammeType: String, Codable {
    case movie = "movie"
    case tvShow = "programme"
    case notAProgramme = ""
}

struct SearchResult: Decodable {
    
    /// The programme's name.
    let name: String
    
    /// The programme uuid.
    let id: String
    
    /// The type of the search result.
    let type: SearchType
    
    /// The type of the programme, if the result's type is `programme`. If the search result's type is `programme`, it can either be a `movie` or a `tvShow`. This will return `notAProgramme` if the search result's time is not `programme`
    let programmeType: ProgrammeType
    
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name = "t"
        case type = "uuidtype"
        case programmeType = "type"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        id = try values.decode(String.self, forKey: .id)
        type = try values.decode(SearchType.self, forKey: .type)
        programmeType = (try? values.decode(ProgrammeType.self, forKey: .programmeType)) ?? .notAProgramme
    }
}
