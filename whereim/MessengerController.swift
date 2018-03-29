//
//  MessengerController.swift
//  whereim
//
//  Created by Buganini Q on 07/03/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import SDWebImage

class InputBar: UIStackView {
    let background = UIView()
    let btn_picker = UIButton()
    let btn_camera = UIButton()
    let pin = UIImageView()
    let text = UITextView()
    let btn_send = UIButton()

    init() {
        super.init(frame: .zero)
        setView()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setView()
    }

    func setView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .horizontal
        self.alignment = .center
        self.distribution = .fill
        self.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.isLayoutMarginsRelativeArrangement = true

        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = UIColor(red:0.91, green:0.91, blue:0.91, alpha:1.0)
        background.layer.borderWidth = 1
        background.layer.borderColor = UIColor.lightGray.cgColor
        self.insertSubview(background, at: 0)

        background.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        background.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        background.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        btn_picker.translatesAutoresizingMaskIntoConstraints = false
        btn_picker.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        btn_picker.setImage(UIImage(named: "ic_insert_photo"), for: .normal)
        btn_picker.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        self.addArrangedSubview(btn_picker)

        btn_camera.translatesAutoresizingMaskIntoConstraints = false
        btn_camera.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0 , bottom: 0, right: 5)
        btn_camera.setImage(UIImage(named: "ic_camera_alt"), for: .normal)
        btn_camera.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        self.addArrangedSubview(btn_camera)

        pin.translatesAutoresizingMaskIntoConstraints = false
        pin.image = UIImage(named: "icon_pin")
        pin.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        self.addArrangedSubview(pin)

        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = .white
        text.font = UIFont.systemFont(ofSize: 17)
        text.layer.cornerRadius = 5
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.lightGray.cgColor
        text.isEditable = true
        text.isScrollEnabled = false
        text.setContentHuggingPriority(UILayoutPriority(rawValue: 0), for: .horizontal)
        self.addArrangedSubview(text)

        btn_send.translatesAutoresizingMaskIntoConstraints = false
        btn_send.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 5)
        btn_send.setTitleColor(UIColor(red:0.06, green:0.53, blue:1.00, alpha:1.0), for: .normal)
        btn_send.setTitle("send".localized, for: .normal)
        btn_send.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        self.addArrangedSubview(btn_send)

        text.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        btn_send.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}

class PendingImageCell: UITableViewCell {
    let imageview = UIImageView()
    let imageviewWidth: NSLayoutConstraint
    let imageviewHeight: NSLayoutConstraint
    var delegate: MessageViewDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        imageviewWidth = imageview.widthAnchor.constraint(equalToConstant: 200)
        imageviewWidth.isActive = true
        imageviewHeight = imageview.heightAnchor.constraint(equalToConstant: 200)
        imageviewHeight.isActive = true

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.transform = CGAffineTransform.init(scaleX: 1, y: -1)

        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.backgroundColor = UIColor(red:0.89, green:0.91, blue:0.92, alpha:1.0)
        imageview.contentMode = .scaleAspectFill
        imageview.layer.masksToBounds = true
        imageview.layer.cornerRadius = 10
        self.contentView.addSubview(imageview)

