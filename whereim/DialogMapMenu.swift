//
//  DialogMapMenu.swift
//  whereim
//
//  Created by Buganini Q on 06/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class DialogMapMenu {
    init(_ mapController: MapController, _ mapView: UIView, _ touchPosition: CGPoint) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let action_openin = UIAlertAction(title: "open_in".localized + " ⤴️", style: .default) { (alert: UIAlertAction!) -> Void in
            let location = mapController.editingCoordinate
            _ = DialogOpenIn(mapController, location, nil, mapView, touchPosition)
        }

        let action_share = UIAlertAction(title: "share".localized + " ✉️", style: .default) { (alert: UIAlertAction!) -> Void in
            let location = mapController.editingCoordinate
            _ = DialogShareLocation(mapController, location, nil, mapView, touchPosition)
        }

        let action_enchantment = UIAlertAction(title: "create_enchantment".localized + " ⭕", style: .default) { (alert: UIAlertAction!) -> Void in
            _ = DialogCreateEnchantment(mapController, nil)
        }

        let action_marker = UIAlertAction(title: "create_marker".localized + " 📍", style: .default) { (alert: UIAlertAction!) -> Void in
            _ = DialogCreateMarker(mapController, nil)
        }

        let action_forge = UIAlertAction(title: "forge_location".localized + " 😈", style: .default) { (alert: UIAlertAction!) -> Void in
            let service = CoreService.bind()
            service.forgeLocation(channel: mapController.channel!, location: mapController.editingCoordinate)
        }

        alert.addAction(action_openin)
        alert.addAction(action_share)
        alert.addAction(action_enchantment)
        alert.addAction(action_marker)
        alert.addAction(action_forge)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = mapView
        alert.popoverPresentationController?.sourceRect = CGRect(x: touchPosition.x, y: touchPosition.y, width: 0, height: 0)
        mapController.present(alert, animated: true, completion:nil)
    }
}
