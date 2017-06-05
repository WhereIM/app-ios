//
//  Utils.swift
//  whereim
//
//  Created by Buganini Q on 06/06/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
        guard let html = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) else { return nil }
        return html
    }
}

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
