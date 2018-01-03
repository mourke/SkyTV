//
//  CinemaCollectionViewController.swift
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
import Kingfisher

class CinemaCollectionViewController: OnDemandCollectionViewController {
    
    /// Used to calculate the size of the dynamic content in the cell for `UICollectionView`
    lazy var sizingCell: PosterCollectionViewCell = Bundle.main.loadNibNamed("PosterCollectionViewCell", owner: nil)?.first as! PosterCollectionViewCell
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController?.searchBar.placeholder = "Search for movies"
        
        let cellNib = UINib(nibName: "PosterCollectionViewCell", bundle: nil)
        collectionView?.register(cellNib, forCellWithReuseIdentifier: "cell")
        
        request = API.cinemaFilters { [unowned self] (error, filters) in
            if let error = error {
                let errorView = ErrorView(with: error)
                errorView.delegate = self
                self.collectionView?.backgroundView = errorView
                return
            }
            self.filters = filters
            self.activeFilter = filters.first
        }
        
        request?.resume()
    }
    
    // MARK: - Collection view data source
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PosterCollectionViewCell
        let programme = programmes[indexPath.row]
        
        cell.textLabel?.text = programme.name
        
        let size = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: indexPath)
        cell.imageView?.kf.setImage(with: API.imageURL(for: programme.id, with: size, type: .poster), placeholder: UIImage(named: "PreloadAsset-Movie"))
        
        return cell
    }
    
    // MARK: - Collection view flow layout delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        var width: CGFloat = 0
        let sectionInset = collectionView.safeAreaInsets.left + flowLayout.sectionInset.left + flowLayout.sectionInset.right + collectionView.safeAreaInsets.right
        let spacing = flowLayout.minimumInteritemSpacing
        
        for items in (2...Int.max) {
            let items = CGFloat(items)
            let newWidth = (view.bounds.width/items) - (sectionInset/items) - (spacing * (items - 1)/items)
            if newWidth < 104 && items > 2 // Minimum of 2 cells no matter the screen size
            {
                break
            }
            width = newWidth
        }
        
        let programme = programmes[indexPath.row]
        
        sizingCell.textLabel?.text = programme.name
        
        sizingCell.setNeedsLayout()
        sizingCell.layoutIfNeeded()
        
        let size = sizingCell.contentView.systemLayoutSizeFitting(CGSize(width: width.rounded(.down), height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        return size
    }
    
    // MARK: - Search results table view controller delegate
    
    override func searchResultsController(_ searchResultsController: SearchResultsTableViewController, textDidChange newText: String, callback: @escaping (Error?, [SearchResult]) -> Void) -> URLSessionDataTask {
        return API.search(for: newText, types: .programme, .person) {
            callback($0, $1.filter({$0.programmeType != .tvShow}))
        }
    }
}
