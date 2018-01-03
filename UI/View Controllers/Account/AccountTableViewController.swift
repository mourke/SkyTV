//
//  AccountTableViewController.swift
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
import SafariServices

class AccountTableViewController: UITableViewController, AuthenticatorDelegate {
    
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView?
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if indexPath.row == 0 && indexPath.section == 0 {
            cell.textLabel?.text = API.Authenticator.shared.isAuthenticated ? "Sign Out" : "Sign In"
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row, indexPath.section) {
        case (0, 0):
            let authenticator = API.Authenticator.shared
            
            if authenticator.isAuthenticated {
                let alertController = UIAlertController.init(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction.init(title: "Sign Out", style: .destructive) { _ in
                    OAuthCredential.delete(identifier: credentialIdentifier)
                    tableView.reloadData()
                })
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                present(alertController, animated: true)
            } else {
                let task = authenticator.signInURL { [unowned self] (error, url) in
                    if let url = url {
                        let safariViewController = SFSafariViewController(url: url)
                        safariViewController.modalPresentationStyle = .formSheet
                        
                        authenticator.add(listener: self)
                        self.present(safariViewController, animated: true)
                    } else if let error = error {
                        let alertController = UIAlertController(title: "Failed to authenticate", message: error.localizedDescription, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        
                        self.present(alertController, animated: true)
                    }
                }
                
                task.resume()
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? WKWebViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            
            let url: URL
            
            if indexPath.section == 2 {
                url = URL(string: "https://secure.sky.com/device-management")!
                destination.navigationItem.title = "Manage Devices"
            } else {
                if indexPath.row == 0 {
                    url = URL(string: "https://config.sky.com/GB/Sky/Go/iOS/Info/terms.html")!
                    destination.navigationItem.title = "Terms of Service"
                } else {
                    url = URL(string: "https://config.sky.com/GB/Sky/Go/iOS/Info/privacy.html")!
                    destination.navigationItem.title = "Privacy Policy"
                }
            }
            
            var request = URLRequest(url: url)
            request.addValue("ADRUM", forHTTPHeaderField: "isAjax:true")
            request.addValue("ADRUM_1", forHTTPHeaderField: "isMobile:true")
            
            destination.request = request
        }
    }
    
    // MARK: - Authenticator delegate
    
    func authenticationDidStart() {
        activityIndicatorView?.isHidden = false
        presentedViewController?.dismiss(animated: true)
    }
    
    func authenticationDidFinish(error: Error?) {
        API.Authenticator.shared.remove(listener: self)
        
        tableView.reloadData()
        activityIndicatorView?.isHidden = true
        
        if let error = error {
            let alertController = UIAlertController(title: "Failed to sign in", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(alertController, animated: true)
        }
    }
}

