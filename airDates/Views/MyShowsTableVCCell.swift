//
//  MyShowsTableVCCell.swift
//  airDates
//
//  Created by Alex Mikhaylov on 01/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import UIKit

class MyShowsTableVCCell: UITableViewCell{
    
    public static let reuseId = "MyShowsCell"
    
    var imgView = UIImageView()
    var titleLabel = UILabel()
    var nextEpisodeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.numberOfLines = 2
        titleLabel.font = titleLabel.font.withSize(24)
        imgView.backgroundColor = .gray
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 4
        
        if #available(iOS 13, *) {
            contentView.backgroundColor = .systemBackground
            titleLabel.textColor = .label
            nextEpisodeLabel.textColor = .secondaryLabel
        } else {
            contentView.backgroundColor = .white
            titleLabel.textColor = .black
            nextEpisodeLabel.textColor = .darkGray
        }

        contentView.addSubview(imgView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(nextEpisodeLabel)
        
        imgView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        nextEpisodeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        imgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        imgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        imgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        imgView.widthAnchor.constraint(equalTo: imgView.heightAnchor, multiplier: 0.675).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        
        nextEpisodeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        nextEpisodeLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16).isActive = true
        nextEpisodeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
