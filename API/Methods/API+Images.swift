//
//  API+Images.swift
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
import struct CoreGraphics.CGBase.CGSize

extension API {
    
    /**
     Returns the image URL of a programme.
     
     - Parameter id:    The uuid of the programme.
     - Parameter size:  The size that the image is to be scaled to. This can be any size, but keep in mind, quality is lost when the image is scaled on-the-fly.
     - Parameter type:  The type of the image to be returned. Most programmes have images of all types but some don't. Most should have one of type `poster`.
     
     - Returns: The image URL.
     */
    static func imageURL(for id: String, with size: CGSize, type: ImageType) -> URL {
        let rounded = Int((type == .poster ? size.height : size.width).rounded())
        return URL(string: API.Endpoints.images + "/pd-image/\(id)/\(type.rawValue)/\(rounded)")!
    }
    
    /**
     Returns the image URL of the badge of a programme.
     
     - Parameter provider:  The name of the provider.
     - Parameter width:     The width that the image is to be scaled to. This can be any size, but keep in mind, quality is lost when the image is scaled on-the-fly. The image is in the ratio of 1:5 (length:width) and clear space is returned along with the badge in the bottom left hand side
     
     - Returns: The badge URL.
     */
    static func providerBadgeURL(for provider: String, width: Int) -> URL {
        let height = width/5
        let badgeName = provider.components(separatedBy: .whitespaces).joined().lowercased()
        return URL(string: API.Endpoints.images + "/pd-logo/skychb_\(badgeName)/\(width)/\(height)")!
    }
}
