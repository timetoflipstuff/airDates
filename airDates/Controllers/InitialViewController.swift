//
//  InitialViewController.swift
//  airDates
//
//  Created by Alex Mikhaylov on 10/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        let nameLabel = UILabel()
        
        nameLabel.font = nameLabel.font.withSize(45)
        nameLabel.textColor = .lightPink
        
        nameLabel.center = view.center
        nameLabel.textAlignment = .center
        nameLabel.frame = view.frame
        
        nameLabel.text = "airDates"
        
        view.addSubview(nameLabel)
        
    }
    
}
