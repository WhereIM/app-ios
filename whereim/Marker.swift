//
//  Marker.swift
//  whereim
//
//  Created by Buganini Q on 22/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import Foundation
import GRDB
import UIKit

class PickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let icon_list = Marker.getIconList()

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return icon_list.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var cell: UIImageView?
        if let v = view {
            cell = v as? UIImageView
        }
        if cell == nil {
            cell = UIImageView(frame: CGRect(x: 0, y: 0, width: 43, height: 43))
        }
        cell!.image = Marker.getIcon(icon_list[row])
        return cell!
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 43
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 43
    }

    func getItem(_ row: Int) -> String {
        return icon_list[row]
    }
}

class MarkerList {
    var public_list = [Marker]()
    var private_list = [Marker]()
}

class Marker: Record {
    static let TABLE_NAME = "marker"

    static let COL_ID = "_id"
    static let COL_CHANNEL_ID = "channel_id"
    static let COL_NAME = "name"
    static let COL_LATITUDE = "latitude"
    static let COL_LONGITUDE = "longitude"
    static let COL_ATTR = "attr"
    static let COL_PUBLIC = "public"
    static let COL_ENABLED = "enabled"

    var id: String?
    var channel_id: String?
    var name: String?
    var latitude: Double?
    var longitude: Double?
    var attr: [String: Any]?
    var isPublic: Bool?
    var enabled: Bool?
    var deleted = false

    static func migrate(_ db: Database, _ db_version: Int) throws {
        var version = db_version

        if version < 1 {
            var sql: String
            sql = "CREATE TABLE " + TABLE_NAME + " (" +
                COL_ID + " TEXT PRIMARY KEY, " +
                COL_CHANNEL_ID + " TEXT, " +
                COL_NAME + " TEXT, " +
                COL_LATITUDE + " DOUBLE PRECISION, " +
                COL_LONGITUDE + " DOUBLE PRECISION, " +
                COL_ATTR + " TEXT, " +
                COL_PUBLIC + " BOOLEAN, " +
                COL_ENABLED + " BOOLEAN)"
            try db.execute(sql)

            sql = "CREATE INDEX marker_index ON "+TABLE_NAME+" ("+COL_CHANNEL_ID+")"
            try db.execute(sql)

            version = 1
        }
    }

    override class var databaseTableName: String {
        return TABLE_NAME
    }

    required init(row: Row) {
        do {
            id = row.value(named: Marker.COL_ID)
            channel_id = row.value(named: Marker.COL_CHANNEL_ID)
            name = row.value(named: Marker.COL_NAME)
            latitude = row.value(named: Marker.COL_LATITUDE)
            longitude = row.value(named: Marker.COL_LONGITUDE)
            let attr_string = row.value(named: Marker.COL_ATTR) as! String
            attr = try JSONSerialization.jsonObject(with: attr_string.data(using: .utf8)!, options: []) as? [String: Any]
            isPublic = row.value(named: Marker.COL_PUBLIC)
            enabled = row.value(named: Marker.COL_ENABLED)
        } catch {
            print("Error in decoding marker.attr")
        }
        super.init(row: row)
    }

    override init() {
        super.init()
    }

    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        do {
            let json = try JSONSerialization.data(withJSONObject: attr ?? [], options: [])
            return [
                Marker.COL_ID: id,
                Marker.COL_CHANNEL_ID: channel_id,
                Marker.COL_NAME: name,
                Marker.COL_LATITUDE: latitude,
                Marker.COL_LONGITUDE: longitude,
                Marker.COL_ATTR: String(data: json, encoding: .utf8)!,
                Marker.COL_PUBLIC: isPublic,
                Marker.COL_ENABLED: enabled
            ]
        } catch {
            print("Error encoding marker.attr")
            return [:]
        }
    }

    static func getAll() -> [Marker] {
        var ret = [Marker]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try appDelegate.dbConn!.inDatabase { db in
                let markers = try Marker.fetchAll(db, "SELECT * FROM "+TABLE_NAME+" ORDER BY "+COL_NAME+" ASC")

                for m in markers {
                    ret.append(m)
                }
            }
        } catch {
            print("Error checking out markers")
        }
        return ret
    }

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

    func getColor() -> String {
        return attr?[Key.COLOR] as? String ?? "red"
    }

    func getIcon() -> UIImage {
        return Marker.getIcon(getColor())
    }

    static func getIcon(_ color: String) -> UIImage {
        switch color {
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
