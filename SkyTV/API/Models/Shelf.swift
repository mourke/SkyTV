//
//  Shelf.swift
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

enum ShelfLayout: String, Codable {
    case carousel = "CAROUSEL"
    case rail = "RAIL"
}

enum RailTemplate: String, Codable {
    case background = "3COL"
    case poster = "5COL"
    case notARail = ""
}

struct Shelf: Node, Decodable {
    
    /// The title of the shelf.
    let name: String
    
    /// The shelf's id.
    let id: String
    
    /// The type of the shelf.
    let type: NodeType
    
    /// The layout of the shelf, giving information about how it should be displayed. It is not necessary to follow this layout.
    let layout: ShelfLayout
    
    /// The type of rail, if the shelf's layout is `rail`.
    let template: RailTemplate
    
    /// The items on the shelf.
    var items: [ShelfItem] = []
    
    enum CodingKeys: String, CodingKey {
        case type = "nodetype"
        case name = "t"
        case id = "cmsid"
        case renderHints = "renderhints"
    }
    
    enum RenderHintsKeys: String, CodingKey {
        case layout = "layout"
        case template = "template"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        type = try values.decode(NodeType.self, forKey: .type)
        
        if type != .heading {
            throw NodeError.invalidType
        }
        
        id = try values.decode(String.self, forKey: .id)
        
        let renderHints = try values.nestedContainer(keyedBy: RenderHintsKeys.self, forKey: .renderHints)
        layout = try renderHints.decode(ShelfLayout.self, forKey: .layout)
        template = (try? renderHints.decode(RailTemplate.self, forKey: .template)) ?? .notARail
    }
    
}
