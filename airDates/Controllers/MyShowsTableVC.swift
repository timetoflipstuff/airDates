//
//  ViewController.swift
//  airDates
//
//  Created by Alex Mikhaylov on 03/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import UIKit
import CoreData

class MyShowsTableVC: UITableViewController {
    
    let coreData = CoreDataManager.shared
    
    var myShows: [MOShow]!
    var images: [UIImage?]!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        tableView.tableFooterView = UIView()
        
        let refreshControl = UIRefreshControl()
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshShowTable), for: .valueChanged)

        navigationItem.title = "My Shows"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleShowAddition))
        navigationItem.rightBarButtonItem?.tintColor = .lightPink
        
        tableView.register(MyShowsTableVCCell.self, forCellReuseIdentifier: MyShowsTableVCCell.reuseId)
    }
    
    @objc private func refreshShowTable() {
        
        setupTableView() {
            self.refreshControl?.endRefreshing()
        }
        
    }
    
    func setupTableView(completion: @escaping (() -> Void) = {}) {

        images = []
        myShows = []

        coreData.updateSavedShowData() {

            guard let fetchedShows = self.coreData.getFetchedResultsController().fetchedObjects else { return }

            self.myShows = fetchedShows

            for _ in fetchedShows {
                self.images.append(nil)
            }

            self.tableView.reloadData()
            completion()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myShows?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let show = myShows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MyShowsTableVCCell.reuseId, for: indexPath) as! MyShowsTableVCCell
        
        cell.titleLabel.text = show.title
        NetworkManager.shared.downloadImage(link: show.imgUrl) { image in
            cell.imgView.image = image
            if self.images.count > indexPath.row {
                self.images[indexPath.row] = image
            }
            
        }
        
        cell.nextEpisodeLabel.text = show.nextEpisodeString ?? "Unannounced"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let showExpandedVC = ShowExpandedVC()
        let show = myShows[indexPath.row]

        showExpandedVC.delegate = self
        showExpandedVC.titleLabel.text = show.title
        showExpandedVC.showId = Int(show.id)
        showExpandedVC.imgUrl = show.imgUrl
        
        if self.images.count > indexPath.row {
            showExpandedVC.imgView.image = self.images[indexPath.row]
        }
        
        
        if let network = show.network, let country = show.country, let desc = show.desc {
            showExpandedVC.networkLabel.text = "\(network), \(country)"
            
            let descString = desc.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            
            showExpandedVC.descLabel.text = descString
        } else {
            showExpandedVC.networkLabel.text = "Unknown"
        }
        
        showExpandedVC.airLabel.text = show.status
        
        navigationController?.pushViewController(showExpandedVC, animated: true)
        
        showExpandedVC.setupUI() {success in
            if success {
                
                showExpandedVC.hideOverlayView()
                
            } else {
                
                self.navigationController?.popViewController(animated: true)
                
            }
        }
    }
    
    @objc private func handleShowAddition() {
        let addShowVC = AddShowVC()
        addShowVC.delegate = self
        navigationController?.pushViewController(addShowVC, animated: true)
    }
    
}

extension MyShowsTableVC: AddShowVCCellDelegate {
    func didAddShow() {
        self.setupTableView()
    }
}
