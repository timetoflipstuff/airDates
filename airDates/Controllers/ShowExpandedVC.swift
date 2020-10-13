//
//  AddShowExpandedVC.swift
//  airDates
//
//  Created by Alex Mikhaylov on 07/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import UIKit

final class ShowExpandedVC: UIViewController {

    private let fetchedResultsController = CoreDataManager.shared.getFetchedResultsController()

    private lazy var scrollView = UIScrollView()

    private lazy var subScrollView: UIView = {
        let view = UIView()
        if #available(iOS 13, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        return view
    }()

    private lazy var colorView = UIView()

    private lazy var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.textColor = .white
        return titleLabel
    }()

    private lazy var imgView: UIImageView = {
        var imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.layer.shadowColor = UIColor.black.cgColor
        imgView.layer.shadowOpacity = 0.5
        imgView.layer.shadowOffset = .zero
        imgView.layer.shadowRadius = 16
        imgView.layer.cornerRadius = 4
        return imgView
    }()

    private lazy var imgViewView = UIView()

    private lazy var addShowButton = AddShowButton()

    private lazy var descTitleLabel = titleLabel(text: "Show description")
    private lazy var descLabel = label()

    private lazy var nextEpisodeTitleLabel = titleLabel(text: "Upcoming episode")
    private lazy var nextEpisodeLabel = label(text: "Not announced", isSecondary: false)
    private lazy var nextEpisodeNumberLabel = label()
    private lazy var nextEpisodeDateLabel = label()

    private var overlayView: UIView = {
        let view = UIView()
        if #available(iOS 13, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        return view
    }()

    private func titleLabel(text: String?) -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = text
        if #available(iOS 13, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        return label
    }

    private func label(text: String? = nil, isSecondary: Bool = true) -> UILabel {
        let label = UILabel()
        label.font = label.font.withSize(15)
        label.numberOfLines = 0
        label.text = text
        if #available(iOS 13, *) {
            label.textColor = isSecondary ? .secondaryLabel : .label
        } else {
            label.textColor = isSecondary ? .darkGray : .black
        }
        return label
    }

    // MARK: - Color

    private func setColor(_ color: UIColor?) {
        let color = color ?? .darkGray
        overlayView.backgroundColor = color
        colorView.backgroundColor = color
        view.backgroundColor = color
    }

    // MARK: - Public Interface

    weak var delegate: ShowCellDelegate?

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


    var showId: Int?
    var showTitle: String? {
        didSet {
            titleLabel.text = showTitle
        }
    }
    var imgUrl: String?

    let infoView = InfoView()

    var image: UIImage? {
        didSet {
            imgView.image = image
        }
    }

    var showDescription: String? {
        get {
            return descLabel.text
        }
        set {
            descLabel.text = newValue
        }
    }

    var nextEpisodeTitle: String? {
        get {
            return nextEpisodeLabel.text
        }
        set {
            nextEpisodeLabel.text = newValue
        }
    }

    var nextEpisodeNumber: String? {
        get {
            return nextEpisodeNumberLabel.text
        }
        set {
            nextEpisodeNumberLabel.text = newValue
        }
    }

    var nextEpisodeDate: String? {
        get {
            return nextEpisodeDateLabel.text
        }
        set {
            nextEpisodeDateLabel.text = newValue
        }
    }

    // MARK: - Lifecycle

    override func loadView() {
        super.loadView()
        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        navigationController?.navigationBar.tintColor = .lightPink

        addShowButton.addTarget(self, action: #selector(addShowButtonTapped), for: .touchUpInside)

        [overlayView, scrollView, subScrollView, colorView, titleLabel, imgView, infoView, addShowButton, nextEpisodeTitleLabel, nextEpisodeNumberLabel, nextEpisodeLabel, nextEpisodeDateLabel, descTitleLabel, descLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        view.addSubview(scrollView)
        scrollView.addSubview(subScrollView)

        [colorView, titleLabel].forEach { subScrollView.addSubview($0) }

        [imgView, infoView, addShowButton].forEach { colorView.addSubview($0) }

        [nextEpisodeTitleLabel, nextEpisodeLabel, nextEpisodeNumberLabel, nextEpisodeDateLabel, descTitleLabel, descLabel].forEach {
            subScrollView.addSubview($0)
        }

        view.addSubview(overlayView)

        setupConstraints()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func hideOverlayView() {

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

    func setupUI(network: String?, country: String?, status: String?) {

        if let network = network, let country = country {
            infoView.networkText = "\(network), \(country)"
        }

        infoView.statusText = status ?? "Unknown"

        setupUI() { success in
            if success {
                self.hideOverlayView()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func setupUI(completion: @escaping(Bool) -> Void) {

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

            imgView.widthAnchor.constraint(equalTo: self.imgView.heightAnchor, multiplier: aspectRatio).isActive = true

            setColor(image.averageColor)

        } else {

            dispatchGroup.enter()

            NetworkManager.shared.downloadImage(link: imgUrl) { image in
                self.imgView.image = image
                var aspectRatio = image.size.width/image.size.height
                if aspectRatio > 1.5 {
                    aspectRatio = 1.5
                }

                DispatchQueue.main.async {

                    self.imgView.widthAnchor.constraint(equalTo: self.imgView.heightAnchor, multiplier: aspectRatio).isActive = true

                    self.setColor(image.averageColor)

                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.enter()

        NetworkManager.shared.getShowData(id: Int32(showId)) { showData in
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
                self.infoView.genreText = genreString
                let descString = showData.tvShow.description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                self.descLabel.text = descString

                if let nextEpisode = showData.tvShow.countdown {
                    self.nextEpisodeNumberLabel.text = "Season \(nextEpisode.season), Episode \(nextEpisode.episode)"
                    self.nextEpisodeLabel.text = nextEpisode.name

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
                    dateFormatter.locale = Locale(identifier: "en_US")
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

                    if let date = dateFormatter.date(from: nextEpisode.air_date) {

                        dateFormatter.timeZone = TimeZone.current
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .short
                        self.nextEpisodeDateLabel.text = "Airs on \(dateFormatter.string(from: date))"
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

                CoreDataManager.shared.saveShow(id: Int32(id), title: title, imgUrl: imgUrl, status: infoView.statusText ?? nil) {success in

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
            
            infoView.topAnchor.constraint(equalTo: imgView.topAnchor),
            infoView.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            addShowButton.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 12),
            addShowButton.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16),
            addShowButton.widthAnchor.constraint(equalToConstant: 100),
            
            nextEpisodeTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextEpisodeTitleLabel.topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 16),
            nextEpisodeTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nextEpisodeNumberLabel.topAnchor.constraint(equalTo: nextEpisodeLabel.bottomAnchor),
            nextEpisodeNumberLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextEpisodeNumberLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nextEpisodeLabel.topAnchor.constraint(equalTo: nextEpisodeTitleLabel.bottomAnchor, constant: 8),
            nextEpisodeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextEpisodeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nextEpisodeDateLabel.topAnchor.constraint(equalTo: nextEpisodeNumberLabel.bottomAnchor),
            nextEpisodeDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextEpisodeDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descTitleLabel.topAnchor.constraint(equalTo: nextEpisodeDateLabel.bottomAnchor, constant: 16),
            descTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            descLabel.topAnchor.constraint(equalTo: descTitleLabel.bottomAnchor, constant: 8),
            descLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
}
