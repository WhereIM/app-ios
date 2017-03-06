//
//  Marker.swift
//  whereim
//
//  Created by Buganini Q on 22/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import Foundation
import UIKit

class MarkerList {
    var public_list = [Marker]()
    var private_list = [Marker]()
}

class Marker {
    var id: String?
    var channel_id: String?
    var name: String?
    var latitude: Double?
    var longitude: Double?
    var attr: [String: Any]?
    var isPublic: Bool?
    var enable: Bool?

    static func getIconList() -> [String] {
        return ["red",
        "orange",
        "yellow",
        "green",
        "cyan",
        "azure",
        "blue",
        "violet",
        "magenta",
        "rose",
        "grey"]
    }

    func getIcon() -> UIImage {
        return Marker.getIcon(attr?[Key.COLOR] as? String)
    }

    static func getIcon(_ color: String?) -> UIImage {
        if color == nil {
            return UIImage(named: "icon_marker_red")!
        }
        switch color! {
        case "azure": return UIImage(named: "icon_marker_azure")!
        case "blue": return UIImage(named: "icon_marker_blue")!
        case "cyan": return UIImage(named: "icon_marker_cyan")!
        case "green": return UIImage(named: "icon_marker_green")!
        case "grey": return UIImage(named: "icon_marker_grey")!
        case "magenta": return UIImage(named: "icon_marker_magenta")!
        case "orange": return UIImage(named: "icon_marker_orange")!
        case "red": return UIImage(named: "icon_marker_red")!
        case "rose": return UIImage(named: "icon_marker_rose")!
        case "violet": return UIImage(named: "icon_marker_violet")!
        case "yellow": return UIImage(named: "icon_marker_yellow")!
        default:
            return UIImage(named: "icon_marker_red")!
        }
    }
}
