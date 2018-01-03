//
//  CountryOrRegionTableViewController.swift
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

class CountryOrRegionTableViewController: UITableViewController, ErrorViewDelegate {
    
    @IBOutlet var segmentedControl: UISegmentedControl?
    
    var regions: [Region] = []
    var request: URLSessionTask?
    
    @IBAction func segmentedControlDidChangeSegment(sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        request = API.regions { [unowned self] (error, regions) in
            if let error = error {
                let errorView = ErrorView(with: error)
                errorView.delegate = self
                self.tableView.backgroundView = errorView
                return
            }
            self.regions = regions
            self.tableView.reloadData()
        }
        
        request?.resume()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if regions.isEmpty {
            let loadingView = Bundle.main.loadNibNamed("LoadingView", owner: nil)?.first as! UIView
            tableView.backgroundView = loadingView
            segmentedControl?.isHidden = true
        } else {
            tableView.backgroundView = nil
            segmentedControl?.isHidden = false
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = segmentedControl?.selectedSegmentIndex ?? 0
        return index == 0 ? regions.filter({$0.broadcastQuality == .hd}).count : regions.filter({$0.broadcastQuality == .sd}).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let index = segmentedControl?.selectedSegmentIndex ?? 0
        let regions = index == 0 ? self.regions.filter({$0.broadcastQuality == .hd}) : self.regions.filter({$0.broadcastQuality == .sd})
        let region = regions[indexPath.row]
        
        let groupingSeparator = Locale.current.groupingSeparator ?? ","
        
        cell.textLabel?.text = region.name + "\(groupingSeparator) " + region.broadcastQuality.rawValue
        
        if let currentRegion = Region.current {
            cell.accessoryType = currentRegion == region ? .checkmark : .none
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = segmentedControl?.selectedSegmentIndex ?? 0
        let regions = index == 0 ? self.regions.filter({$0.broadcastQuality == .hd}) : self.regions.filter({$0.broadcastQuality == .sd})
        
        Region.current = regions[indexPath.row]
        tableView.reloadData()
        
        navigationItem.rightBarButtonItem?.isEnabled = true // When this view controller is presented at the start of the app, the user must choose a region before they can continue. Once a region has been chosen, they are free to continue using the app.
    }
    
    // MARK - Error view delegate
    
    func retryRequest() {
        request?.resume()
        tableView.reloadData()
    }
}
