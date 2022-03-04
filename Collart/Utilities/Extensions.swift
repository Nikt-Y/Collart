//
//  Extensions.swift
//  Collart
//
//  Created by Nik Y on 28.12.2023.
//

import SwiftUI

extension AnyTransition {
    static var fadeInAndScale: AnyTransition {
        let insertion = AnyTransition.opacity.combined(with: .scale)
        let removal = AnyTransition.scale.combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
