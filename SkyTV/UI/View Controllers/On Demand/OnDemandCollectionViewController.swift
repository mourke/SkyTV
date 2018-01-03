//
//  OnDemandCollectionViewController.swift
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

class OnDemandCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, FilterTableViewControllerDelegate, SearchResultsTableViewControllerDelegate, ErrorViewDelegate {
    
    
    var searchController: UISearchController?
    var catalogue: Catalogue<Programme>?
    var request: URLSessionTask?
    
    /// Used to calculate the size of the dynamic content in the header for `UICollectionView`
    lazy var sizingHeader: SectionHeaderCollectionReusableView = Bundle.main.loadNibNamed("SectionHeaderCollectionReusableView", owner: nil)?.first as! SectionHeaderCollectionReusableView
    
    var programmes: [Programme] {
        return catalogue?.childNodes ?? []
    }
    
    var filters: [Filter] = [] {
        didSet {
            navigationItem.leftBarButtonItem?.isEnabled = !filters.isEmpty
        }
    }
    
    var activeFilter: Filter! {
        didSet {
            guard let filter = activeFilter, oldValue?.id != filter.id else { return }
            
            catalogue = nil
            collectionView?.reloadData()
            
            request = API.catalogue(for: filter.id) { [unowned self] (error, catalogue) in
                if let error = error {
                    let errorView = ErrorView(with: error)
                    errorView.delegate = self
                    self.collectionView?.backgroundView = errorView
                    return
                }
                self.catalogue = catalogue
                self.collectionView?.reloadData()
            }
            
            request?.resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchResultsController = SearchResultsTableViewController(style: .plain)
        searchController = SearchController(searchResultsController: searchResultsController)
        
        searchController?.searchResultsUpdater = searchResultsController
        searchResultsController.delegate = self
        searchResultsController.searchController = searchController
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let headerNib = UINib(nibName: "SectionHeaderCollectionReusableView", bundle: nil)
        collectionView?.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "sectionHeader")
    }
    
    // MARK: - Collection view data source
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if programmes.isEmpty {
            let loadingView = Bundle.main.loadNibNamed("LoadingView", owner: nil)?.first as! UIView
            collectionView.backgroundView = loadingView
        } else {
            collectionView.backgroundView = nil
        }
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return programmes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath) as! SectionHeaderCollectionReusableView
            
            sectionHeader.titleLabel?.text = catalogue?.name
            sectionHeader.subtitleLabel?.text = catalogue?.subtitle
            
            return sectionHeader
        } else {
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    // MARK: - Collection view flow layout delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard !programmes.isEmpty else {
            return .zero
        }
        
        sizingHeader.titleLabel?.text = catalogue?.name
        sizingHeader.subtitleLabel?.text = catalogue?.subtitle
        
        sizingHeader.setNeedsLayout()
        sizingHeader.layoutIfNeeded()
        
        let size = sizingHeader.contentView!.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        return size
    }
    
    // MARK - Filter table view controller delegate
    
    func filterDidChange(_ newFilter: Filter) {
        activeFilter = newFilter
        collectionView?.reloadData()
    }
    
    // MARK: - Search results table view controller delegate
    
    func searchResultsController(_ searchResultsController: SearchResultsTableViewController, textDidChange newText: String, callback: @escaping (Error?, [SearchResult]) -> Void) -> URLSessionDataTask {
        fatalError("Must be implemented by subclass")
    }
    
    // MARK: - Error view delegate
    
    func retryRequest() {
        request?.resume()
        collectionView?.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilters",
            let navigationController = segue.destination as? UINavigationController,
            let destination = navigationController.viewControllers.first as? FilterTableViewController {
            destination.delegate = self
            destination.filters = filters
            destination.currentFilter = activeFilter
        }
    }
}
