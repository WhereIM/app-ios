//
//  MessengerController.swift
//  whereim
//
//  Created by Buganini Q on 07/03/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class ChannelMessageCell: UITableViewCell {
    let sender = UILabel()
    let time = UILabel()
    let message = UITextView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        sender.font = sender.font.withSize(12)
        sender.adjustsFontSizeToFitWidth = false
        sender.translatesAutoresizingMaskIntoConstraints = false

        time.font = time.font.withSize(10)
        time.adjustsFontSizeToFitWidth = false
        time.translatesAutoresizingMaskIntoConstraints = false

        message.translatesAutoresizingMaskIntoConstraints = false
        message.isScrollEnabled = false

        self.contentView.addSubview(sender)
        self.contentView.addSubview(time)
        self.contentView.addSubview(message)

        NSLayoutConstraint.activate([
            sender.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant:10),
            sender.topAnchor.constraint(equalTo: self.contentView.topAnchor)
            ])
        NSLayoutConstraint.activate([
            time.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant:-10),
            time.topAnchor.constraint(equalTo: self.contentView.topAnchor)
            ])
        NSLayoutConstraint.activate([
            message.topAnchor.constraint(equalTo: sender.bottomAnchor, constant:10),
            message.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant:10),
            message.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            self.contentView.bottomAnchor.constraint(equalTo: message.bottomAnchor, constant: 10)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ChannelMessageAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    var messageList: BundledMessages
    let service: CoreService
    let channel: Channel
    let numberOfSections = 2

    init(_ service: CoreService, _ channel: Channel) {
        self.service = service
        self.channel = channel
        self.messageList = service.getMessages(channel.id!)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.message.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath) as! ChannelMessageCell

        let m = messageList.message[indexPath.row]

        let mate = service.getChannelMate(channel.id!, m.mate_id!)

        cell.sender.text = mate.getDisplayName()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        cell.time.text = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(m.time!)))

        cell.message.text = "\(m.type!): \(m.message!)"
        let size = cell.sizeThatFits(CGSize(width: cell.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        cell.message.heightAnchor.constraint(equalToConstant: size.height)

        return cell
    }

    func reload() {
        self.messageList = service.getMessages(channel.id!)
    }
}

class MessengerController: UIViewController {
    var service: CoreService?
    var channel: Channel?
    var adapter: ChannelMessageAdapter?
    var cbkey: Int?

    @IBOutlet weak var messageListView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let parent = self.tabBarController as! ChannelController
        channel = parent.channel

        service = CoreService.bind()
        adapter = ChannelMessageAdapter((service)!, channel!)
        messageListView.allowsSelection = false
        messageListView.register(ChannelMessageCell.self, forCellReuseIdentifier: "message")
        messageListView.dataSource = adapter
        messageListView.delegate = adapter
        messageListView.estimatedRowHeight = 50 // any value not 0
        messageListView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
