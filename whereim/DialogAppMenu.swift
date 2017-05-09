//
//  DialogAppMenu.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class DialogAppMenu {
    init(_ viewController: UIViewController, _ sourceView: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let action_settings = UIAlertAction(title: "action_settings".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "settings")
            viewController.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "action_settings".localized, style: .plain, target: nil, action: nil)
            viewController.performSegue(withIdentifier: "settings", sender: nil)
        }

        let action_about = UIAlertAction(title: "action_about".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            viewController.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "action_about".localized, style: .plain, target: nil, action: nil)
            viewController.performSegue(withIdentifier: "about", sender: nil)
        }

        alert.addAction(action_settings)
        alert.addAction(action_about)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = sourceView
        viewController.present(alert, animated: true, completion:nil)
    }
}
