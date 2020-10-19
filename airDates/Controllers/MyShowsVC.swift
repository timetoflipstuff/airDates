//
//  MyShowsVC.swift
//  airDates
//
//  Created by Alex Mikhaylov on 03/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import UIKit
import CoreData

/// The "My Shows" screen.
final class MyShowsVC: UITableViewController {
    
    private let coreData = CoreDataManager.shared
    private var myShows: [ShowMetaInfo] = []

    override func loadView() {
        super.loadView()
        navigationItem.largeTitleDisplayMode = .always
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            tableView.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
            tableView.backgroundColor = .white
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

        tableView.register(ShowCell.self, forCellReuseIdentifier: ShowCell.reuseId)
    }

    @objc private func refreshShowTable() {
        setupTableView() {
            self.refreshControl?.endRefreshing()
        }
    }

    func setupTableView(completion: @escaping (() -> Void) = {}) {

        myShows = []
        tableView.reloadData()

        guard let fetchedShows = coreData.getFetchedResultsController().fetchedObjects else {
            // TO DO: Add a "Something went wrong" screen.
            myShows = []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                completion()
            }
            return
        }

        NetworkManager.getShowsData(ids: fetchedShows.map { $0.id }) { [weak self] in
            self?.myShows = $0
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                completion()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myShows.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let show = myShows[indexPath.row].showInfo
        let cell = tableView.dequeueReusableCell(withIdentifier: ShowCell.reuseId, for: indexPath) as! ShowCell

        cell.title = show.name

        if let nextEpisodeDate = try? ModelHelper.getEpisodeDate(from: show.countdown?.air_date),
            let nextEpisodeString = ModelHelper.getNextEpisodeString(from: nextEpisodeDate) {
            cell.subtitle = nextEpisodeString
        } else {
            cell.subtitle = show.status == "Running" ? "Unannounced" : show.status
        }

        cell.isAddShowButtonHidden = true

        NetworkManager.downloadImage(link: show.thumbnailPath) { image in
            DispatchQueue.main.async { [weak self, weak cell] in
                cell?.img = image
                self?.myShows[indexPath.row].image = image
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let showExpandedVC = ShowExpandedVC()
        let showModel = myShows[indexPath.row]
        let show = showModel.showInfo

        showExpandedVC.delegate = self
        showExpandedVC.image = myShows[indexPath.row].image
        showExpandedVC.showTitle = show.name
        showExpandedVC.showId = Int(show.id)
        showExpandedVC.imgUrl = show.thumbnailPath

        navigationController?.pushViewController(showExpandedVC, animated: true)

        showExpandedVC.setupUI(network: show.network, country: show.country, status: show.status)
    }

    @objc private func handleShowAddition() {
        let addShowVC = AddShowVC()
        addShowVC.delegate = self
        navigationController?.pushViewController(addShowVC, animated: true)
    }
}

extension MyShowsVC: ShowCellDelegate {
    func didAddShow() {
        setupTableView()
    }
}
