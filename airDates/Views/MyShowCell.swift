//
//  MyShowCell.swift
//  airDates
//
//  Created by Alex Mikhaylov on 08.07.2020.
//  Copyright © 2020 Alexander Mikhaylov. All rights reserved.
//

import UIKit

protocol ShowCellDelegate: AnyObject {
    func didAddShow()
}

final class MyShowCell: UITableViewCell {

    class var reuseId: String {
        return "MyShowCell"
    }

    weak var delegate: ShowCellDelegate?

    var showId: Int?
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    var imgUrl: String?

    var nextEpisode: String? {
        get {
            return nextEpisodeLabel.text
        }
        set {
            nextEpisodeLabel.text = newValue ?? ""
        }
    }
    var thumbnailImage: UIImage? {
        get {
            return imgView.image
        }
        set {
            imgView.image = newValue
        }
    }

    private lazy var imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.backgroundColor = .gray
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 4
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.font = titleLabel.font.withSize(24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    private lazy var nextEpisodeLabel: UILabel = {
        let nextEpisodeLabel = UILabel()
        nextEpisodeLabel.translatesAutoresizingMaskIntoConstraints = false
        return nextEpisodeLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        if #available(iOS 13.0, *) {
            titleLabel.textColor = .label
            nextEpisodeLabel.textColor = .secondaryLabel
        } else {
            titleLabel.textColor = .black
            nextEpisodeLabel.textColor = .darkGray
        }

        [imgView, titleLabel, nextEpisodeLabel].forEach(addSubview)

        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func prepareForReuse() {
        super.prepareForReuse()

        imgView.image = nil
        titleLabel.text = ""
        nextEpisodeLabel.text = ""
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            imgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            imgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            imgView.widthAnchor.constraint(equalTo: imgView.heightAnchor, multiplier: 0.675),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            nextEpisodeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            nextEpisodeLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16),
            nextEpisodeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
