//
//  HomeTableViewController+UICollectionViewDataSourceDelegate.swift
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

extension HomeTableViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    // MARK: - Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menu!.childNodes[collectionView.tag].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let header = menu!.childNodes[collectionView.tag]
        let item = header.items[indexPath.row]
        
        let size = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: indexPath)
        
        if header.template == .poster {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "posterCell", for: indexPath) as!PosterCollectionViewCell
            
            cell.textLabel?.text = item.name
            cell.imageView?.kf.setImage(with: API.imageURL(for: item.id, with: size, type: .poster), placeholder: UIImage(named: "PreloadAsset-Movie"))
            
            return cell
        } else {
            if header.layout == .carousel {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "heroCell", for: indexPath) as! HeroCollectionViewCell
                
                cell.textLabel?.text = item.name
                cell.detailTextLabel?.text = item.provider.localizedUppercase
                cell.textView?.text = item.synopsis
                
                let placeholder = traitCollection.horizontalSizeClass == .compact ? UIImage(named: "PreloadAsset-Generic") : UIImage(named: "PreloadAsset-Movie")
                let type: ImageType = traitCollection.horizontalSizeClass == .compact ? .hero : .poster
                
                cell.imageView?.kf.setImage(with: API.imageURL(for: item.id, with: size, type: type), placeholder: placeholder)
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "backgroundCell", for: indexPath) as! BackgroundCollectionViewCell
                
                cell.textLabel?.text = item.name
                cell.imageView?.kf.setImage(with: API.imageURL(for: item.id, with: size, type: .background), placeholder: UIImage(named: "PreloadAsset-TV"))
                cell.detailTextLabel?.text = item.provider.localizedUppercase
                cell.networkBadgeView?.kf.setImage(with: API.providerBadgeURL(for: item.provider, width: Int(size.width/2.0)))
                
                return cell
            }
        }
    }
    
    // MARK: - Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Collection view delegate flow layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        let sectionInset = collectionView.safeAreaInsets.left + flowLayout.sectionInset.left + flowLayout.sectionInset.right + collectionView.safeAreaInsets.right
        var width = view.bounds.width - sectionInset
        let header = menu!.childNodes[collectionView.tag]
        let item = header.items[indexPath.row]
        let sizingView: UIView
        
        if header.template == .poster {
            let maxWidth: CGFloat = 104
            if width > maxWidth {
                width = maxWidth
            }
            
            posterSizingCell.textLabel?.text = item.name
            
            sizingView = posterSizingCell.contentView
        } else {
            if header.layout == .carousel {
                if traitCollection.horizontalSizeClass == .regular {
                    width = view.bounds.width/2.0 - sectionInset
                }
                
                heroSizingCell.textLabel?.text = item.name
                heroSizingCell.detailTextLabel?.text = item.provider.localizedUppercase
                heroSizingCell.textView?.text = item.synopsis
                
                heroSizingCell.overrideTraitCollection = collectionView.traitCollection
                
                sizingView = heroSizingCell.contentView
            } else {
                let maxWidth: CGFloat = 230
                if width > maxWidth {
                    width = maxWidth
                }
                
                backgroundSizingCell.textLabel?.text = item.name
                backgroundSizingCell.detailTextLabel?.text = item.provider.localizedUppercase
                
                sizingView = backgroundSizingCell.contentView
            }
        }
        
        sizingView.setNeedsLayout()
        sizingView.layoutIfNeeded()
        sizingView.setNeedsUpdateConstraints()
        sizingView.updateConstraintsIfNeeded()
        
        return sizingView.systemLayoutSizeFitting(CGSize(width: width.rounded(.down), height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}