        imageview.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor, constant: 100).isActive = true
        imageview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        imageview.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        imageview.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PendingTextCell: UITableViewCell {
    let message = UITextView()
    var delegate: MessageViewDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.transform = CGAffineTransform.init(scaleX: 1, y: -1)

        message.translatesAutoresizingMaskIntoConstraints = false
        message.backgroundColor = UIColor(red:0.73, green:0.95, blue:0.56, alpha:1.0)
        message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        message.dataDetectorTypes = .all
        message.isEditable = false
        message.textContainer.lineBreakMode = .byWordWrapping
        message.isScrollEnabled = false
        message.layer.masksToBounds = true
        message.layer.cornerRadius = 10

        self.contentView.addSubview(message)

        message.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor, constant: 100).isActive = true
        message.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        message.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        message.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class InImageCell: UITableViewCell {
    let date = UILabel()
    let sender = UILabel()
    let imageview = UIImageView()
    let imageviewWidth: NSLayoutConstraint
    let imageviewHeight: NSLayoutConstraint
    let time = UILabel()
    var dateHeight: NSLayoutConstraint
    var msg: Message?
    var delegate: MessageViewDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        dateHeight = date.heightAnchor.constraint(equalToConstant: 0)

        imageviewWidth = imageview.widthAnchor.constraint(equalToConstant: 200)
        imageviewWidth.isActive = true
        imageviewHeight = imageview.heightAnchor.constraint(equalToConstant: 200)
        imageviewHeight.isActive = true

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.transform = CGAffineTransform.init(scaleX: 1, y: -1)

        date.translatesAutoresizingMaskIntoConstraints = false
        date.textAlignment = .center
        date.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)
        date.font = UIFont.systemFont(ofSize: 13)
        self.contentView.addSubview(date)

        sender.translatesAutoresizingMaskIntoConstraints = false
        sender.font = UIFont.systemFont(ofSize: 12)
        sender.textColor = .gray
        self.contentView.addSubview(sender)

        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.backgroundColor = UIColor(red:0.89, green:0.91, blue:0.92, alpha:1.0)
        imageview.contentMode = .scaleAspectFill
        imageview.layer.masksToBounds = true
        imageview.layer.cornerRadius = 10
        self.contentView.addSubview(imageview)

        imageview.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(gestureReconizer:)))
        imageview.addGestureRecognizer(tap)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureReconizer:)))
        imageview.addGestureRecognizer(longPress)

        time.translatesAutoresizingMaskIntoConstraints = false
        time.font = UIFont.systemFont(ofSize: 10)
        time.textColor = .lightGray
        self.contentView.addSubview(time)

        date.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        date.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        date.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true

        sender.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        sender.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -100).isActive = true
        sender.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 5).isActive = true

        imageview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        imageview.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -100).isActive = true
        imageview.topAnchor.constraint(equalTo: sender.bottomAnchor, constant: 2).isActive = true
        imageview.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true

        time.leadingAnchor.constraint(equalTo: imageview.trailingAnchor, constant: 5).isActive = true
        time.bottomAnchor.constraint(equalTo: imageview.bottomAnchor).isActive = true
    }

    @objc func tap(gestureReconizer: UITapGestureRecognizer) {
        if (gestureReconizer.state == UIGestureRecognizerState.ended) {
            delegate?.channelController.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
            let vc = ImageViewerController(msg!.getSender(), msg!.time!, msg!.getImage()!)
            delegate?.channelController.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func longPress(gestureReconizer: UILongPressGestureRecognizer) {
        if (gestureReconizer.state == UIGestureRecognizerState.began){
            DialogMessage.show(delegate!.channelController, msg!, true, imageview, gestureReconizer.location(in: imageview))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class OutImageCell: UITableViewCell {
    let date = UILabel()
    let imageview = UIImageView()
    let imageviewWidth: NSLayoutConstraint
    let imageviewHeight: NSLayoutConstraint
    let time = UILabel()
    var dateHeight: NSLayoutConstraint
    var msg: Message?
    var delegate: MessageViewDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        dateHeight = date.heightAnchor.constraint(equalToConstant: 0)

        imageviewWidth = imageview.widthAnchor.constraint(equalToConstant: 200)
        imageviewWidth.isActive = true
        imageviewHeight = imageview.heightAnchor.constraint(equalToConstant: 200)
        imageviewHeight.isActive = true

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.transform = CGAffineTransform.init(scaleX: 1, y: -1)

        date.translatesAutoresizingMaskIntoConstraints = false
        date.textAlignment = .center
        date.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)
        date.font = UIFont.systemFont(ofSize: 13)
        self.contentView.addSubview(date)

        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.backgroundColor = UIColor(red:0.89, green:0.91, blue:0.92, alpha:1.0)
        imageview.contentMode = .scaleAspectFill
        imageview.layer.masksToBounds = true
        imageview.layer.cornerRadius = 10
        self.contentView.addSubview(imageview)

        imageview.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(gestureReconizer:)))
        imageview.addGestureRecognizer(tap)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureReconizer:)))
        imageview.addGestureRecognizer(longPress)

        time.translatesAutoresizingMaskIntoConstraints = false
        time.font = UIFont.systemFont(ofSize: 10)
        time.textColor = .lightGray
        time.adjustsFontSizeToFitWidth = false
        self.contentView.addSubview(time)

        date.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        date.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        date.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true

        imageview.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor, constant: 100).isActive = true
        imageview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        imageview.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 5).isActive = true
        imageview.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true

        time.trailingAnchor.constraint(equalTo: imageview.leadingAnchor, constant: -10).isActive = true
        time.bottomAnchor.constraint(equalTo: imageview.bottomAnchor).isActive = true
    }

    @objc func tap(gestureReconizer: UITapGestureRecognizer) {
        if (gestureReconizer.state == UIGestureRecognizerState.ended) {
            delegate?.channelController.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
            let vc = ImageViewerController(msg!.getSender(), msg!.time!, msg!.getImage()!)
            delegate?.channelController.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func longPress(gestureReconizer: UILongPressGestureRecognizer) {
        if (gestureReconizer.state == UIGestureRecognizerState.began) {
            DialogMessage.show(delegate!.channelController, msg!, false, imageview, gestureReconizer.location(in: imageview))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class InTextCell: UITableViewCell {
    let date = UILabel()
    let sender = UILabel()
    let message = UITextView()
    let time = UILabel()
    var dateHeight: NSLayoutConstraint
    var msg: Message?
    var delegate: MessageViewDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        dateHeight = date.heightAnchor.constraint(equalToConstant: 0)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.transform = CGAffineTransform.init(scaleX: 1, y: -1)

        date.translatesAutoresizingMaskIntoConstraints = false
        date.textAlignment = .center
        date.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)
        date.font = UIFont.systemFont(ofSize: 13)
        self.contentView.addSubview(date)

        sender.translatesAutoresizingMaskIntoConstraints = false
        sender.font = UIFont.systemFont(ofSize: 12)
        sender.textColor = .gray
        self.contentView.addSubview(sender)

        message.translatesAutoresizingMaskIntoConstraints = false
        message.backgroundColor = UIColor(red:0.89, green:0.91, blue:0.92, alpha:1.0)
        message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        message.dataDetectorTypes = .all
        message.isEditable = false
        message.textContainer.lineBreakMode = .byWordWrapping
        message.isScrollEnabled = false
        message.delaysContentTouches = false
        message.layer.masksToBounds = true
        message.layer.cornerRadius = 10
        message.isSelectable = true
        self.contentView.addSubview(message)

        if let rs = message.gestureRecognizers {
            for r in rs {
                r.isEnabled = false
            }
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(gestureReconizer:)))
        message.addGestureRecognizer(tap)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureReconizer:)))
        message.addGestureRecognizer(longPress)

        time.translatesAutoresizingMaskIntoConstraints = false
        time.font = UIFont.systemFont(ofSize: 10)
        time.textColor = .lightGray
        self.contentView.addSubview(time)

        date.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        date.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        date.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true

        sender.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        sender.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -100).isActive = true
        sender.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 5).isActive = true

        message.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        message.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -100).isActive = true
        message.topAnchor.constraint(equalTo: sender.bottomAnchor, constant: 2).isActive = true
        message.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true

        time.leadingAnchor.constraint(equalTo: message.trailingAnchor, constant: 5).isActive = true
        time.bottomAnchor.constraint(equalTo: message.bottomAnchor).isActive = true
    }

    @objc func tap(gestureReconizer: UITapGestureRecognizer) {
        if (gestureReconizer.state == UIGestureRecognizerState.ended) {
            let tapLocation = gestureReconizer.location(in: message)
            guard
                let textPosition = message.closestPosition(to: tapLocation),
                let attrA = message.textStyling(at: textPosition, in: UITextStorageDirection.forward),
                let attrB = message.textStyling(at: textPosition, in: UITextStorageDirection.backward)
                else {
                    return
            }
            let urlA = attrA[NSAttributedStringKey.link.rawValue]
            let urlB = attrB[NSAttributedStringKey.link.rawValue]
            if urlA != nil || urlB != nil {
                let url = URL(string: String(describing: (urlA ?? urlB)!))!
                if delegate?.shouldInteract(with: url) != false {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }

    @objc func longPress(gestureReconizer: UILongPressGestureRecognizer) {
        if (gestureReconizer.state == UIGestureRecognizerState.began){
            DialogMessage.show(delegate!.channelController, msg!, true, message, gestureReconizer.location(in: message))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class OutTextCell: UITableViewCell {
    let date = UILabel()
    let message = UITextView()
    let time = UILabel()
    var dateHeight: NSLayoutConstraint
    var msg: Message?
    var delegate: MessageViewDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        dateHeight = date.heightAnchor.constraint(equalToConstant: 0)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.transform = CGAffineTransform.init(scaleX: 1, y: -1)

        date.translatesAutoresizingMaskIntoConstraints = false
        date.textAlignment = .center
        date.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)
        date.font = UIFont.systemFont(ofSize: 13)
        self.contentView.addSubview(date)

        message.translatesAutoresizingMaskIntoConstraints = false
        message.backgroundColor = UIColor(red:0.73, green:0.95, blue:0.56, alpha:1.0)
        message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        message.dataDetectorTypes = .all
        message.isEditable = false
        message.textContainer.lineBreakMode = .byWordWrapping
        message.isScrollEnabled = false
        message.delaysContentTouches = false
        message.layer.masksToBounds = true
        message.layer.cornerRadius = 10
        message.isSelectable = true
        self.contentView.addSubview(message)

        if let rs = message.gestureRecognizers {
            for r in rs {
                r.isEnabled = false
            }
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(gestureReconizer:)))
        message.addGestureRecognizer(tap)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureReconizer:)))
        message.addGestureRecognizer(longPress)

        time.translatesAutoresizingMaskIntoConstraints = false
        time.font = UIFont.systemFont(ofSize: 10)
        time.textColor = .lightGray
        time.adjustsFontSizeToFitWidth = false
        self.contentView.addSubview(time)

        date.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        date.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        date.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true

        message.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor, constant: 100).isActive = true
        message.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        message.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 5).isActive = true
        message.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true

        time.trailingAnchor.constraint(equalTo: message.leadingAnchor, constant: -5).isActive = true
        time.bottomAnchor.constraint(equalTo: message.bottomAnchor).isActive = true
    }

    @objc func tap(gestureReconizer: UITapGestureRecognizer) {
        if (gestureReconizer.state == UIGestureRecognizerState.ended) {
            let tapLocation = gestureReconizer.location(in: message)
            guard
                let textPosition = message.closestPosition(to: tapLocation),
                let attrA = message.textStyling(at: textPosition, in: UITextStorageDirection.forward),
                let attrB = message.textStyling(at: textPosition, in: UITextStorageDirection.backward)
            else {
                return
            }
            let urlA = attrA[NSAttributedStringKey.link.rawValue]
            let urlB = attrB[NSAttributedStringKey.link.rawValue]
            if urlA != nil || urlB != nil {
                let url = URL(string: String(describing: (urlA ?? urlB)!))!
                if delegate?.shouldInteract(with: url) != false {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }

    @objc func longPress(gestureReconizer: UILongPressGestureRecognizer) {
        if (gestureReconizer.state == UIGestureRecognizerState.began){
            DialogMessage.show(delegate!.channelController, msg!, false, message, gestureReconizer.location(in: message))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MessageViewDelegate: NSObject {
    let channelController: ChannelController
    let service: CoreService
    init(_ channelController: ChannelController, _ service: CoreService) {
        self.channelController = channelController
        self.service = service
    }

    func shouldInteract(with URL: URL) -> Bool {
        if URL.scheme! == "wim" {
            let args = URL.pathComponents
            switch URL.host! {
            case "marker":
                if let marker = service.getChannelMarker(channelController.channel!.id!, args[1]) {
                    channelController.moveTo(marker: marker)
                } else {
                    channelController.moveTo(pin: CLLocationCoordinate2D(latitude: Double(args[2])!, longitude: Double(args[3])!))
                }
            case "pin":
                channelController.moveTo(pin: CLLocationCoordinate2D(latitude: Double(args[1])!, longitude: Double(args[2])!))
            default:
                return false
            }
            return false
        }
        return true
    }
}

class MessageAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    let vc: MessengerController
    let tableView: UITableView
    let service: CoreService
    let channel: Channel
    let channelController: ChannelController
    var messageList: BundledMessages
    var viewEnd = true

    let messageViewDelegate: MessageViewDelegate

    let dateFormatter = DateFormatter()
    let lymdFormatter = DateFormatter()
    let eeeFormatter = DateFormatter()
    let timeFormatter = DateFormatter()

    init(_ viewController: MessengerController, _ tableView: UITableView, _ service: CoreService, _ channel: Channel, _ channelController: ChannelController) {
        self.vc = viewController
        self.tableView = tableView
        self.service = service
        self.channel = channel
        self.channelController = channelController
        self.messageList = service.getMessages(channel.id!)
        self.service.set(channel_id: channel.id!, unread: false)
        self.messageViewDelegate = MessageViewDelegate(channelController, service)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        lymdFormatter.dateStyle = .medium
        lymdFormatter.timeStyle = .none
        eeeFormatter.dateFormat = "EEE"
        timeFormatter.dateFormat = "HH:mm"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageList.message.count + self.messageList.pendingMessage.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var showDate = false

        if indexPath.row < messageList.pendingMessage.count {
            let message = self.messageList.pendingMessage[indexPath.row]
            if message.type == "image" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "pending_image", for: indexPath) as! PendingImageCell
                let prefix = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let path = prefix.appendingPathComponent(message.getFile()!)
                do {
                    let data = try Data(contentsOf: URL(string: path.absoluteString)!)
                    let im = UIImage(data: data)!
                    cell.imageview.image = im
                    cell.imageviewHeight.constant = cell.imageviewWidth.constant * CGFloat(im.size.height/im.size.width)
                } catch {
                    print("Unable to load data: \(error)")
                }
                cell.delegate = messageViewDelegate
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "pending_text", for: indexPath) as! PendingTextCell
                cell.delegate = messageViewDelegate
                cell.message.attributedText = Message.getText("rich", message.payload)
                cell.layoutSubviews()
                return cell
            }
        } else {
            let row = indexPath.row - messageList.pendingMessage.count
            let message = self.messageList.message[row]
            let time = Date(timeIntervalSince1970: TimeInterval(message.time!))

            let lymd = lymdFormatter.string(from: time)
            let eee = eeeFormatter.string(from: time)
            let dateString = String(format: "date_format".localized, eee, lymd)
            let timeString = timeFormatter.string(from: time)
            let messageText = message.getText()
            if row == self.messageList.message.count - 1 {
                showDate = true
            } else {
                let prev = self.messageList.message[row + 1]
                if dateFormatter.string(from: time) != dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(prev.time!))) {
                    showDate = true
                }
            }
            if let img = message.getImage() {
                if (message.mate_id == channel.mate_id) {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "out_image", for: indexPath) as! OutImageCell
                    cell.imageview.sd_setImage(with: Config.getThumbnail(img))
                    cell.imageviewHeight.constant = cell.imageviewWidth.constant * CGFloat(img.height/img.width)
                    cell.date.text = dateString
                    cell.dateHeight.isActive = !showDate
                    cell.time.text = timeString
                    cell.msg = message
                    cell.delegate = messageViewDelegate
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "in_image", for: indexPath) as! InImageCell
                    cell.sender.text = message.getSender()
                    cell.imageview.sd_setImage(with: Config.getThumbnail(img))
                    cell.imageviewHeight.constant = cell.imageviewWidth.constant * CGFloat(img.height/img.width)
                    cell.date.text = dateString
                    cell.dateHeight.isActive = !showDate
                    cell.time.text = timeString
                    cell.msg = message
                    cell.delegate = messageViewDelegate
                    return cell
                }
            }
            if (message.mate_id == channel.mate_id) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "out_text", for: indexPath) as! OutTextCell
                cell.message.attributedText = messageText
                cell.date.text = dateString
                cell.dateHeight.isActive = !showDate
                cell.time.text = timeString
                cell.msg = message
                cell.delegate = messageViewDelegate
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "in_text", for: indexPath) as! InTextCell
                cell.sender.text = message.getSender()
                cell.message.attributedText = messageText
                cell.date.text = dateString
                cell.dateHeight.isActive = !showDate
                cell.time.text = timeString
                cell.msg = message
                cell.delegate = messageViewDelegate
                return cell
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height) {
            if (messageList.loadMoreUserMessage || messageList.loadMoreChannelMessage) {
                service.requestMessage(channel, before: messageList.loadMoreBefore, after: messageList.loadMoreAfter)
            } else {
                service.requestMessage(channel, before: messageList.firstId, after: nil)
            }
        }
        viewEnd = scrollView.contentOffset.y == 0
        if viewEnd {
            self.vc.unread.isHidden = true
        }
    }

    func reload() {
        let prevLastId = self.messageList.lastId
        let viewEnd = self.viewEnd
        var rowOffset = CGFloat.init(0)
        var anchorRowId = Int64(-1)
        if let count = self.tableView.indexPathsForVisibleRows?.count {
            if count > 0 {
                for indexPath in self.tableView.indexPathsForVisibleRows! {
                    if indexPath.row >= self.messageList.pendingMessage.count {
                        anchorRowId = self.messageList.message[indexPath.row - self.messageList.pendingMessage.count].id!
                        rowOffset = self.tableView.contentOffset.y - self.tableView.rectForRow(at: indexPath).origin.y
                        break
                    }
                }
            }
        }
        self.messageList = service.getMessages(channel.id!)
        self.service.set(channel_id: channel.id!, unread: false)
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        var row = -1
        if anchorRowId != -1 {
            for i in 0..<self.messageList.message.count {
                if self.messageList.message[i].id! <= anchorRowId {
                    row = i + self.messageList.pendingMessage.count
                    break
                }
            }
        }
        if row != -1 {
            let rowY = self.tableView.rectForRow(at: IndexPath.init(row: row, section: 0)).origin.y
            self.tableView.contentOffset = CGPoint.init(x: 0, y: rowY + rowOffset)
        }
        DispatchQueue.main.async {
            if (viewEnd) {
                if(self.messageList.message.count + self.messageList.pendingMessage.count > 0){
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            } else {
                if(self.messageList.lastId > prevLastId) {
                    self.vc.unread.isHidden = false
                }
            }
        }
    }
}

