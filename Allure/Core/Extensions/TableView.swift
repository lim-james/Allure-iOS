//
//  TableView.swift
//  Allure
//
//  Created by James on 23/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit

extension UITableViewCell {
    var tableView: UITableView? {
        return self.next(of: UITableView.self)
    }

    var indexPath: IndexPath? {
        return self.tableView?.indexPath(for: self)
    }
}
