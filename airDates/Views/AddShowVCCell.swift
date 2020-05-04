//
//  AddShowVCCell.swift
//  airDates
//
//  Created by Alex Mikhaylov on 01/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import UIKit

protocol AddShowVCCellDelegate: AnyObject {
    func didAddShow()
}

class AddShowVCCell: UITableViewCell{

    public static let reuseId = "AddShowCell"

    weak var delegate: AddShowVCCellDelegate?

    var showId: Int?
    var title: String?
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

    let imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.backgroundColor = .gray
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 4
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.font = titleLabel.font.withSize(24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    let airLabel: UILabel = {
        let airLabel = UILabel()
        airLabel.translatesAutoresizingMaskIntoConstraints = false
        return airLabel
    }()

    let addShowButton: AddShowButton = {
        let addShowButton = AddShowButton()
        addShowButton.translatesAutoresizingMaskIntoConstraints = false
        return addShowButton
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addShowButton.addTarget(self, action: #selector(addShowButtonTapped), for: .touchUpInside)

        if #available(iOS 13.0, *) {
            contentView.backgroundColor = .systemBackground
            titleLabel.textColor = .label
            airLabel.textColor = .secondaryLabel
        } else {
            contentView.backgroundColor = .white
            titleLabel.textColor = .black
            airLabel.textColor = .darkGray
        }

        contentView.addSubview(imgView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(airLabel)
        contentView.addSubview(addShowButton)

        setupConstraints()
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
                        self.isActive = true
                    }
                }

            } else {

                CoreDataManager.shared.deleteShow(id: Int32(id)) {success in

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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    
    override func prepareForReuse() {
        super.prepareForReuse()

        imgView.image = nil
        titleLabel.text = ""
        airLabel.text = ""
        isActive = false
        isTrackingShow = false
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

            airLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            airLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16),
            airLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            addShowButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            addShowButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addShowButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}
