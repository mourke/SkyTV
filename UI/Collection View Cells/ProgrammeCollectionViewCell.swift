//
//  ProgrammeCollectionViewCell.swift
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

import UIKit

class ProgrammeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var highlightView: UIView?
    @IBOutlet var textLabel: UILabel?
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                highlightView?.isHidden = false
                highlightView?.alpha = 1.0
            } else {
                UIView.animate(withDuration: 0.1,
                               delay: 0.0, options: [.curveEaseOut, .allowUserInteraction],
                               animations: { [unowned self] in
                                self.highlightView?.alpha = 0.0
                }) { _ in
                    self.highlightView?.isHidden = true
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView?.layer.borderColor = UIColor(red: 29.0/255.0, green: 29.0/255.0, blue: 29.0/255.0, alpha: 1).cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        [highlightView, imageView].forEach {
            $0?.layer.cornerRadius = self.bounds.width * 0.015
            $0?.layer.masksToBounds = true
        }
    }
}
