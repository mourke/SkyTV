//
//  FilterTableViewController.swift
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

protocol FilterTableViewControllerDelegate: class {
    func filterDidChange(_ newFilter: Filter)
}

class FilterTableViewController: UITableViewController {
    
    var filters: [Filter] = []
    var currentFilter: Filter!
    
    weak var delegate: FilterTableViewControllerDelegate?
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        popoverPresentationController?.backgroundColor = view.backgroundColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        preferredContentSize = tableView.contentSize
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filter = filters[indexPath.row]
        let cell: UITableViewCell
        
        if filter.childNodes.isEmpty {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            if let currentFilter = currentFilter, filter == currentFilter {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
        }
        
        cell.textLabel?.text = filter.name
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = filters[indexPath.row]
        
        if filter.childNodes.isEmpty {
            currentFilter = filter
            tableView.reloadData()
            delegate?.filterDidChange(filter)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FilterTableViewController,
            segue.identifier == "showDetail",
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            let selectedFilter = filters[indexPath.row]
            
            destination.navigationItem.title = selectedFilter.name
            destination.filters = selectedFilter.childNodes
            destination.currentFilter = currentFilter
            destination.delegate = delegate
        }
    }
}
