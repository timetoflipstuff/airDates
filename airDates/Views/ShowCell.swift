//
//  ShowCell.swift
//  airDates
//
//  Created by Alex Mikhaylov on 13.10.2020.
//  Copyright © 2020 Alexander Mikhaylov. All rights reserved.
//

import UIKit

protocol ShowCellDelegate: AnyObject {
    func didAddShow()
}

final class ShowCell: UITableViewCell{

    private lazy var imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.backgroundColor = .gray
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 4
        return imgView
    }()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        return titleLabel
    }()

    private lazy var statusLabel = UILabel()

    private lazy var addShowButton: AddShowButton = {
        let button = AddShowButton()
        button.isInCell = true
        button.isHidden = isAddShowButtonHidden
        return button
    }()

    // MARK: - Public Interface

    var isAddShowButtonHidden = false {
        didSet {
            addShowButton.isHidden = isAddShowButtonHidden
        }
    }

    static let reuseId = "ShowCell"

    weak var delegate: ShowCellDelegate?

    var showId: Int?
    var imgUrl: String?

    var title: String? { didSet { titleLabel.text = title } }

    var subtitle: String? { didSet { statusLabel.text = subtitle } }

    var img: UIImage? { didSet { imgView.image = img } }

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

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addShowButton.addTarget(self, action: #selector(addShowButtonTapped), for: .touchUpInside)

        if #available(iOS 13.0, *) {
            contentView.backgroundColor = .systemBackground
            titleLabel.textColor = .label
            statusLabel.textColor = .secondaryLabel
        } else {
            contentView.backgroundColor = .white
            titleLabel.textColor = .black
            statusLabel.textColor = .darkGray
        }

        [imgView, titleLabel, statusLabel, addShowButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func addShowButtonTapped() {

        if isActive {

            guard let id = showId, let title = titleLabel.text, let imgUrl = imgUrl else {return}
            isTrackingShow = !isTrackingShow
            isActive = false

            if isTrackingShow {

                CoreDataManager.shared.saveShow(id: Int32(id), title: title, imgUrl: imgUrl, status: statusLabel.text ?? nil) { success in

                    if success {
                        DispatchQueue.main.async {
                            self.delegate?.didAddShow()
                        }
                        self.isActive = true
                    } else {
                        self.isTrackingShow = false
                        self.isActive = true
                    }
                }

            } else {

                CoreDataManager.shared.deleteShow(id: Int32(id)) { success in

                    if success {
                        DispatchQueue.main.async {
                            self.delegate?.didAddShow()
                        }
                    } else {
                       DispatchQueue.main.async {
                           self.isTrackingShow = true
                       }
                   }
                   DispatchQueue.main.async {
                       self.isActive = true
                   }
                }
            }
        }
    }

    // MARK: - Layout

    override func prepareForReuse() {
        super.prepareForReuse()

        isActive = false
        isTrackingShow = false
        isAddShowButtonHidden = false

        title = nil
        subtitle = nil
        img = nil
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            imgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imgView.widthAnchor.constraint(equalTo: imgView.heightAnchor, multiplier: 0.675),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            addShowButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            addShowButton.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16),
            addShowButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}
