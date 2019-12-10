//
//  AddShowVC.swift
//  airDates
//
//  Created by Alex Mikhaylov on 03/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import UIKit



class AddShowVC: UIViewController {
    
    weak var delegate: AddShowVCCellDelegate?
    
    var timer: Timer?
    var shows: [Show] = []
    var images: [UIImage?] = []
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let showExpandedVC = ShowExpandedVC()
        let show = shows[indexPath.row]
        showExpandedVC.delegate = self
        showExpandedVC.titleLabel.text = show.name
        showExpandedVC.showId = show.id
        showExpandedVC.imgUrl = show.image_thumbnail_path
        
        if self.images.count > indexPath.row {
            showExpandedVC.imgView.image = self.images[indexPath.row]
        }
        
        
        if let network = show.network, let country = show.country {
            showExpandedVC.networkLabel.text = "\(network), \(country)"
        }
        
        showExpandedVC.airLabel.text = show.status
        
        self.navigationController?.pushViewController(showExpandedVC, animated: true)
        
        showExpandedVC.setupUI() {success in
            
            if success {
                
                showExpandedVC.hideOverlayView()
                
            } else {
                
                self.navigationController?.popViewController(animated: true)
                
            }
            
        }
        
    }
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
        
        cell.delegate = self
        cell.selectionStyle = .none
        
        if let myShows = myShows {
            
            for myShow in myShows {
                if myShow.id == Int32(show.id) {
                    cell.isTracked = true
                }
            }
            
            cell.addButtonActive = true
            cell.updateTrackButton()

        }
        
        cell.showId = show.id
        cell.title = show.name
        cell.imgUrl = show.image_thumbnail_path
        
        NetworkManager.shared.downloadImage(link: show.image_thumbnail_path) { image in
            cell.imgView.image = image
            
            if self.images.count > indexPath.row {
                self.images[indexPath.row] = image
            }
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
            
            if searchText != "" {
                NetworkManager.shared.getSearchQueryResults(query: searchText, page: 1) {results in
                    guard let results = results else { return }
                    self.images = []
                    self.shows = results.tv_shows
                    for _ in self.shows {
                        self.images.append(nil)
                    }
                    if results.pages > 1 {
                        
                        let dispatchGroup = DispatchGroup()
                        for i in 2...results.pages {
                            
                            dispatchGroup.enter()
                            NetworkManager.shared.getSearchQueryResults(query: searchText, page: i) { moreResults in
                                guard let moreResults = moreResults else {return}
                                self.shows.append(contentsOf: moreResults.tv_shows)
                                for _ in moreResults.tv_shows {
                                    self.images.append(nil)
                                }
                                
                                dispatchGroup.leave()
                            }
                            
                        }
                        
                        dispatchGroup.notify(queue: DispatchQueue.main) {
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                        }
                        
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } else {
                self.shows = []
                self.images = []
                self.tableView.reloadData()
            }
            
        }
    }
}

extension AddShowVC: AddShowVCCellDelegate {
    func didAddShow() {
        self.delegate?.didAddShow()
    }
}
