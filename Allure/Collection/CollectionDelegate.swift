//
//  CollectionDelegate.swift
//  Allure
//
//  Created by James on 2/4/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit

class CollectionDelegate: NSObject, UICollectionViewDelegate {
    
    public var manager: CollectionManager!
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        
        if row == 0 {
            manager.NewEmitter(named: "New emitter")
        } else {
            manager.SetCurrent(index: row - 1)
        }
    }
}
