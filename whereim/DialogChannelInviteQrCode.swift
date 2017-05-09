//
//  DialogChannelInviteQrCode.swift
//  whereim
//
//  Created by Buganini Q on 09/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import SDCAlertView
import UIKit

class DialogChannelInviteQrCode {
    let alert = AlertController(title: nil, message: nil, preferredStyle: .alert)
    let qrcode = UIImageView()

    init(_ viewController: UIViewController, _ channel: Channel) {
        let screenSize: CGRect = UIScreen.main.bounds
        let e = min(screenSize.width, screenSize.height) * 0.75
        let data = channel.getLink().data(using: String.Encoding.isoLatin1, allowLossyConversion: false)

        let filter = CIFilter(name: "CIQRCodeGenerator")

        filter!.setValue(data, forKey: "inputMessage")
        filter!.setValue("Q", forKey: "inputCorrectionLevel")

        let ciImg = filter!.outputImage!

        let scaleX = e / ciImg.extent.size.width
        let scaleY = e / ciImg.extent.size.height
        let transformedImage = ciImg.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrcode.image = UIImage(ciImage: transformedImage)

        alert.title = channel.channel_name
        alert.add(AlertAction(title: "close".localized, style: .normal, handler: nil))

        qrcode.translatesAutoresizingMaskIntoConstraints = false
        alert.contentView.addSubview(qrcode)

        qrcode.centerXAnchor.constraint(equalTo: alert.contentView.centerXAnchor).isActive = true
        qrcode.topAnchor.constraint(equalTo: alert.contentView.topAnchor).isActive = true
        alert.contentView.bottomAnchor.constraint(equalTo: qrcode.bottomAnchor).isActive = true

        viewController.present(alert, animated: true, completion: nil)
    }
}
