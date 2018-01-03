//
//  SearchResultsTableViewController.swift
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

protocol SearchResultsTableViewControllerDelegate: class {
    func searchResultsController(_ searchResultsController: SearchResultsTableViewController, textDidChange newText: String, callback: @escaping (Error?, [SearchResult]) -> Void) -> URLSessionDataTask
}

class SearchResultsTableViewController: UITableViewController, UISearchResultsUpdating, ErrorViewDelegate {
    
    var searchResults: [SearchResult] = []
    var searchController: UISearchController!
    var workItem: DispatchWorkItem!
    var request: URLSessionTask?
    weak var delegate: SearchResultsTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1)
        tableView.separatorColor = UIColor(red: 58.0/255.0, green: 58.0/255.0, blue: 58.0/255.0, alpha: 1)

        let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }

    // MARK: - Search results updating
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBar = searchController.searchBar as? SearchBar else { return }
        
        workItem?.cancel()
        
        if searchBar.text == nil || searchBar.text!.isEmpty {
            searchResults.removeAll()
            tableView.reloadData()
            return
        }
        
        workItem = DispatchWorkItem {
            searchBar.isLoading = true
            
            self.request?.cancel()
            
            self.request = self.delegate?.searchResultsController(self, textDidChange: searchBar.text ?? "") { [weak self, weak searchBar] (error, searchResults) in
                if let error = error {
                    let errorView = ErrorView(with: error)
                    errorView.delegate = self
                    self?.tableView.backgroundView = errorView
                    return
                }
                self?.searchResults = searchResults
                searchBar?.isLoading = false
                self?.tableView.reloadData()
            }
            
            self.request?.resume()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchBar = searchController.searchBar as? SearchBar,
            let text = searchBar.text,
            !searchBar.isLoading,
            searchResults.isEmpty {
            let backgroundView = Bundle.main.loadNibNamed("ErrorView", owner: nil)?.first as! ErrorView
            let openQuote = Locale.current.quotationBeginDelimiter ?? "\""
            let closeQuote = Locale.current.quotationEndDelimiter ?? "\""
            
            backgroundView.titleLabel?.text = "No results"
            backgroundView.descriptionLabel?.text = "We didn't turn anything up for \(openQuote + text + closeQuote). Try something else."
            backgroundView.retryButton?.isHidden = true
            
            tableView.backgroundView = backgroundView
        } else {
            tableView.backgroundView = nil
        }
        
        return searchResults.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let searchResult = searchResults[indexPath.row]
        let searchText = searchController.searchBar.text ?? ""
        
        let attributedTitle = NSMutableAttributedString(string: searchResult.name)
        let rangeOfMatchingText = (searchResult.name as NSString).range(of: searchText, options: .caseInsensitive)
        
        attributedTitle.addAttributes([.foregroundColor : UIColor.lightGray], range: rangeOfMatchingText)
        cell.textLabel?.attributedText = attributedTitle

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Error view delegate
    
    func retryRequest() {
        request?.resume()
        tableView.reloadData()
    }
}
