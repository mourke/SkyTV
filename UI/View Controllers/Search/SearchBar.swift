//
//  SearchBar.swift
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

import UIKit.UISearchBar

class SearchBar: UISearchBar {
    
    let loadingView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    var isLoading = false {
        didSet {
            isLoading ? loadingView.startAnimating() : loadingView.stopAnimating()
            clearButton?.isHidden = isLoading
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedSetup()
    }
    
    func sharedSetup() {
        if let searchBarTextField = searchBarTextField {
            searchBarTextField.addSubview(loadingView)
            loadingView.translatesAutoresizingMaskIntoConstraints = false
            
            loadingView.centerYAnchor.constraint(equalTo: searchBarTextField.centerYAnchor).isActive = true
            loadingView.trailingAnchor.constraint(equalTo: searchBarTextField.trailingAnchor, constant: -5).isActive = true
        }
        
        loadingView.hidesWhenStopped = true
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        if subview === clearButton {
            ({ self.isLoading = isLoading })() // Force update the `isLoading` status. `clearButton` may already have been set to hidden, but because it was not in the view hierarchy, this message was not passed to the button.
        }
    }
}
