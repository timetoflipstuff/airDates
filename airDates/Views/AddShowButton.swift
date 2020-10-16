//
//  AddShowButton.swift
//  airDates
//
//  Created by Alex Mikhaylov on 04.05.2020.
//  Copyright © 2020 Alexander Mikhaylov. All rights reserved.
//

import UIKit

/// "Track" button.
final class AddShowButton: UIButton {

    /// Current state of the button.
    /// Determined by the combination of isActive and isTrackingShow.
    /// Will update isActive and isTrackingShow if set.
    var buttonState: AddShowButtonState {
        get {
            if isActive {
                return isTrackingShow ? .tracking : .notTracking
            } else {
                return .inactive
            }
        }
        set {
            updateProperties(for: newValue)
        }
    }

    /// Determines whether the color of `untracking` state is black or white.
    var isInCell = false

    /// Indicates whether the button is set to states other than .inactive.
    var isActive: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    /// Indicates whether the button will display "Track" or "Untrack" when isActive = true
    var isTrackingShow: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    /// Initializes button with provided state.
    /// - Parameter buttonState: Whether button will display "Track", "Untrack" or "Unavailable"
    init(with buttonState: AddShowButtonState) {
        super.init(frame: .zero)

        titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.buttonState = buttonState

        layer.borderWidth = 1
    }

    /// Initializes the Button with given parameters.
    /// - Parameters:
    ///   - isActive: Determines whether the button is available or not.
    ///   - isTrackingShow: Determines whether the button displays "Track" or "Untrack".
    convenience init(isActive: Bool = false, isTrackingShow: Bool = false) {
        self.init(with: .inactive)
        self.isActive = isActive
        self.isTrackingShow = isTrackingShow
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 4
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func updateProperties(for state: AddShowButtonState) {

        switch state {
        case .tracking:
            isActive = true
            isTrackingShow = true
        case .notTracking:
            isActive = true
            isTrackingShow = false
        case .inactive:
            isActive = false
        }
    }

    private func updateAppearance() {

        let trackingColor: UIColor
        if isInCell {
            if #available(iOS 13, *) {
                trackingColor = .label
            } else {
                trackingColor = .black
            }
        } else {
            trackingColor = .white
        }

        switch buttonState {
        case .tracking:
            backgroundColor = .clear
            layer.borderColor = trackingColor.cgColor
            setTitleColor(trackingColor, for: UIControl.State.normal)
            setTitle("Untrack", for: UIControl.State.normal)
        case .notTracking:
            backgroundColor = .lightPink
            layer.borderColor = UIColor.lightPink.cgColor
            setTitleColor(.white, for: UIControl.State.normal)
            setTitle("Track", for: UIControl.State.normal)
        case .inactive:
            backgroundColor = .clear
            layer.borderColor = UIColor.gray.cgColor
            setTitleColor(.gray, for: UIControl.State.normal)
        }
    }
}
