//
//  DialogSendSharingNotification.swift
//  whereim
//
//  Created by Buganini Q on 13/02/2018.
//  Copyright © 2018 Where.IM. All rights reserved.
//

import MaterialComponents.MaterialSnackbar
import UIKit

class DialogSendSharingNotification {
    init(_ viewController: UIViewController, _ channel_id: String) {
        let message = MDCSnackbarMessage()
        message.text = "begin_sharing".localized

        let action = MDCSnackbarMessageAction()
        let actionHandler = {() in
            let service = CoreService.bind()
            service.sendNotification(channel_id, "begin_sharing")
        }
        action.handler = actionHandler
        action.title = "send".localized
        message.action = action

        MDCSnackbarManager.show(message)
    }
}
