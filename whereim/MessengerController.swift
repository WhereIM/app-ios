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
    let date = UILabel()
    let sender = UILabel()
    let message = UITextView()
    let time = UILabel()
    var dateHeight: NSLayoutConstraint

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
        message.font = UIFont.systemFont(ofSize: 17)
        message.isEditable = false
        message.textContainer.lineBreakMode = .byWordWrapping
        message.isScrollEnabled = false
        message.layer.masksToBounds = true
        message.layer.cornerRadius = 10
        self.contentView.addSubview(message)

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
        message.topAnchor.constraint(equalTo: sender.bottomAnchor, constant: 2).isActive = true
        message.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true

        time.leadingAnchor.constraint(equalTo: message.trailingAnchor, constant: 5).isActive = true
        time.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -80).isActive = true
        time.bottomAnchor.constraint(equalTo: message.bottomAnchor).isActive = true
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
        message.font = UIFont.systemFont(ofSize: 17)
        message.isEditable = false
        message.textContainer.lineBreakMode = .byWordWrapping
        message.isScrollEnabled = false
        message.layer.masksToBounds = true
        message.layer.cornerRadius = 10

        self.contentView.addSubview(message)

        time.translatesAutoresizingMaskIntoConstraints = false
        time.font = UIFont.systemFont(ofSize: 10)
        time.textColor = .lightGray
        time.adjustsFontSizeToFitWidth = false
        self.contentView.addSubview(time)

        date.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        date.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        date.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true

        time.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor, constant: 80).isActive = true
        time.bottomAnchor.constraint(equalTo: message.bottomAnchor).isActive = true

        message.leadingAnchor.constraint(equalTo: time.trailingAnchor, constant: 5).isActive = true
        message.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        message.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 5).isActive = true
        message.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        dateFormatter.dateFormat = "yyyy-MM-dd"
        lymdFormatter.dateStyle = .medium
        lymdFormatter.timeStyle = .none
        eeeFormatter.dateFormat = "EEE"
        timeFormatter.dateFormat = "hh:mm"
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
        let time = Date(timeIntervalSince1970: TimeInterval(message.time!))

        var showDate = false

        if indexPath.row == self.messageList.message.count - 1 {
            showDate = true
        } else {
            let prev = self.messageList.message[indexPath.row + 1]
            if dateFormatter.string(from: time) != dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(prev.time!))) {
                showDate = true
            }
        }

        let lymd = lymdFormatter.string(from: time)
        let eee = eeeFormatter.string(from: time)
        let dateString = String(format: "date_format".localized, eee, lymd)
        let timeString = timeFormatter.string(from: time)

        if (message.mate_id == channel.mate_id) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "out_text", for: indexPath) as! OutTextCell
            cell.message.text = message.getText()
            cell.date.text = dateString
            cell.dateHeight.isActive = !showDate
            cell.time.text = timeString
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "in_text", for: indexPath) as! InTextCell
            cell.sender.text = message.getSender()
            cell.message.text = message.getText()
            cell.date.text = dateString
            cell.dateHeight.isActive = !showDate
            cell.time.text = timeString
            return cell
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
    }

    func reload() {
        let prevLastId = self.messageList.lastId
        let viewEnd = self.viewEnd
        var rowOffset = CGFloat.init(0)
        var anchorRowId = Int64(0)
        if let firstIndex = self.tableView.indexPathsForVisibleRows?[0] {
            anchorRowId = self.messageList.message[firstIndex.row].id!
            rowOffset = self.tableView.contentOffset.y - self.tableView.rectForRow(at: firstIndex).origin.y
        }

        self.messageList = service.getMessages(channel.id!)
        self.service.set(channel_id: channel.id!, unread: false)
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        if let row = self.messageList.rowMap[anchorRowId] {
            let rowY = self.tableView.rectForRow(at: IndexPath.init(row: row, section: 0)).origin.y
            self.tableView.contentOffset = CGPoint.init(x: 0, y: rowY + rowOffset)
        }
        DispatchQueue.main.async {
            if (viewEnd) {
                if(self.messageList.message.count > 0){
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

class MessengerController: UIViewController, Callback {
    let inputBar = InputBar()
    let unread = UITextView()
    let messageView = UITableView()

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

        adapter = MessageAdapter(self, messageView, (service)!, channel!, parent)
        messageView.transform = CGAffineTransform.init(scaleX: 1, y: -1)
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

        messageView.reloadData()

        super.viewDidLoad()
    }

    @objc func unread_clicked(sender: Any) {
        if(self.adapter!.messageList.message.count > 0){
            let indexPath = IndexPath(row: 0, section: 0)
            self.messageView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        self.unread.isHidden = true
    }

    @objc func btn_send_clicked(sender: Any) {
        service!.sendMessage(channel!.id!, inputBar.text.text!)
    }

    func onCallback() {
        adapter?.reload()
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
