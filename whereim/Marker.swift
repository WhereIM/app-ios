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

class Marker: RowConvertible, Persistable {
    static let TABLE_NAME = "marker"

    enum Columns {
        static let id = Column("_id")
        static let channel_id = Column("channel_id")
        static let name = Column("name")
        static let latitude = Column("latitude")
        static let longitude = Column("longitude")
        static let attr = Column("attr")
        static let is_public = Column("public")
        static let enabled = Column("enabled")
    }

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
            sql = """
            CREATE TABLE \(TABLE_NAME) (
                \(Columns.id.name) TEXT PRIMARY KEY,
                \(Columns.channel_id.name) TEXT,
                \(Columns.name.name) TEXT,
                \(Columns.latitude.name) DOUBLE PRECISION,
                \(Columns.longitude.name) DOUBLE PRECISION,
                \(Columns.attr.name) TEXT,
                \(Columns.is_public.name) BOOLEAN,
                \(Columns.enabled.name) BOOLEAN
            )
            """
            try db.execute(sql)

            sql = "CREATE INDEX marker_index ON \(TABLE_NAME) (\(Columns.channel_id.name))"
            try db.execute(sql)

            version = 1
        }
    }

    static let databaseTableName = TABLE_NAME

    init(){
        // noop
    }

    required init(row: Row) {
        do {
            id = row[Columns.id]
            channel_id = row[Columns.channel_id]
            name = row[Columns.name]
            latitude = row[Columns.latitude]
            longitude = row[Columns.longitude]
            let attr_string = row[Columns.attr] as! String
            attr = try JSONSerialization.jsonObject(with: attr_string.data(using: .utf8)!, options: []) as? [String: Any]
            isPublic = row[Columns.is_public]
            enabled = row[Columns.enabled]
        } catch {
            print("Error in decoding marker.attr")
        }
    }

    func encode(to container: inout PersistenceContainer) {
        do {
            let json = try JSONSerialization.data(withJSONObject: attr ?? [], options: [])
            container[Columns.id] = id
            container[Columns.channel_id] = channel_id
            container[Columns.name] = name
            container[Columns.latitude] = latitude
            container[Columns.longitude] = longitude
            container[Columns.attr] = String(data: json, encoding: .utf8)!
            container[Columns.is_public] = isPublic
            container[Columns.enabled] = enabled
        } catch {
            print("Error encoding marker.attr")
        }
    }

    static func getAll() -> [Marker] {
        var ret = [Marker]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        do {
            try CoreService.bind().dbConn!.inDatabase { db in
                let markers = try Marker.fetchAll(db, "SELECT * FROM \(TABLE_NAME) ORDER BY \(Columns.name.name) ASC")

                for m in markers {
                    ret.append(m)
                }
            }
        } catch {
            print("Error checking out markers \(error)")
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
