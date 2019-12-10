//
//  AddShowExpandedVC.swift
//  airDates
//
//  Created by Alex Mikhaylov on 07/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import UIKit

class ShowExpandedVC: UIViewController {
    
    let fetchedResultsController = CoreDataManager.shared.getFetchedResultsController()
    
    weak var delegate: AddShowVCCellDelegate?
    
    var isTracked = false
    var addButtonActive = false
    var episodes: [Episode] = []
    
    let scrollView = UIScrollView()
    let subScrollView = UIView()
    let colorScrollView = UIScrollView()
    let colorView = UIView()
    
    var titleLabel = UILabel()
    var imgView = UIImageView()
    var imgViewView = UIView()
    
    var genreLabel = UILabel()
    var networkLabel = UILabel()
    var airLabel = UILabel()
    var addButton = UIButton()
    
    var descHeader = UILabel()
    var descLabel = UILabel()
    
    var nextEpisodeHeader = UILabel()
    var nextEpisodeNumber = UILabel()
    var nextEpisodeTitle = UILabel()
    var nextEpisodeDate = UILabel()
    
    private var overlayView = UIView()
    private var overlayRect = UIView()
    
    var showId: Int?
    var showTitle: String?
    var imgUrl: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.tintColor = .lightPink
        
        subScrollView.backgroundColor = .white
        
        titleLabel.numberOfLines = 4
        titleLabel.font = UIFont.boldSystemFont(ofSize: 45)
        
        titleLabel.textColor = .white
        
        networkLabel.textColor = .white
        genreLabel.textColor = .white
        genreLabel.numberOfLines = 3
        airLabel.textColor = .white
        imgView.contentMode = .scaleAspectFit
        
