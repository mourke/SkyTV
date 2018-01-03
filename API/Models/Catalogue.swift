//
//  Catalogue.swift
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

struct Catalogue<T: Node & Decodable>: Decodable, ParentNode {
    
    /// The name of the catalogue.
    let name: String
    
    /// The catalogue's id.
    let id: String
    
    /// A small discription, if any, of the contents of the catalogue.
    let subtitle: String?
    
    /// The items of the catalogue.
    let childNodes: [T]
    
    /// The type of the child nodes.
    let childNodeType: NodeType
    
    enum CodingKeys: String, CodingKey {
        case name = "nodename"
        case id = "nodeid"
        case subtitle = "sy"
        case childNodes = "childnodes"
        case childNodeType = "childnodetype"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        id = try values.decode(String.self, forKey: .id)
        subtitle = try? values.decode(String.self, forKey: .subtitle)
        childNodeType = try values.decode(NodeType.self, forKey: .childNodeType)
        childNodes = try values.decode([Failable<T>].self, forKey: .childNodes).flatMap({$0.rawValue})
    }
}
