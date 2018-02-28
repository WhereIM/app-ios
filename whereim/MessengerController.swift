//
//  MessengerController.swift
//  whereim
//
//  Created by Buganini Q on 07/03/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class InputBar: UIStackView {
    let background = UIView()
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
        self.alignment = .bottom
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

class InTextCell: UITableViewCell {
    let sender = UILabel()
    let message = UITextView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        sender.translatesAutoresizingMaskIntoConstraints = false
        sender.font = UIFont.systemFont(ofSize: 12)
        sender.textColor = .gray
        self.contentView.addSubview(sender)

        message.translatesAutoresizingMaskIntoConstraints = false
        message.backgroundColor = UIColor(red:0.89, green:0.91, blue:0.92, alpha:1.0)
        message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        message.font = UIFont.systemFont(ofSize: 17)
        message.isEditable = false
        message.textContainer.lineBreakMode = .byWordWrapping
        message.isScrollEnabled = false
        message.layer.masksToBounds = true
        message.layer.cornerRadius = 10

        self.contentView.addSubview(message)

        sender.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        sender.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -100).isActive = true
        sender.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true

        message.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        message.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -100).isActive = true
        message.topAnchor.constraint(equalTo: sender.bottomAnchor, constant: 2).isActive = true
        message.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setMessage(_ message: Message) {
        self.sender.text = message.getSender()
        self.message.text = message.getText()
//        self.message.layoutIfNeeded()
    }
}

class OutTextCell: UITableViewCell {
    let message = UITextView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        message.translatesAutoresizingMaskIntoConstraints = false
        message.backgroundColor = UIColor(red:0.73, green:0.95, blue:0.56, alpha:1.0)
        message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        message.font = UIFont.systemFont(ofSize: 17)
        message.isEditable = false
        message.textContainer.lineBreakMode = .byWordWrapping
        message.isScrollEnabled = false
        message.layer.masksToBounds = true
        message.layer.cornerRadius = 10

        self.contentView.addSubview(message)

        message.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 100).isActive = true
        message.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        message.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        message.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setMessage(_ message: Message) {
        self.message.text = message.getText()
        self.message.layoutIfNeeded()
    }
}

class MessageAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    let vc: MessengerController
    let service: CoreService
    let channel: Channel
    let channelController: ChannelController
    var messageList: BundledMessages

    init(_ viewController: MessengerController, _ service: CoreService, _ channel: Channel, _ channelController: ChannelController) {
        self.vc = viewController
        self.service = service
        self.channel = channel
        self.channelController = channelController
        self.messageList = service.getMessages(channel.id!)
        self.service.set(channel_id: channel.id!, unread: false)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageList.message.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messageList.message[indexPath.row]
        if (message.mate_id == channel.mate_id) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "out_text", for: indexPath) as! OutTextCell
            cell.setMessage(message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "in_text", for: indexPath) as! InTextCell
            cell.setMessage(message)
            return cell
        }
    }

    func reload() {
        self.messageList = service.getMessages(channel.id!)
        self.service.set(channel_id: channel.id!, unread: false)
    }
}

class MessengerController: UIViewController, Callback {
    let inputBar = InputBar()
    let messageView = UITableView()

    var messageList: BundledMessages?
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

        inputBar.btn_send.addTarget(self, action: #selector(btn_send_clicked(sender:)), for: .touchUpInside)

        let parent = self.tabBarController as! ChannelController
        channel = parent.channel

        service = CoreService.bind()

        adapter = MessageAdapter(self, (service)!, channel!, parent)
        messageView.register(InTextCell.self, forCellReuseIdentifier: "in_text")
        messageView.register(OutTextCell.self, forCellReuseIdentifier: "out_text")
        messageView.allowsSelection = false
        messageView.estimatedRowHeight = 1000000.0
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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        super.viewDidLoad()
    }

    @objc func btn_send_clicked(sender: Any) {
        service!.sendMessage(channel!.id!, inputBar.text.text!)
    }

    func onCallback() {
        adapter?.reload()
        messageView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cbkey = service!.addMessageListener(channel!, cbkey, self)
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
        print(r.size.height)
        self.bottomConstraint!.constant = -(r.size.height - self.tabBarController!.tabBar.frame.size.height)
        self.view.layoutIfNeeded()
    }

    @objc func keyboardHide(_ n:NSNotification) {
        self.bottomConstraint!.constant = 0
        self.view.layoutIfNeeded()
    }
}
