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

    var showId: Int?
    var showTitle: String?
    var imgUrl: String?

    var isActive = false {
        didSet {
            DispatchQueue.main.async {
                self.addShowButton.isActive = self.isActive
            }
        }
    }
    var isTrackingShow = false {
        didSet {
            DispatchQueue.main.async {
                self.addShowButton.isTrackingShow = self.isTrackingShow
            }
        }
    }

    var episodes: [Episode] = []

    var scrollView = UIScrollView()
    var subScrollView = UIView()
    var colorScrollView = UIView()
    var colorView = UIView()

    var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.numberOfLines = 4
        titleLabel.font = UIFont.boldSystemFont(ofSize: 45)
        return titleLabel
    }()

    var imgView: UIImageView = {
        var imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.layer.shadowColor = UIColor.black.cgColor
        imgView.layer.shadowOpacity = 0.5
        imgView.layer.shadowOffset = .zero
        imgView.layer.shadowRadius = 16
        imgView.layer.cornerRadius = 4
        return imgView
    }()

    var imgViewView = UIView()

    var genreLabel: UILabel = {
        var genreLabel = UILabel()
        genreLabel.textColor = .white
        genreLabel.numberOfLines = 3
        return genreLabel
    }()

    var networkLabel = UILabel()
    var airLabel = UILabel()

    var addShowButton = AddShowButton()

    var descHeader: UILabel = {
        var descHeader = UILabel()
        descHeader.text = "Show description"
        descHeader.font = descHeader.font.withSize(35)
        return descHeader
    }()

    var descLabel: UILabel = {
        var descLabel = UILabel()
        descLabel.numberOfLines = 0
        descLabel.text = ""
        return descLabel
    }()

    var nextEpisodeHeader: UILabel = {
        var nextEpisodeHeader = UILabel()
        nextEpisodeHeader.font = nextEpisodeHeader.font.withSize(35)
        nextEpisodeHeader.text = "Upcoming episode"
        return nextEpisodeHeader
    }()

    var nextEpisodeTitle: UILabel = {
        var nextEpisodeTitle = UILabel()
        nextEpisodeTitle.text = "Not announced"
        nextEpisodeTitle.font = nextEpisodeTitle.font.withSize(21)
        return nextEpisodeTitle
    }()

    var nextEpisodeNumber = UILabel()
    var nextEpisodeDate = UILabel()

    private var overlayView = UIView()
    private var overlayRect = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13, *) {
            view.backgroundColor = .systemBackground
            subScrollView.backgroundColor = .systemBackground
            airLabel.textColor = .white
            titleLabel.textColor = .white
            descLabel.textColor = .secondaryLabel
            nextEpisodeNumber.textColor = .secondaryLabel
            nextEpisodeDate.textColor = .secondaryLabel
        } else {
            view.backgroundColor = .white
            subScrollView.backgroundColor = .white
            airLabel.textColor = .white
            titleLabel.textColor = .white
            descLabel.textColor = .darkGray
            nextEpisodeNumber.textColor = .darkGray
            nextEpisodeDate.textColor = .darkGray
        }

        navigationController?.navigationBar.tintColor = .lightPink

        networkLabel.textColor = .white

        addShowButton.addTarget(self, action: #selector(addShowButtonTapped), for: .touchUpInside)

        overlayView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        subScrollView.translatesAutoresizingMaskIntoConstraints = false
        colorView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        imgView.translatesAutoresizingMaskIntoConstraints = false
        networkLabel.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        airLabel.translatesAutoresizingMaskIntoConstraints = false
        addShowButton.translatesAutoresizingMaskIntoConstraints = false

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
        colorView.addSubview(addShowButton)
        subScrollView.addSubview(nextEpisodeHeader)
        subScrollView.addSubview(nextEpisodeTitle)
        subScrollView.addSubview(nextEpisodeNumber)
        subScrollView.addSubview(nextEpisodeDate)
        subScrollView.addSubview(descHeader)
        subScrollView.addSubview(descLabel)

        view.addSubview(overlayView)

        setupConstraints()
    }
    
    func hideOverlayView() {

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
    
    func setupUI(completion: @escaping(Bool) -> Void) {

        guard let imgUrl = imgUrl, let showId = showId, let myShows = fetchedResultsController.fetchedObjects else {return}

        for myShow in myShows {
            if myShow.id == Int32(showId) {
                isTrackingShow = true
            }
        }

        isActive = true

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

    @objc private func addShowButtonTapped() {
        
        if isActive {

            guard let id = showId, let title = titleLabel.text, let imgUrl = imgUrl else {return}
            isTrackingShow = !isTrackingShow
            isActive = false

            if isTrackingShow {

                CoreDataManager.shared.saveShow(id: Int32(id), title: title, imgUrl: imgUrl, status: airLabel.text ?? nil) {success in

                    if success {
                        DispatchQueue.main.async {
                            self.delegate?.didAddShow()
                        }
                    } else {
                        self.isTrackingShow = false
                    }
                    self.isActive = true
                }

            } else {

                CoreDataManager.shared.deleteShow(id: Int32(id)) {success in

                    if success {
                        DispatchQueue.main.async {
                            self.delegate?.didAddShow()
                        }
                    } else {
                        self.isTrackingShow = true
                    }
                    self.isActive = true
                }
            }
        }
        
    }

    // MARK: - Constraints
    
    private func setupConstraints() {

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            overlayView.leftAnchor.constraint(equalTo: view.leftAnchor),
            overlayView.rightAnchor.constraint(equalTo: view.rightAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            subScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            subScrollView.bottomAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 16),
            subScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            subScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            colorView.topAnchor.constraint(equalTo: subScrollView.topAnchor),
            colorView.bottomAnchor.constraint(equalTo: addShowButton.bottomAnchor, constant: 32),
            colorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: subScrollView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            imgView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            imgView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imgView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -170),
            imgView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            genreLabel.topAnchor.constraint(equalTo: imgView.topAnchor),
            genreLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16),
            genreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            networkLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 4),
            networkLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16),
            networkLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            airLabel.topAnchor.constraint(equalTo: networkLabel.bottomAnchor, constant: 4),
            airLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16),
            airLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            addShowButton.topAnchor.constraint(equalTo: airLabel.bottomAnchor, constant: 12),
            addShowButton.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16),
            addShowButton.widthAnchor.constraint(equalToConstant: 100),
            
            nextEpisodeHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextEpisodeHeader.topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 16),
            nextEpisodeHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nextEpisodeNumber.topAnchor.constraint(equalTo: nextEpisodeTitle.bottomAnchor),
            nextEpisodeNumber.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextEpisodeNumber.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nextEpisodeTitle.topAnchor.constraint(equalTo: nextEpisodeHeader.bottomAnchor, constant: 8),
            nextEpisodeTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextEpisodeTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nextEpisodeDate.topAnchor.constraint(equalTo: nextEpisodeNumber.bottomAnchor),
            nextEpisodeDate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextEpisodeDate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descHeader.topAnchor.constraint(equalTo: nextEpisodeDate.bottomAnchor, constant: 16),
            descHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            descLabel.topAnchor.constraint(equalTo: descHeader.bottomAnchor, constant: 8),
            descLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
}
