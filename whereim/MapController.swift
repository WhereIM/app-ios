//
//  MapController.swift
//  whereim
//
//  Created by Buganini Q on 20/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

protocol MapControllerInterface {
    func initmarkerTamplate()
    func viewDidLoad(_ viewContrller: UIViewController)
    func didReceiveMemoryWarning()
}

class MapController: UIViewController {
    var service: CoreService?
    var channel: Channel?
    var cbkey: Int?
    var mapControllerImpl: MapControllerInterface?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        _init()
    }

    func _init() {
        mapControllerImpl = GoogleMapController()
        mapControllerImpl!.initmarkerTamplate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        service = CoreService.bind()
        let parent = self.tabBarController as! ChannelController
        channel = parent.channel
        cbkey = service!.openMap(channel!, cbkey, mapControllerImpl as! MapDataReceiver)

        mapControllerImpl!.viewDidLoad(self)
    }

    deinit {
        service!.closeMap(channel: channel!, key: cbkey!)
    }

    override func didReceiveMemoryWarning() {
        mapControllerImpl!.didReceiveMemoryWarning()
        super.didReceiveMemoryWarning()
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
