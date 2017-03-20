//
//  LogController.swift
//  whereim
//
//  Created by Buganini Q on 13/03/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {
    let layout = UICompactStackView()
    let message = UILabel()
    let time = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        layout.axis = .vertical
        layout.alignment = .leading
        layout.distribution = .fill

        time.adjustsFontSizeToFitWidth = false
        time.translatesAutoresizingMaskIntoConstraints = false
        time.font = time.font.withSize(8)
        layout.addArrangedSubview(time)

        message.adjustsFontSizeToFitWidth = false
        message.translatesAutoresizingMaskIntoConstraints = false
        message.font = message.font.withSize(9)
        layout.addArrangedSubview(message)

        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.requestLayout()

        self.contentView.addSubview(layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LogController: UITableViewController {

    var logs = [Log]()
    let formatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearLogs))

        self.tableView!.register(LogCell.self, forCellReuseIdentifier: "log")
        self.tableView!.allowsSelection = false

        logs = Log.getAll()
    }

    func clearLogs() {
        Log.clear()
        logs = Log.getAll()
        self.tableView!.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "log", for: indexPath) as! LogCell

        let log = logs[indexPath.row]

        cell.message.text = log.message
        cell.time.text = formatter.string(from: log.time)

        return cell
    }

}
