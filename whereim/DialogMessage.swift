//
//  DialogMessage.swift
//  whereim
//
//  Created by Buganini Q on 28/03/2018.
//  Copyright © 2018 Where.IM. All rights reserved.
//

import UIKit

class DialogMessage {
    static func show(_ vc: UIViewController, _ message: Message, _ income: Bool, _ view: UIView, _ touchPosition: CGPoint) {
        if income {
            if message.deleted || message.hidden {
                return
            }
            if message.type == "text" || message.type == "rich" {
                _ = DialogInMessage(vc, message, view, touchPosition)
            } else if message.type == "image" {
                _ = DialogInImage(vc, message, view, touchPosition)
            }
        } else {
            if message.deleted || message.hidden {
                return
            }
            if message.type == "text" || message.type == "rich" {
                _ = DialogOutMessage(vc, message, view, touchPosition)
            } else if message.type == "image" {
                _ = DialogOutImage(vc, message, view, touchPosition)
            }
        }
    }
}

class DialogInImage {
    init(_ vc: UIViewController, _ message: Message, _ view: UIView, _ touchPosition: CGPoint) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let action_report = UIAlertAction(title: "report".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            let alert = UIAlertController(title: "confirm".localized, message: nil, preferredStyle: .alert)

            let action_leave = UIAlertAction(title: "report".localized, style: .destructive) { (alert: UIAlertAction!) -> Void in
                CoreService.bind().report(message)
            }

            alert.addAction(action_leave)
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            vc.present(alert, animated: true, completion:nil)
        }
        alert.addAction(action_report)

        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: touchPosition.x, y: touchPosition.y, width: 0, height: 0)
        vc.present(alert, animated: true, completion:nil)
    }
}

class DialogOutImage {
    init(_ vc: UIViewController, _ message: Message, _ view: UIView, _ touchPosition: CGPoint) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let action_delete = UIAlertAction(title: "delete".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            let alert = UIAlertController(title: "confirm".localized, message: nil, preferredStyle: .alert)

            let action_leave = UIAlertAction(title: "delete".localized, style: .destructive) { (alert: UIAlertAction!) -> Void in
                CoreService.bind().delete(message)
            }

            alert.addAction(action_leave)
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            vc.present(alert, animated: true, completion:nil)
        }
        alert.addAction(action_delete)

        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: touchPosition.x, y: touchPosition.y, width: 0, height: 0)
        vc.present(alert, animated: true, completion:nil)
    }
}

class DialogInMessage {
    init(_ vc: UIViewController, _ message: Message, _ view: UIView, _ touchPosition: CGPoint) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let action_copy = UIAlertAction(title: "copy".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            print("copy")
        }
        alert.addAction(action_copy)
        let action_report = UIAlertAction(title: "report".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            let alert = UIAlertController(title: "confirm".localized, message: nil, preferredStyle: .alert)

            let action_leave = UIAlertAction(title: "report".localized, style: .destructive) { (alert: UIAlertAction!) -> Void in
                CoreService.bind().report(message)
            }

            alert.addAction(action_leave)
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            vc.present(alert, animated: true, completion:nil)
        }
        alert.addAction(action_report)

        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: touchPosition.x, y: touchPosition.y, width: 0, height: 0)
        vc.present(alert, animated: true, completion:nil)
    }
}

class DialogOutMessage {
    init(_ vc: UIViewController, _ message: Message, _ view: UIView, _ touchPosition: CGPoint) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let action_copy = UIAlertAction(title: "copy".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            print("copy")
        }
        alert.addAction(action_copy)
        let action_delete = UIAlertAction(title: "delete".localized, style: .default) { (alert: UIAlertAction!) -> Void in
            let alert = UIAlertController(title: "confirm".localized, message: nil, preferredStyle: .alert)

            let action_leave = UIAlertAction(title: "delete".localized, style: .destructive) { (alert: UIAlertAction!) -> Void in
                CoreService.bind().delete(message)
            }

            alert.addAction(action_leave)
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            vc.present(alert, animated: true, completion:nil)
        }
        alert.addAction(action_delete)

        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: touchPosition.x, y: touchPosition.y, width: 0, height: 0)
        vc.present(alert, animated: true, completion:nil)
    }
}
