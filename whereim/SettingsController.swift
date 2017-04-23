//
//  SettingsController.swift
//  whereim
//
//  Created by Buganini Q on 23/04/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {
    let scrollView = UIScrollView()
    let list = UIStackView()

    let row_power_saving = UIView()
    let label_power_saving = UILabel()
    let switch_power_saving = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.bottomAnchor).isActive = true

        scrollView.addSubview(list)

        list.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        list.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        list.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true

        list.axis = .vertical
        list.alignment = .leading
        list.distribution = .fill

        row_power_saving.addSubview(label_power_saving)
        row_power_saving.addSubview(switch_power_saving)

        label_power_saving.adjustsFontSizeToFitWidth = false
        label_power_saving.text = "power_saving".localized

        label_power_saving.leftAnchor.constraint(equalTo: row_power_saving.leftAnchor).isActive = true
        label_power_saving.centerYAnchor.constraint(equalTo: row_power_saving.centerYAnchor).isActive = true

        switch_power_saving.rightAnchor.constraint(equalTo: row_power_saving.rightAnchor).isActive = true
        switch_power_saving.centerYAnchor.constraint(equalTo: row_power_saving.centerYAnchor).isActive = true
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
