//
//  MapController.swift
//  whereim
//
//  Created by Buganini Q on 20/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import CoreLocation
import UIKit

protocol MapControllerInterface {
    func setup(_ mapController: MapController)
    func viewDidLoad(_ viewContrller: UIViewController)
    func didReceiveMemoryWarning()
    func refreshEditing()
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
        mapControllerImpl!.setup(self)
    }

    let enchantmentPanel = UICompactStackView()
    let markerPanel = UICompactStackView()
    override func viewDidLoad() {
        super.viewDidLoad()

        service = CoreService.bind()
        let parent = self.tabBarController as! ChannelController
        channel = parent.channel
        cbkey = service!.openMap(channel!, cbkey, mapControllerImpl as! MapDataReceiver)

        mapControllerImpl!.viewDidLoad(self)

        enchantmentPanel.axis = .horizontal
        enchantmentPanel.alignment = .center
        enchantmentPanel.distribution = .fill
        enchantmentPanel.spacing = 15

        do {
            let reduce = UIButton()
            reduce.translatesAutoresizingMaskIntoConstraints = false
            reduce.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            reduce.setTitle("➖", for: .normal)
            reduce.setTitleColor(.black, for: .normal)
            reduce.addTarget(self, action: #selector(enchantment_reduce(sender:)), for: .touchUpInside)
            enchantmentPanel.addArrangedSubview(reduce)

            let enlarge = UIButton()
            enlarge.translatesAutoresizingMaskIntoConstraints = false
            enlarge.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            enlarge.setTitle("➕", for: .normal)
            enlarge.setTitleColor(.black, for: .normal)
            enlarge.addTarget(self, action: #selector(enchantment_enlarge(sender:)), for: .touchUpInside)
            enchantmentPanel.addArrangedSubview(enlarge)

            let cancel = UIButton()
            cancel.translatesAutoresizingMaskIntoConstraints = false
            cancel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            cancel.setTitle("✘", for: .normal)
            cancel.setTitleColor(.black, for: .normal)
            cancel.addTarget(self, action: #selector(enchantment_cancel(sender:)), for: .touchUpInside)
            enchantmentPanel.addArrangedSubview(cancel)

            let ok = UIButton()
            ok.translatesAutoresizingMaskIntoConstraints = false
            ok.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            ok.setTitle("✔", for: .normal)
            ok.setTitleColor(.black, for: .normal)
            ok.addTarget(self, action: #selector(enchantment_ok(sender:)), for: .touchUpInside)
            enchantmentPanel.addArrangedSubview(ok)
        }

        enchantmentPanel.requestLayout()
        enchantmentPanel.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(enchantmentPanel)
        NSLayoutConstraint.activate([enchantmentPanel.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -15), enchantmentPanel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)])
        enchantmentPanel.isHidden = true

        markerPanel.axis = .horizontal
        markerPanel.alignment = .center
        markerPanel.distribution = .fill
        markerPanel.spacing = 15

        do {
            let cancel = UIButton()
            cancel.translatesAutoresizingMaskIntoConstraints = false
            cancel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            cancel.setTitle("✘", for: .normal)
            cancel.setTitleColor(.black, for: .normal)
            cancel.addTarget(self, action: #selector(marker_cancel(sender:)), for: .touchUpInside)
            markerPanel.addArrangedSubview(cancel)

            let ok = UIButton()
            ok.translatesAutoresizingMaskIntoConstraints = false
            ok.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            ok.setTitle("✔", for: .normal)
            ok.setTitleColor(.black, for: .normal)
            ok.addTarget(self, action: #selector(marker_ok(sender:)), for: .touchUpInside)
            markerPanel.addArrangedSubview(ok)
        }

        markerPanel.requestLayout()
        markerPanel.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(markerPanel)
        NSLayoutConstraint.activate([markerPanel.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -15), markerPanel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)])
        markerPanel.isHidden = true
    }

    func enchantment_reduce(sender: UIButton) {
        print("enchantment_reduce")
    }

    func enchantment_enlarge(sender: UIButton) {
        print("enchantment_enlarge")
    }

    func enchantment_cancel(sender: UIButton) {
        print("enchantment_cancel")
    }

    func enchantment_ok(sender: UIButton) {
        print("enchantment_ok")
    }

    func marker_cancel(sender: UIButton) {
        print("marker_cancel")
    }

    func marker_ok(sender: UIButton) {
        print("marker_ok")
    }

    deinit {
        service!.closeMap(channel: channel!, key: cbkey!)
    }

    override func didReceiveMemoryWarning() {
        mapControllerImpl!.didReceiveMemoryWarning()
        super.didReceiveMemoryWarning()
    }

    enum EditingType {
        case marker
        case enchantment
    }

    var editingType: EditingType?
    var editingCoordinate = CLLocationCoordinate2D()
    func startEditing(_ coordinate: CLLocationCoordinate2D) {
        editingCoordinate = coordinate
        if editingType != nil {
            mapControllerImpl!.refreshEditing()
            return
        }

        Dialog.start_editing(self)
    }

    func refreshEditing(_ type: EditingType) {
        editingType = type
        if editingType == nil {
            enchantmentPanel.isHidden = true
            markerPanel.isHidden = true
        } else {
            switch editingType! {
            case .enchantment:
                enchantmentPanel.isHidden = false
                markerPanel.isHidden = true
            case .marker:
                enchantmentPanel.isHidden = true
                markerPanel.isHidden = false
            }
        }
        mapControllerImpl!.refreshEditing()
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
