//
//  Programme.swift
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

enum ImageType: String {
    case background = "16-9"
    case hero = "background"
    case poster = "cover"
}

struct Programme: Decodable, Node {
    
    /// The Sky uuid of the programme.
    let id: String
    
    /// The name of the programme.
    let name: String
    
    /// A short summary of the programme's contents.
    let synopsis: String
    
    /// The programme's age rating, if any.
    let certification: String?
    
    /// The programmes rating out of 100.
    let rating: Int
    
    /// The video formats in which the programme is available.
    let formats: [VideoFormat]
    
    private let type: NodeType
    
    enum CodingKeys: String, CodingKey {
        case name = "t"
        case id = "programmeuuid"
        case synopsis = "sy"
        case certification = "r"
        case rating = "reviewrating"
        case type
        case formats
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(NodeType.self, forKey: .type)
        
        if type != .programme {
            throw NodeError.invalidType
        }
        
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        synopsis = try values.decode(String.self, forKey: .synopsis)
        certification = try? values.decode(String.self, forKey: .certification)
        rating = (try? values.decode(Int.self, forKey: .rating)) ?? 0
        formats = try values.decode([Failable<VideoFormat>].self, forKey: .formats).flatMap({$0.rawValue})
    }
}
