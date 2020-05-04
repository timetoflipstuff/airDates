//
//  AddShowButton.swift
//  airDates
//
//  Created by Alex Mikhaylov on 04.05.2020.
//  Copyright © 2020 Alexander Mikhaylov. All rights reserved.
//

import UIKit

/// "Track" button.
class AddShowButton: UIButton {

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

    /// Indicates whether the button is set to states other than .inactive.
    var isActive: Bool {
        didSet {
            updateAppearance()
        }
    }

    /// Indicates whether the button will display "Track" or "Untrack" when isActive = true
    var isTrackingShow: Bool {
        didSet {
            updateAppearance()
        }
    }

    /// Initializes button with provided state.
    /// - Parameter buttonState: Whether button will display "Track", "Untrack" or "Unavailable"
    init(with buttonState: AddShowButtonState) {

        self.isActive = false
        self.isTrackingShow = false

        super.init(frame: .zero)

        self.layer.cornerRadius = 4

        self.buttonState = buttonState
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

        switch self.buttonState {
        case .tracking:
            backgroundColor = .gray
            setTitleColor(.white, for: UIControl.State.normal)
            setTitle("Untrack", for: UIControl.State.normal)
        case .notTracking:
            backgroundColor = .lightPink
            setTitleColor(.white, for: UIControl.State.normal)
            setTitle("Track", for: UIControl.State.normal)
        case .inactive:
            self.backgroundColor = .gray
            self.setTitleColor(.white, for: UIControl.State.normal)
            self.setTitle("Unavailable", for: UIControl.State.normal)
        }
    }
}
