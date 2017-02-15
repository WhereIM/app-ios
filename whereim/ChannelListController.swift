//
//  ChannelListController.swift
//  whereim
//
//  Created by Buganini Q on 15/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class ChannelListController: UIViewController {
    var service: CoreService?

    override func viewDidLoad() {
        super.viewDidLoad()

        service = CoreService.bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        if service!.getClientId() == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "login")
            self.present(vc!, animated: true)
        }
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
