//
//  AddShowVC.swift
//  airDates
//
//  Created by Alex Mikhaylov on 03/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import UIKit


final class AddShowVC: UITableViewController {

    private var totalPageCount = 0
    private var currentPageCount = 0
    private var searchText = ""

    weak var delegate: ShowCellDelegate?

    private var timer: Timer?
    var shows: [BasicShowMetaInfo] = []

    var myShows: [MOShow]?

    private let searchController = UISearchController(searchResultsController: nil)

    private func setupSearchBar() {
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }

    override func loadView() {
        super.loadView()
        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = .lightPink

        if #available(iOS 13, *) {
            view.backgroundColor = .systemBackground
            tableView.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
            tableView.backgroundColor = .white
        }
        setupSearchBar()

        tableView.tableFooterView = UIView()

        myShows = CoreDataManager.shared.getFetchedResultsController().fetchedObjects

        tableView.register(ShowCell.self, forCellReuseIdentifier: ShowCell.reuseId)
    }

    // MARK: - TableView

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let showExpandedVC = ShowExpandedVC()
        let showModel = shows[indexPath.row]
        let show = showModel.showInfo
        showExpandedVC.delegate = self
        showExpandedVC.showTitle = show.name
        showExpandedVC.showId = show.id
        showExpandedVC.imgUrl = show.image_thumbnail_path
        showExpandedVC.image = showModel.image

        present(showExpandedVC, animated: true)

        showExpandedVC.setupUI(network: show.network, country: show.country, status: show.status)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shows.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let showModel = shows[indexPath.row]
        let show = showModel.showInfo
        let cell = tableView.dequeueReusableCell(withIdentifier: ShowCell.reuseId, for: indexPath) as! ShowCell

        cell.delegate = self
        cell.selectionStyle = .gray

        if let myShows = myShows {

            for myShow in myShows {
                if myShow.id == Int32(show.id) {
                    cell.isTrackingShow = true
                }
            }
            cell.isActive = true
        }

        cell.showId = show.id
        cell.title = show.name
        cell.imgUrl = show.image_thumbnail_path

        if let image = showModel.image {
            cell.img = image
        } else {
            NetworkManager.downloadImage(link: show.image_thumbnail_path) { [weak cell, weak self] image in
                DispatchQueue.main.async {
                    cell?.img = image
                    self?.shows[indexPath.row].image = image
                }
            }
        }

        cell.title = show.name
        cell.subtitle = show.status

        // Check if loading extra rows is needed.
        if indexPath.row == shows.count - 1 { loadExtraRowsIfNeeded() }

        return cell
    }
}

extension AddShowVC: UISearchBarDelegate {

    private func loadExtraRowsIfNeeded() {
        guard totalPageCount > currentPageCount, searchText != "", searchText.count > 1 else { return }

        NetworkManager.getSearchQueryResults(query: searchText, page: currentPageCount) { [weak self] results in

            guard let results = results else { return }

            self?.shows += results.tv_shows.map { BasicShowMetaInfo(showInfo: $0) }
            self?.totalPageCount = results.pages
            self?.currentPageCount += 1

            DispatchQueue.main.async { [weak self] in
                UIView.animate(withDuration: 0.3) {
                    self?.tableView.reloadData()
                }
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in

            guard searchText != "", searchText.count > 1 else {
                self?.shows = []
                self?.tableView.reloadData()
                return
            }

            NetworkManager.getSearchQueryResults(query: searchText, page: 1) { [weak self] results in
                guard let results = results else { return }

                self?.shows = results.tv_shows.map { BasicShowMetaInfo(showInfo: $0) }
                self?.totalPageCount = results.pages
                self?.currentPageCount = 1

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

extension AddShowVC: ShowCellDelegate {
    func didAddShow() {
        self.delegate?.didAddShow()
    }
}
