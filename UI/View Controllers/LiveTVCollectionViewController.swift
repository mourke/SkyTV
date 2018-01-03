//
//  LiveTVCollectionViewController.swift
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

class LiveTVCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ErrorViewDelegate {
    
    var channels: [Channel] = []
    var shedules: [Shedule] = []
    var request: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        request = API.channels { [unowned self] (error, channels) in
            if let error = error {
                let errorView = ErrorView(with: error)
                errorView.delegate = self
                self.collectionView?.backgroundView = errorView
                return
            }
            
            self.channels = channels
            
            self.request = API.shedules(for: channels) { (error, shedules) in
                if let error = error {
                    let errorView = ErrorView(with: error)
                    errorView.delegate = self
                    self.collectionView?.backgroundView = errorView
                    return
                }
                
                self.shedules = shedules
                self.collectionView?.reloadData()
            }
            
            self.request?.resume()
        }
        
        request?.resume()
    }
    
    // MARK: - Collection view data source
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if channels.isEmpty {
            let loadingView = Bundle.main.loadNibNamed("LoadingView", owner: nil)?.first as! UIView
            collectionView.backgroundView = loadingView
        } else {
            collectionView.backgroundView = nil
        }
        return channels.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shedules.filter({$0.id == channels[section].sheduleId}).count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "entryCell", for: indexPath)
        
        return cell
    }
    
    // MARK: - Collection view flow layout delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .zero
    }

    // MARK: - Error view delegate
    
    func retryRequest() {
        request?.resume()
        collectionView?.reloadData()
    }
}
