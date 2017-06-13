//
//  DialogFixedEnchantment.swift
//  whereim
//
//  Created by Buganini Q on 14/06/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class DialogFixedEnchantment {
    init(_ viewController: UIViewController) {
        let alert = UIAlertController(title: "fixed_enchantment".localized, message: "fixed_enchantment_desc".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "close".localized, style: .default, handler: nil))
        viewController.present(alert, animated: true, completion:nil)
    }
}
