//
//  BlurImageView.swift
//  airDates
//
//  Created by Alex Mikhaylov on 23.12.2020.
//  Copyright © 2020 Alexander Mikhaylov. All rights reserved.
//

import UIKit

final class BlurImageView: UIImageView {

    override func layoutSubviews() {

        clipsToBounds = true
        contentMode = .scaleAspectFill

        let darkBlur = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: darkBlur)

        blurView.translatesAutoresizingMaskIntoConstraints = false

        insertSubview(blurView, at: 0)

        NSLayoutConstraint.activate([
            blurView.leftAnchor.constraint(equalTo: leftAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}