class MessengerController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, Callback {
    let inputBar = InputBar()
    let unread = UITextView()
    let messageView = UITableView()
    var pinLocation: CLLocationCoordinate2D?

    var isTyping = false

    var service: CoreService?
    var channel: Channel?
    var cbkey: Int?

    var adapter: MessageAdapter?
    var bottomConstraint: NSLayoutConstraint?

    let formatter = DateFormatter()

    override func viewDidLoad() {
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

        inputBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(inputBar)
        self.bottomConstraint = inputBar.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor)
        self.bottomConstraint!.isActive = true
        inputBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        inputBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true

        inputBar.text.delegate = self
        inputBar.btn_camera.addTarget(self, action: #selector(btn_camera_clicked(sender:)), for: .touchUpInside)
        inputBar.btn_send.addTarget(self, action: #selector(btn_send_clicked(sender:)), for: .touchUpInside)

        let parent = self.tabBarController as! ChannelController
        channel = parent.channel

        service = CoreService.bind()

        adapter = MessageAdapter(self, messageView, (service)!, channel!, parent)
        messageView.transform = CGAffineTransform.init(scaleX: 1, y: -1)
        messageView.register(PendingImageCell.self, forCellReuseIdentifier: "pending_image")
        messageView.register(PendingTextCell.self, forCellReuseIdentifier: "pending_text")
        messageView.register(InImageCell.self, forCellReuseIdentifier: "in_image")
        messageView.register(OutImageCell.self, forCellReuseIdentifier: "out_image")
        messageView.register(InTextCell.self, forCellReuseIdentifier: "in_text")
        messageView.register(OutTextCell.self, forCellReuseIdentifier: "out_text")
        messageView.allowsSelection = false
        messageView.estimatedRowHeight = 100.0
        messageView.rowHeight = UITableViewAutomaticDimension
        messageView.separatorStyle = .none
        messageView.dataSource = adapter
        messageView.delegate = adapter

        messageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(messageView)
        messageView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        messageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        messageView.bottomAnchor.constraint(equalTo: inputBar.topAnchor).isActive = true

        unread.translatesAutoresizingMaskIntoConstraints = false
        unread.isEditable = false
        unread.isScrollEnabled = false
        unread.backgroundColor = UIColor(red:0.00, green:0.00, blue:0.50, alpha:1.0)
        unread.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        unread.font = UIFont.systemFont(ofSize: 17)
        unread.textColor = .white
        unread.layer.masksToBounds = true
        unread.layer.cornerRadius = 10
        unread.text = "unread".localized

        self.view.addSubview(unread)
        unread.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -15).isActive = true
        unread.centerXAnchor.constraint(equalTo: messageView.centerXAnchor).isActive = true
        self.view.bringSubview(toFront: unread)
        unread.isHidden = true

        let unreadTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(unread_clicked))
        unreadTap.cancelsTouchesInView = false
        unread.addGestureRecognizer(unreadTap)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        super.viewDidLoad()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        isTyping = true
        updateUI()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        isTyping = false
        updateUI()
    }

    @objc func unread_clicked(sender: Any) {
        if(self.adapter!.messageList.message.count > 0){
            let indexPath = IndexPath(row: 0, section: 0)
            self.messageView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        self.unread.isHidden = true
    }

    @objc func btn_camera_clicked(sender: Any) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != AVAuthorizationStatus.authorized {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    self.takePhoto()
                }
            }
        } else {
            takePhoto()
        }
    }

    func takePhoto() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.camera
        self.present(pickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let folder = path.appendingPathComponent("temp")
            do {
                try FileManager.default.createDirectory(atPath: folder.path, withIntermediateDirectories: false, attributes: nil)
            } catch {
                // noop
            }
            let uid = UUID().uuidString
            let file = "temp/\(uid).jpg"
            let newPath = path.appendingPathComponent(file)
            let jpgImageData = UIImageJPEGRepresentation(image, 1.0)
            do {
                try jpgImageData!.write(to: newPath)
                service!.sendImage(channel!.id!, file)
            } catch {
                print(error)
            }
        }
        dismiss(animated:true, completion: nil)
    }

    @objc func btn_send_clicked(sender: Any) {
        let text = inputBar.text.text!.trim()
        if text.count > 0 {
            service!.sendMessage(channel!.id!, inputBar.text.text!, pinLocation)
            inputBar.text.text = nil
            pinLocation = nil
            updateUI()
        }
    }

    func onCallback() {
        adapter?.reload()
    }

    func updateUI() {
        inputBar.pin.isHidden = pinLocation==nil
        if isTyping || (pinLocation != nil) {
            inputBar.btn_picker.isHidden = true
            inputBar.btn_camera.isHidden = true
        } else {
            inputBar.btn_picker.isHidden = false
            inputBar.btn_camera.isHidden = !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)

        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cbkey = service!.addMessageListener(channel!, cbkey, self)

        let parent = self.tabBarController as! ChannelController
        pinLocation = parent.pendingPinLocation
        parent.pendingPinLocation = nil

        updateUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let sv = service {
            sv.removeMessageListener(channel!, cbkey)
            cbkey = nil
        }

        super.viewWillDisappear(animated)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func keyboardShown(_ n:NSNotification) {
        let d = n.userInfo!
        let r = (d[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.bottomConstraint!.constant = -(r.size.height - self.tabBarController!.tabBar.frame.size.height)
        self.view.layoutIfNeeded()
    }

    @objc func keyboardHide(_ n:NSNotification) {
        self.bottomConstraint!.constant = 0
        self.view.layoutIfNeeded()
    }
}
