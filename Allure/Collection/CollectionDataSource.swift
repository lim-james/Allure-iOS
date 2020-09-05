//
//  CollectionDataSource.swift
//  Allure
//
//  Created by James on 2/4/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit

class CollectionDataSource: NSObject, UICollectionViewDataSource {
    
    public var manager: CollectionManager!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manager == nil ? 1 : manager.map.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "Add", for: indexPath) as! AddCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionCell
        
        let name = Array(manager.map.keys)[indexPath.row - 1]
        let emitter = manager.map[name]!
        
        cell.titleLabel.text = name
        cell.primaryColor = UIColor(emitter.startColor)
        cell.secondaryColor = UIColor(emitter.endColor)
        
        return cell
    }
    
}
