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

    override func viewDidLoad() {
        
        let fetchedShows = coreData.getFetchedResultsController()
        
        myShows = fetchedShows.fetchedObjects
        
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "My Shows"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleShowAddition))
        
        tableView.register(MyShowsTableVCCell.self, forCellReuseIdentifier: MyShowsTableVCCell.reuseId)
        
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
        }
        
        return cell
    }
    
    @objc private func handleShowAddition() {
        navigationController?.pushViewController(AddShowVC(), animated: true)
    }
    
}

