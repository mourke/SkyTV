//
//  HomeTableViewController.swift
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

class HomeTableViewController: UITableViewController, ErrorViewDelegate {
    
    var menu: ShelfMenu?
    var request: URLSessionTask?
    
    /// Because the `UITableViewCell` containing the `UICollectionView` is reusable, the `UICollectionView.contentOffset` can be shared between two cells displaying different content. This dictionary is used to keep track of the `UICollectionView`'s corresponding `UICollectionView.contentOffset`
    var collectionViewOffsets: [Int: CGPoint] = [:]
    
    /// The following are used to calculate the size of the dynamic content in the cell for `UICollectionView`
    lazy var backgroundSizingCell = Bundle.main.loadNibNamed("BackgroundCollectionViewCell", owner: nil)?.first as! BackgroundCollectionViewCell
    lazy var heroSizingCell = Bundle.main.loadNibNamed("HeroCollectionViewCell", owner: nil)?.first as! HeroCollectionViewCell
    lazy var posterSizingCell = Bundle.main.loadNibNamed("PosterCollectionViewCell", owner: nil)?.first as! PosterCollectionViewCell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let selector = Selector(("_setHeaderAndFooterViewsFloat:"))
        
        if tableView.responds(to: selector) {
            tableView.perform(selector, with: false)
        }
        
        let cellNib = UINib(nibName: "CollectionViewTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "collectionViewCell")
        let headerNib = UINib(nibName: "SectionTableViewHeaderView", bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "header")
        
        tableView.tableFooterView = UIView()
        
        request = API.menu { [unowned self] (error, menu) in
            if let menu = menu {
                self.menu = menu
                self.tableView.reloadData()
            } else if let error = error {
                let errorView = ErrorView(with: error)
                errorView.delegate = self
                self.tableView.backgroundView = errorView
            }
        }
        
        request?.resume()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let sections = menu?.childNodes.count ?? 0
        
        if sections == 0 {
            let loadingView = Bundle.main.loadNibNamed("LoadingView", owner: nil)?.first as! UIView
            tableView.backgroundView = loadingView
        } else {
            tableView.backgroundView = nil
        }
        
        return sections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewTableViewCell
        
        cell.collectionView?.delegate = self
        cell.collectionView?.dataSource = self
        cell.collectionView?.tag = indexPath.section
        cell.collectionView?.collectionViewLayout.invalidateLayout()
        cell.collectionView?.reloadData()
        cell.collectionView?.invalidateIntrinsicContentSize()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        
        header?.textLabel?.text = menu!.childNodes[section].name
        
        return header
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! CollectionViewTableViewCell
        
        cell.collectionView?.contentOffset = collectionViewOffsets[indexPath.section] ?? .zero
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! CollectionViewTableViewCell
        
        collectionViewOffsets[indexPath.section] = cell.collectionView?.contentOffset ?? .zero
    }
    
    // MARK: - Error view delegate
    
    func retryRequest() {
        request?.resume()
        tableView.reloadData()
    }
}
