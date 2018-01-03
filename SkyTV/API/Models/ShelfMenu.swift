//
//  ShelfMenu.swift
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

struct ShelfMenu: ParentNode, Decodable {
    
    /// The title of the menu.
    let name: String
    
    /// The menu's id.
    let id: String
    
    /// The type of the menu.
    let type: NodeType
    
    /// The menu's content, split into shelves.
    let childNodes: [Shelf]
    
    
    enum CodingKeys: String, CodingKey {
        case type = "nodetype"
        case name = "t"
        case id = "cmsid"
        case childNodes = "childnodes"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        type = try values.decode(NodeType.self, forKey: .type)
        
        if type != .menu {
            throw NodeError.invalidType
        }
        
        id = try values.decode(String.self, forKey: .id)
        
        let headings = try values.decode([Failable<Shelf>].self, forKey: .childNodes)
        let items = try values.decode([Failable<ShelfItem>].self, forKey: .childNodes)
        
        var shelves: [Shelf] = []
        
        for index in 0..<items.count {
            guard var heading = headings[index].rawValue else { continue }
            
            var index = index + 1
            
            while index < items.count, let item = items[index].rawValue {
                index += 1
                
                heading.items.append(item)
            }
            
            heading.items.isEmpty ? () : shelves.append(heading)
        }
        
        
        childNodes = shelves
    }
}
