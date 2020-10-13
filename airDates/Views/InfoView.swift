//
//  InfoView.swift
//  airDates
//
//  Created by Alex Mikhaylov on 30.09.2020.
//  Copyright © 2020 Alexander Mikhaylov. All rights reserved.
//

import UIKit

final class InfoView: UIStackView {

    private lazy var genreLabel = createLabel()

    private lazy var networkLabel = createLabel()

    private lazy var statusLabel = createLabel()

    private func createLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = label.font.withSize(13)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        return label
    }

    // MARK: - Public Interface

    var genreText: String? {
        didSet {
            genreLabel.text = genreText
        }
    }

    var networkText: String? {
        didSet {
            networkLabel.text = networkText
        }
    }

    var statusText: String? {
        didSet {
            statusLabel.text = statusText
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        axis = .vertical
        alignment = .fill
        spacing = 4

        [genreLabel, networkLabel, statusLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addArrangedSubview($0)
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
