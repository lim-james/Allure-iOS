//
//  AttributesTable.swift
//  Allure
//
//  Created by James on 19/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit

class AttributesDelegate: NSObject, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.endEditing(true)
    }
    
}
