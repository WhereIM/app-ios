//
//  DialogMobileEnchantment.swift
//  whereim
//
//  Created by Buganini Q on 14/06/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class DialogMobileEnchantment {
    init(_ viewController: UIViewController) {
        let alert = UIAlertController(title: "mobile_enchantment".localized, message: "mobile_enchantment_desc".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "close".localized, style: .default, handler: nil))
        viewController.present(alert, animated: true, completion:nil)
    }
}
