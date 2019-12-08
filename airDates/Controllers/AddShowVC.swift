//
//  AddShowVC.swift
//  airDates
//
//  Created by Alex Mikhaylov on 03/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import UIKit

class AddShowVC: UIViewController {
    
    var timer: Timer?
    var shows: [Show] = []
    let tableView = UITableView()
    
    var myShows: [MOShow]?
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private func setupSearchBar() {
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.showsSearchResultsButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupSearchBar()
        tableView.frame = view.safeAreaLayoutGuide.layoutFrame
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        
        myShows = CoreDataManager.shared.getFetchedResultsController().fetchedObjects
        
        tableView.register(AddShowVCCell.self, forCellReuseIdentifier: AddShowVCCell.reuseId)
        
    }
    
}

extension AddShowVC: UITableViewDelegate {
    
}

extension AddShowVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let show = shows[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: AddShowVCCell.reuseId, for: indexPath) as! AddShowVCCell
        if let myShows = myShows {
            for myShow in myShows {
                if myShow.id == Int32(show.id) {
                    cell.isTracked = true
                    cell.updateTrackButton()
                }
            }
        }
        
        cell.showId = show.id
        cell.title = show.name
        cell.imgUrl = show.image_thumbnail_path
        
        NetworkManager.shared.downloadImage(link: show.image_thumbnail_path) { image in
            cell.imgView.image = image
        }
        
        cell.titleLabel.text = show.name
        cell.airLabel.text = show.status
        
        return cell
    }
    
}

extension AddShowVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            print(searchText)
            
            if searchText != "" {
                NetworkManager.shared.getSearchQueryResults(query: searchText) { (results) in
                    guard let results = results else { return }
                    self.shows = results.tv_shows
                    print(self.shows.count)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } else {
                self.shows = []
                self.tableView.reloadData()
            }
            
        }
    }
    
    
    
}
