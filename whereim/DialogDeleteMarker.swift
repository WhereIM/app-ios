//
//  DialogDeleteMarker.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class DialogDeleteMarker {
    init(_ viewController: UIViewController, _ marker: Marker) {
        let alert = UIAlertController(title: "delete".localized, message: marker.name, preferredStyle: .alert)

        let action_leave = UIAlertAction(title: "delete".localized, style: .destructive) { (alert: UIAlertAction!) -> Void in
            let service = CoreService.bind()
            service.deleteMarker(marker)
        }

        alert.addAction(action_leave)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion:nil)
    }
}
