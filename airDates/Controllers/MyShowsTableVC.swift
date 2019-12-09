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
        
        super.viewDidLoad()

        navigationItem.title = "My Shows"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleShowAddition))
        
        tableView.register(MyShowsTableVCCell.self, forCellReuseIdentifier: MyShowsTableVCCell.reuseId)
        
        setupTableView()
        
    }
    
    func setupTableView() {
        
        myShows = []
        
        guard let fetchedShows = coreData.getFetchedResultsController().fetchedObjects else {return}
        
        let dispatchGroup = DispatchGroup()
        
        for fetchedShow in fetchedShows {
            
            dispatchGroup.enter()
            
            NetworkManager.shared.getShowData(id: fetchedShow.id) {showData in
                
                guard let showData = showData else {
                    
                    dispatchGroup.leave()
                    return
                    
                }
                
                var minutesTilNextEpisode: NSNumber? = 1000000
                var nextEpisodeString: String? = nil
                let status = showData.tvShow.status
                let desc = showData.tvShow.description
                let country = showData.tvShow.country
                let network = showData.tvShow.network
                
                if let countdown = showData.tvShow.countdown {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
                    dateFormatter.locale = Locale(identifier: "en_US")
                    
                    do {
                        if let difference = try self.getTimeTilNextEpisode(apiDateString: countdown.air_date) {
                            if let years = difference.year, let days = difference.day, let hours = difference.hour, let minutes = difference.minute {
                                let countdownInMinutes = years*525600 + days*1440 + hours*60 + minutes
                                minutesTilNextEpisode = countdownInMinutes as NSNumber
                                let countdown: String
                                if years > 1 {
                                    countdown = "\(years) years"
                                } else if years == 1 {
                                    countdown = "1 year"
                                } else if days > 1 {
                                    countdown = "\(days) days"
                                } else if days == 1 {
                                    countdown = "1 day"
                                } else if hours > 1 {
                                    countdown = "\(hours) hours"
                                } else if hours == 1 {
                                    countdown = "1 hour"
                                } else if minutes > 1 {
                                    countdown = "\(minutes) minutes"
                                } else {
                                    countdown = "1 minute"
                                }
                                nextEpisodeString = "New episode in \(countdown)"
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
                
                CoreDataManager.shared.updateShow(id: fetchedShow.id, desc: desc, minutesTilNextEpisode: minutesTilNextEpisode, nextEpisodeString: nextEpisodeString, status: status, country: country, network:network) {_ in
                    dispatchGroup.leave()
                }
                
            }
            
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {

            let updatedShows = self.coreData.getFetchedResultsController()
            
            self.myShows = updatedShows.fetchedObjects
            
            self.tableView.reloadData()
        }
        
    }
    
    func getTimeTilNextEpisode(apiDateString: String) throws -> DateComponents? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let date = dateFormatter.date(from: apiDateString) else {
            throw MyShowError.invalidDateStringFormat
        }
        
        dateFormatter.timeZone = TimeZone.current
        
        let difference = Calendar.current.dateComponents([.year, .day, .hour, .minute], from: Date(), to: date)
        
        return difference
        
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
        
        if let network = show.network, let country = show.country, let desc = show.desc {
            showExpandedVC.networkLabel.text = "\(network), \(country)"
            
            let descString = desc.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            
            showExpandedVC.descLabel.text = descString
        } else {
            showExpandedVC.networkLabel.text = "Unknown"
        }
        
        showExpandedVC.airLabel.text = show.status
        
        showExpandedVC.setupUI()
        
        navigationController?.pushViewController(showExpandedVC, animated: true)
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
