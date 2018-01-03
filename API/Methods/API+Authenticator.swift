//
//  API+Authenticator.swift
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

import Foundation

/// The name of the credential stored when the user has sucessfully authenticated. This can be used to retrieve the credential from the user's keychain
public let credentialIdentifier = "SkyTVCredential"

/**
 This class provides information about the success of the authentication request. All methods are _required_ and therefore must be implemented.
 */
protocol AuthenticatorDelegate: class {
    /**
     Called right before the OAuth initiation process starts.
     */
    func authenticationDidStart()
    
    /**
     Called right after a response has been received from the OAuth API.
     
     - Parameter error: If the request fails, the reason for failure will be supplied. If this property is `nil`, the request has completed successfully.
     */
    func authenticationDidFinish(error: Error?)
}

extension API {
    
    /**
     This class is used to help the user authenticate with SkyGo.
     
         1. Call the `signInURL:callback:` method.
         2. Open the URL received in some webview - `SFSafariViewController`, `Safari`, `WKWebView` etc. - and register for the scheme: 'skygo://auth'.
         3. Pass the 'code' received from this URL into the `credential:code:callback:` method.
         4. Done! 🎉🎉. The credential will have been stored in the user's keychain for later use.
     */
    class Authenticator {
        
        /// Shared singleton instance
        static let shared = Authenticator()
        
        /// A boolean value indicating whether or not the user has signed in
        var isAuthenticated: Bool {
            return credential != nil
        }
        
        /// The OAuth credential retrieved from a successful authentication, if any
        var credential: OAuthCredential? {
            return OAuthCredential.retrieve(identifier: credentialIdentifier)
        }
        
        private var listeners: [AuthenticatorDelegate] = []
        
        /**
         Signs the object up to recieve `AuthenticatorDelegate` requests, if the object has not already been signed up.
         
         - Parameter listener: The object to sign up for the requests.
         */
        func add(listener: AuthenticatorDelegate) {
            if !listeners.contains(where: {listener === $0}) {
                listeners.append(listener)
            }
        }
        
        /**
         Stops further `AuthenticatorDelegate` requests from being sent to the object, if the object had signed up for said requests.
         
         - Parameter listener: The object to opt-out of the requests.
         */
        func remove(listener: AuthenticatorDelegate) {
            if let index = listeners.index(where: {$0 === listener}) {
                listeners.remove(at: index)
            }
        }
        
        /**
         The 1st step in user authentication.
         
         Returns the sign in URL to which the user should be navigated in order to complete the rest of the authentication process. Upon visiting this URL and successfully logging in, a 'code' will be passed into the application. This code must be passed to the `credential:code:callback:` method to finish authentication.
         
         - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `URL` will be returned, however, if it fails, the underlying error will be returned.
         
         - Returns: The request's `URLSessionTask` to be `resume()`ed.
         */
        func signInURL(callback: @escaping (Error?, URL?) -> Void) -> URLSessionDataTask {
            let session = URLSession.shared
            var components = URLComponents(string: Endpoints.authorise)!
            
            components.queryItems = [URLQueryItem(name: "response_type", value: "code"),
                                     URLQueryItem(name: "client_id", value: "sky"),
                                     URLQueryItem(name: "appearance", value: "compact")]
            
            let request = URLRequest(url: components.url!)
            
            let task = session.dataTask(with: request) { (data, response, error) in
                OperationQueue.main.addOperation {
                    callback(error, response?.url)
                }
            }
            
            return task
        }
        
        /**
         The last step in user authentication.
         
         Returns and stores the `OAuthCredential` object in the user's keychain. This can later be accessed by the `credential` property.
         
         - Parameter code:      The code received from the first part of the authentication process
         - Parameter callback:  The closure called when the request completes. If the request completes successfully, an `OAuthCredential` will be returned, however, if it fails, the underlying error will be returned.
         
         - Returns: The request's `URLSessionTask` to be `resume()`ed.
         */
        func credential(code: String,
                        callback: ((Error?, OAuthCredential?) -> Void)? = nil
            ) -> URLSessionDataTask {
            OperationQueue.main.addOperation {
                self.listeners.forEach { $0.authenticationDidStart() }
            }
            
            let session = URLSession.shared
            
            var request = URLRequest(url: URL(string: Endpoints.signIn)!)
            
            let tokenDictionary = ["token": ["code": code,
                                             "client_id": "sky",
                                             "redirect_uri": "skygo://auth",
                                             "grant_type": "authorization_code"]]
            let encoder = JSONEncoder()
            request.httpBody = try? encoder.encode(tokenDictionary)
            request.httpMethod = "POST"
            
            let base64 = "ethan:test1234".data(using: .utf8)!.base64EncodedString()
            request.addValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = session.dataTask(with: request) { [unowned self] (data, response, error) in
                guard let data = data else {
                    return OperationQueue.main.addOperation {
                        callback?(error, nil)
                        self.listeners.forEach { $0.authenticationDidFinish(error: error) }
                    }
                }
                
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: String] ?? [String: String]()
                    
                    if let token = dictionary["access_token"], let type = dictionary["token_type"] {
                        let credential = OAuthCredential(token: token, of: type)
                        
                        credential.store(identifier: credentialIdentifier)
                        
                        OperationQueue.main.addOperation {
                            callback?(nil, credential)
                            self.listeners.forEach { $0.authenticationDidFinish(error: nil) }
                        }
                    }
                } catch {
                    OperationQueue.main.addOperation {
                        callback?(error, nil)
                        self.listeners.forEach { $0.authenticationDidFinish(error: error) }
                    }
                }
            }
            
            return task
        }
    }
}
