//
//  Utils.swift
//  whereim
//
//  Created by Buganini Q on 06/06/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import Foundation
import UIKit

// Google Places
extension String {
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
        guard let html = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) else { return nil }
        return html
    }
}

// Localization
extension String {
    var localized: String {
        let text = NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        if text != self {
            return text
        }
        let path = Bundle.main.path(forResource: "Base", ofType: "lproj")
        let bundle = Bundle(path: path!)
        if let forcedString = bundle?.localizedString(forKey: self, value: nil, table: nil) {
            return forcedString
        } else {
            return self
        }
    }

    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}


// Mapbox
extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func centerBottom() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width,
                   height: self.size.height * 2), false, self.scale)
        let _ = UIGraphicsGetCurrentContext()
        self.draw(at: CGPoint.zero)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
}
