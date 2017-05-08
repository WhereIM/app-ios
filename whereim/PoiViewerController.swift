//
//  LocationViewerController.swift
//  whereim
//
//  Created by Buganini Q on 07/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import CoreLocation
import UIKit

protocol PoiViewerControllerInterface {
    init(_ viewController: PoiViewerController)
    func viewDidLoad(_ viewContrller: PoiViewerController)
    func viewWillAppear(_ viewContrller: PoiViewerController)
    func viewWillDisappear(_ viewContrller: PoiViewerController)
    func didReceiveMemoryWarning()
}

class PoiViewerController: UIViewController {
    var service: CoreService?
    var poiViewerControllerImpl: PoiViewerControllerInterface?
    var poi: POI?
    let contentArea = UIView()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        _init()
    }

    func _init() {
        poiViewerControllerImpl = GooglePoiViewerController(self)
    }

    override func viewDidLoad() {
        service = CoreService.bind()

        let close = UIButton(type: UIButtonType.system)
        close.translatesAutoresizingMaskIntoConstraints = false
        close.setTitle("close".localized, for: .normal)
        close.addTarget(self, action: #selector(close(sender:)), for: .touchUpInside)
        self.view.addSubview(close)

        close.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 8).isActive = true
        close.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -8).isActive = true
        close.heightAnchor.constraint(equalToConstant: close.intrinsicContentSize.height).isActive = true

        let open_in = UIButton(type: UIButtonType.system)
        open_in.translatesAutoresizingMaskIntoConstraints = false
        open_in.setTitle("open_in_channel".localized, for: .normal)
        open_in.addTarget(self, action: #selector(open_in_channel(sender:)), for: .touchUpInside)
        self.view.addSubview(open_in)

        open_in.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -8).isActive = true
        open_in.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -8).isActive = true
        open_in.heightAnchor.constraint(equalToConstant: open_in.intrinsicContentSize.height).isActive = true

        contentArea.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(contentArea)

        contentArea.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        contentArea.bottomAnchor.constraint(equalTo: close.topAnchor, constant: -8).isActive = true
        contentArea.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        contentArea.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true


        poiViewerControllerImpl!.viewDidLoad(self)

        super.viewDidLoad()
    }

    func close(sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let startupVC = sb.instantiateViewController(withIdentifier: "startup") as! UINavigationController
        UIApplication.shared.delegate!.window!!.rootViewController = startupVC;
    }

    func open_in_channel(sender: Any) {
        var title: String?
        if let t = poi?.name {
            title = "/\(t)"
        } else {
            title = ""
        }
        service!.processLink(String(format: "open_in_channel/here/%f/%f%@", poi!.location!.latitude, poi!.location!.longitude, title!))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        poiViewerControllerImpl!.viewWillAppear(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        poiViewerControllerImpl!.viewWillDisappear(self)

        super.viewWillDisappear(animated)
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
