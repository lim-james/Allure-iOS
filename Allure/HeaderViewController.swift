//
//  HeaderViewController.swift
//  Allure
//
//  Created by James on 26/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit

class HeaderViewController: UIViewController, UITextFieldDelegate {
    
    public var heightConstraint: NSLayoutConstraint!
    
    public var minHeight: CGFloat!
    private var maxHeight: CGFloat {
        return minHeight + collectionHeight
    }
    
    private var menuButton: UIButton!
    private var deleteButton: UIButton!
    
    private var textField: UITextField!
    private var emitterName: String!
    
    private var delegate: CollectionDelegate!
    private var dataSource: CollectionDataSource!
    
    private var edgeInsets: CGFloat!
    private var collectionHeight: CGFloat!
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EventManager.Instance.Subscribe(name: "CURRENT_SET", callback: #selector(HeaderViewController.CurrentSet(_:)), context: self)
        EventManager.Instance.Subscribe(name: "RELOAD_COLLECTION", callback: #selector(HeaderViewController.ReloadCollection(_:)), context: self)
        
        menuButton = UIButton()
        menuButton.setImage(UIImage(named: "expand_arrow"), for: .normal)
        menuButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        menuButton.addTarget(self, action: #selector(HeaderViewController.ToggleCollection(_:)), for: .touchUpInside)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuButton)
        
        NSLayoutConstraint.activate([
            menuButton.topAnchor.constraint(equalTo: view.topAnchor),
            menuButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            menuButton.heightAnchor.constraint(equalToConstant: minHeight),
            menuButton.widthAnchor.constraint(equalTo: menuButton.heightAnchor)
        ])
        
        deleteButton = UIButton()
        deleteButton.setImage(UIImage(named: "more"), for: .normal)
        deleteButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: view.topAnchor),
            deleteButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: minHeight),
            deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor)
        ])
        
        textField = UITextField()
        textField.delegate = self
        textField.textAlignment = .center
        textField.placeholder = "Emitter name"
        textField.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.topAnchor),
            textField.leftAnchor.constraint(equalTo: menuButton.rightAnchor, constant: 8),
            textField.rightAnchor.constraint(equalTo: deleteButton.leftAnchor, constant: 8),
//            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.heightAnchor.constraint(equalTo: menuButton.heightAnchor)
        ])
        
        delegate = CollectionDelegate()
        dataSource = CollectionDataSource()
        
        edgeInsets = 10
        collectionHeight = 150
        let cellSize = collectionHeight - edgeInsets * 2.0
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = edgeInsets
        flowLayout.sectionInset = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        flowLayout.itemSize = CGSize(width: cellSize * 5.0 / 3.0, height: cellSize)
        flowLayout.scrollDirection = .horizontal

        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.delegate = delegate
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = .systemBackground
        collectionView.register(AddCell.self, forCellWithReuseIdentifier: "Add")
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: textField.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        emitterName = textField.text
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if emitterName != textField.text {
            EventManager.Instance.Trigger(name: "EMITTER_NAME", data: textField.text!)
        }
        return true
    }
    
    @objc private func ToggleCollection(_ target: UIButton) {
        textField.resignFirstResponder()
        
        if heightConstraint.constant == minHeight {
            heightConstraint.constant = maxHeight
        } else {
            heightConstraint.constant = minHeight
        }
        
        UIView.animate(withDuration: 0.5) {
            self.menuButton.transform =  self.menuButton.transform.rotated(by: CGFloat.pi)
            self.view.superview?.superview?.layoutIfNeeded()
        }
    }
    
    public func SetManager(_ manager: CollectionManager) {
        delegate.manager = manager
        dataSource.manager = manager
        collectionView.reloadData()
    }
    
    @objc private func CurrentSet(_ data: Any) {
        if let name = data as? String {
            textField.text = name
        }
    }
    
    @objc private func ReloadCollection(_ data: Any) {
        if let index = data as? Int {
            if index < 0 {
                collectionView.reloadData()
            } else {
                collectionView.reloadItems(at: [IndexPath(item: index + 1, section: 0)])
            }
        }
    }
}
