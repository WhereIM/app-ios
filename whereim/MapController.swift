//
//  MapController.swift
//  whereim
//
//  Created by Buganini Q on 20/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class MapController: UIViewController {
    var service: CoreService?
    var channel: Channel?
    var cbkey: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        service = CoreService.bind()
        let parent = self.tabBarController as! ChannelController
        channel = parent.channel
        cbkey = service!.openMap(channel!, cbkey, self as! MapDataReceiver)
    }

    deinit {
        service!.closeMap(channel: channel!, key: cbkey!)
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
