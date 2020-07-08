//
//  MyShowsVC.swift
//  airDates
//
//  Created by Alex Mikhaylov on 03/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import UIKit
import CoreData

fileprivate struct ShowCellModel {
    var show: MOShow
    var minutesTilNextEpisode: Int? = nil
    var thumbnailImage: UIImage? = nil
}

/// The "My Shows" screen.
final class MyShowsVC: UITableViewController {
    
    private let coreData = CoreDataManager.shared
    private var myShows: [ShowCellModel] = []

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

        tableView.register(MyShowCell.self, forCellReuseIdentifier: MyShowCell.reuseId)
    }

    @objc private func refreshShowTable() {
        setupTableView() {
            self.refreshControl?.endRefreshing()
        }
    }

    func setupTableView(completion: @escaping (() -> Void) = {}) {

        myShows = []
        tableView.reloadData()

        coreData.updateSavedShowData() {

            guard let fetchedShows = self.coreData.getFetchedResultsController().fetchedObjects else {
                self.myShows = []
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    completion()
                }

                completion()
                return
            }

            self.myShows = fetchedShows.map { ShowCellModel(show: $0) }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

            completion()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myShows.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let show = myShows[indexPath.row].show
        let cell = tableView.dequeueReusableCell(withIdentifier: MyShowCell.reuseId, for: indexPath) as! MyShowCell

        cell.title = show.title
        cell.nextEpisode = ModelHelper.getNextEpisodeString(from: show.nextEpisodeDateSnapshot) ??
            show.status == "Running" ? "Unannounced" : show.status
        NetworkManager.shared.downloadImage(link: show.imgUrl) { image in
            DispatchQueue.main.async { [weak self, weak cell] in
                cell?.thumbnailImage = image
                self?.myShows[indexPath.row].thumbnailImage = image
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let showExpandedVC = ShowExpandedVC()
        let showModel = myShows[indexPath.row]
        let show = showModel.show

        showExpandedVC.delegate = self
        showExpandedVC.imgView.image = showModel.thumbnailImage
        showExpandedVC.titleLabel.text = show.title
        showExpandedVC.showId = Int(show.id)
        showExpandedVC.imgUrl = show.imgUrl
        showExpandedVC.imgView.image = showModel.thumbnailImage

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