        self.imgView.layer.shadowColor = UIColor.black.cgColor
        self.imgView.layer.shadowOpacity = 0.5
        self.imgView.layer.shadowOffset = .zero
        self.imgView.layer.shadowRadius = 16
        imgView.layer.cornerRadius = 4
        addButton.layer.cornerRadius = 4
        addButton.addTarget(self, action: #selector(addShow), for: .touchUpInside)
        updateTrackButton()
        
        nextEpisodeHeader.font = nextEpisodeHeader.font.withSize(35)
        nextEpisodeHeader.text = "Upcoming episode"
        nextEpisodeTitle.text = "Not announced"
        nextEpisodeTitle.font = nextEpisodeTitle.font.withSize(21)
        nextEpisodeNumber.textColor = .darkGray
        nextEpisodeDate.textColor = .darkGray
        
        descHeader.text = "Show description"
        descHeader.font = descHeader.font.withSize(35)
        descLabel.numberOfLines = 0
        descLabel.text = ""
        descLabel.textColor = .darkGray
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        subScrollView.translatesAutoresizingMaskIntoConstraints = false
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        imgView.translatesAutoresizingMaskIntoConstraints = false
        networkLabel.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        airLabel.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        nextEpisodeHeader.translatesAutoresizingMaskIntoConstraints = false
        nextEpisodeNumber.translatesAutoresizingMaskIntoConstraints = false
        nextEpisodeTitle.translatesAutoresizingMaskIntoConstraints = false
        nextEpisodeDate.translatesAutoresizingMaskIntoConstraints = false
        
        descHeader.translatesAutoresizingMaskIntoConstraints = false
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(subScrollView)
        subScrollView.addSubview(colorView)
        
        subScrollView.addSubview(titleLabel)
        colorView.addSubview(imgView)
        
        colorView.addSubview(networkLabel)
        colorView.addSubview(genreLabel)
        colorView.addSubview(airLabel)
        colorView.addSubview(addButton)
        
        subScrollView.addSubview(nextEpisodeHeader)
        subScrollView.addSubview(nextEpisodeTitle)
        subScrollView.addSubview(nextEpisodeNumber)
        subScrollView.addSubview(nextEpisodeDate)

        subScrollView.addSubview(descHeader)
        subScrollView.addSubview(descLabel)
        
        view.addSubview(overlayView)
        
        overlayView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        overlayView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        overlayView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        subScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        subScrollView.bottomAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 16).isActive = true
        subScrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        subScrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        colorView.topAnchor.constraint(equalTo: subScrollView.topAnchor).isActive = true
        colorView.bottomAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 32).isActive = true
        colorView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        colorView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: subScrollView.topAnchor, constant: 32).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        imgView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).isActive = true
        imgView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        imgView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -170).isActive = true
        imgView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        
        genreLabel.topAnchor.constraint(equalTo: imgView.topAnchor).isActive = true
        genreLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16).isActive = true
        genreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        networkLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 4).isActive = true
        networkLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16).isActive = true
        networkLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        airLabel.topAnchor.constraint(equalTo: networkLabel.bottomAnchor, constant: 4).isActive = true
        airLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16).isActive = true
        airLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true

        addButton.topAnchor.constraint(equalTo: airLabel.bottomAnchor, constant: 12).isActive = true
        addButton.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        nextEpisodeHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        nextEpisodeHeader.topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 16).isActive = true
        nextEpisodeHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        nextEpisodeNumber.topAnchor.constraint(equalTo: nextEpisodeTitle.bottomAnchor).isActive = true
        nextEpisodeNumber.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        nextEpisodeNumber.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        nextEpisodeTitle.topAnchor.constraint(equalTo: nextEpisodeHeader.bottomAnchor, constant: 8).isActive = true
        nextEpisodeTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        nextEpisodeTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        nextEpisodeDate.topAnchor.constraint(equalTo: nextEpisodeNumber.bottomAnchor).isActive = true
        nextEpisodeDate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        nextEpisodeDate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        descHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        descHeader.topAnchor.constraint(equalTo: nextEpisodeDate.bottomAnchor, constant: 16).isActive = true
        descHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true

        descLabel.topAnchor.constraint(equalTo: descHeader.bottomAnchor, constant: 8).isActive = true
        descLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        descLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
    }
    
    public func hideOverlayView() {
        
        let shrinkAnimation = CABasicAnimation(keyPath: "opacity")
        shrinkAnimation.duration = 0.3
        shrinkAnimation.fromValue = 1
        shrinkAnimation.toValue = 0
        shrinkAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        shrinkAnimation.isRemovedOnCompletion = true

        overlayView.layer.add(shrinkAnimation, forKey: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.overlayView.removeFromSuperview()
        }
        
    }
    
    public func setupUI(completion: @escaping(Bool) -> Void) {
        
        guard let imgUrl = imgUrl, let showId = showId, let myShows = fetchedResultsController.fetchedObjects else {return}
        
        for myShow in myShows {
            if myShow.id == Int32(showId) {
                isTracked = true
            }
        }
        
        addButtonActive = true
        updateTrackButton()
        
        let dispatchGroup = DispatchGroup()
        
        if let image = imgView.image {
            
            var aspectRatio = image.size.width/image.size.height
            if aspectRatio > 1.5 {
                aspectRatio = 1.5
            }
            
            self.imgView.widthAnchor.constraint(equalTo: self.imgView.heightAnchor, multiplier: aspectRatio).isActive = true
            
            if let color = image.averageColor {
                
                self.overlayView.backgroundColor = color
                self.colorView.backgroundColor = color
                self.view.backgroundColor = color
                self.nextEpisodeHeader.textColor = color
                self.descHeader.textColor = color
                
            }
            
        } else {
            
            dispatchGroup.enter()
            
            NetworkManager.shared.downloadImage(link: imgUrl) {image in
                self.imgView.image = image
                var aspectRatio = image.size.width/image.size.height
                if aspectRatio > 1.5 {
                    aspectRatio = 1.5
                }
                
                DispatchQueue.main.async {
                    
                    self.imgView.widthAnchor.constraint(equalTo: self.imgView.heightAnchor, multiplier: aspectRatio).isActive = true
                    
                    if let color = image.averageColor {
                        
                        self.colorView.backgroundColor = color
                        self.view.backgroundColor = color
                        self.nextEpisodeHeader.textColor = color
                        self.descHeader.textColor = color
                        
                    }
                    
                    dispatchGroup.leave()
                    
                }
                
            }
            
        }
        
        dispatchGroup.enter()
        
        NetworkManager.shared.getShowData(id: Int32(showId)) {showData in
            guard let showData = showData else {
                
                completion(false)
                return
                
            }
            var genreString = ""
            
            for genre in showData.tvShow.genres {
                if genreString == "" {
                    genreString += genre
                } else {
                    genreString += ", \(genre)"
                }
            }
            DispatchQueue.main.async {
                self.genreLabel.text = genreString
                let descString = showData.tvShow.description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                self.descLabel.text = descString
                
                if let nextEpisode = showData.tvShow.countdown {
                    self.nextEpisodeNumber.text = "Season \(nextEpisode.season), Episode \(nextEpisode.episode)"
                    self.nextEpisodeTitle.text = nextEpisode.name
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
                    dateFormatter.locale = Locale(identifier: "en_US")
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    
                    if let date = dateFormatter.date(from: nextEpisode.air_date) {
                        
                        dateFormatter.timeZone = TimeZone.current
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .short
                        self.nextEpisodeDate.text = "Airs on \(dateFormatter.string(from: date))"
                        
                    }
                    
                }
                
                self.subScrollView.layoutIfNeeded()
                self.scrollView.contentSize = self.subScrollView.frame.size
                dispatchGroup.leave()
                
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion(true)
        }
        
    }
    
    @objc private func addShow() {
        
        if addButtonActive {
            
            guard let id = showId, let title = titleLabel.text, let imgUrl = imgUrl else {return}
            isTracked = !isTracked
            
            updateTrackButton()
            
            if isTracked {
                
                addButtonActive = false
                CoreDataManager.shared.saveShow(id: Int32(id), title: title, imgUrl: imgUrl, status: airLabel.text ?? nil) {success in
                    
                    if success {
                        
                        DispatchQueue.main.async {
                            self.isTracked = true
                            self.delegate?.didAddShow()
                            self.updateTrackButton()
                        }
                        
                    } else {
                        
                        self.isTracked = !self.isTracked
                        
                    }
                    
                    self.addButtonActive = true
                    
                }
                
            } else {
                
                self.addButtonActive = false
                CoreDataManager.shared.deleteShow(id: Int32(id)) {success in
                    
                    if success {
                        
                        DispatchQueue.main.async {
                            self.isTracked = false
                            self.delegate?.didAddShow()
                            self.updateTrackButton()
                        }
                        
                    } else {
                        
                        self.isTracked = !self.isTracked
                        
                    }
                    
                    self.addButtonActive = true
                    
                }
                
            }
            
        } else {
            
            updateTrackButton()
            
        }
        
    }
    
    public func updateTrackButton() {
        
        if addButtonActive {
            
            if isTracked {
                
                self.addButton.backgroundColor = .gray
                self.addButton.setTitle("Untrack", for: UIControl.State.normal)
                
            } else {
                
                self.addButton.backgroundColor = .black
                self.addButton.setTitle("Track", for: UIControl.State.normal)
                
            }
            
        } else {
            
            self.addButton.backgroundColor = .gray
            self.addButton.setTitle("Unavailable", for: UIControl.State.normal)
            
        }
        
    }
    
}
