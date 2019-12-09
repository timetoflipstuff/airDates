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
    
    var addButtonActive = false
    
    var isTracked = false
    
    var imgView = UIImageView()
    var titleLabel = UILabel()
    var airLabel = UILabel()
    var addButton = UIButton()
    var showId: Int?
    var title: String?
    var imgUrl: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.numberOfLines = 2
        titleLabel.font = titleLabel.font.withSize(24)
        airLabel.textColor = .darkGray
        imgView.backgroundColor = .gray
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 4
        addButton.layer.cornerRadius = 4
        addButton.addTarget(self, action: #selector(addShow), for: .touchUpInside)
        updateTrackButton()
        
        contentView.backgroundColor = .white
        contentView.addSubview(imgView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(airLabel)
        contentView.addSubview(addButton)
        
        imgView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        airLabel.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        imgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        imgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        imgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        imgView.widthAnchor.constraint(equalTo: imgView.heightAnchor, multiplier: 0.675).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        
        airLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        airLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 16).isActive = true
        airLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        
        addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.isTracked = false
        self.imgView.image = nil
        self.titleLabel.text = ""
        self.airLabel.text = ""
        
        updateTrackButton()
    }
    
}
