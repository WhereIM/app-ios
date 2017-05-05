//
//  DialogOpenIn.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import CoreLocation
import UIKit

class DialogOpenIn {
    init(_ viewController: UIViewController, _ location: CLLocationCoordinate2D, _ title: String?, _ view: UIView, _ touchPosition: CGPoint?) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let apple_maps = UIAlertAction(title: "apple_maps", style: .default) { (alert: UIAlertAction!) -> Void in
            UIApplication.shared.openURL(URL(string: "http://maps.apple.com/?ll=\(location.latitude),\(location.longitude)")!)
        }
        alert.addAction(apple_maps)


        let t = (title == nil ? "" : "\(title!)@").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let google_maps_url = URL(string: "https://www.google.com/maps?q=\(t)\(location.latitude),\(location.longitude)")!
        if (UIApplication.shared.canOpenURL(google_maps_url)) {
            let google_maps = UIAlertAction(title: "google_maps", style: .default) { (alert: UIAlertAction!) -> Void in
                UIApplication.shared.openURL(google_maps_url)
            }
            alert.addAction(google_maps)
        }

        let google_navigation_url = URL(string: "https://www.google.com/maps/dir/Current+Location/\(location.latitude),\(location.longitude)")!
        if (UIApplication.shared.canOpenURL(google_navigation_url)) {
            let google_navigation = UIAlertAction(title: "google_maps_navigation", style: .default) { (alert: UIAlertAction!) -> Void in
                UIApplication.shared.openURL(google_navigation_url)
            }
            alert.addAction(google_navigation)
        }

        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = view
        if let tp = touchPosition {
            alert.popoverPresentationController?.sourceRect = CGRect(x: tp.x, y: tp.y, width: 0, height: 0)
        }
        viewController.present(alert, animated: true, completion:nil)
    }
}
