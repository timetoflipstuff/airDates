//
//  InitialViewController.swift
//  airDates
//
//  Created by Alex Mikhaylov on 10/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    private let nameLabel = UILabel()
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        nameLabel.font = nameLabel.font.withSize(45)
        nameLabel.textColor = .lightPink
        
        nameLabel.center = view.center
        nameLabel.textAlignment = .center
        nameLabel.frame = view.frame
        
        nameLabel.text = "airDates"
        
        view.addSubview(nameLabel)
        
    }
    
    func animateFade() {
        
        let expandAnimation = CABasicAnimation(keyPath: "transform.scale")
        expandAnimation.duration = 0.3
        expandAnimation.fromValue = 1
        expandAnimation.toValue = 3
        expandAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        expandAnimation.isRemovedOnCompletion = true
        
        nameLabel.layer.add(expandAnimation, forKey: nil)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.nameLabel.removeFromSuperview()
        }
        
    }
    
}
