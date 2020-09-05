//
//  EditorViewController.swift
//  Allure
//
//  Created by James on 25/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {

    private var delegate: AttributesDelegate!
    private var dataSource: AttributesDataSource!
    
    private(set) var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Editor"
    
        delegate = AttributesDelegate()
        dataSource = AttributesDataSource()
        
        tableView = UITableView()
        tableView.delegate = delegate
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(IntAttributeCell.self, forCellReuseIdentifier: "Int")
        tableView.register(FloatAttributeCell.self, forCellReuseIdentifier: "Float")
        tableView.register(BoolAttributeCell.self, forCellReuseIdentifier: "Bool")
        tableView.register(Vector3AttributeCell.self, forCellReuseIdentifier: "Vector3")
        tableView.register(ColorAttributeCell.self, forCellReuseIdentifier: "Color")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.FillBounds(child: tableView, parent: view)
    }
    
    public func SetEmitter(_ emitter: ParticleEmitter) {
        dataSource.emitter = emitter
        tableView.reloadData()
    }

}
