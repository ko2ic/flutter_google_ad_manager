//
//  UIView+Controller.swift
//  flutter_google_ad_manager
//
//  Created by Veli Bacik on 3/20/21.
//

import Foundation


public extension UIApplication {

    static var rootViewController: UIViewController? {
        return UIApplication.shared.delegate?.window??.rootViewController
    }
}
