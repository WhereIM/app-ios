//
//  MapboxSearchController.swift
//  whereim
//
//  Created by Buganini Q on 06/06/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import Alamofire
import CoreLocation

class MapboxSearchResultsCell: UITableViewCell {
    let layout = UIStackView()
    let name = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.axis = .vertical
        layout.alignment = .leading
        layout.distribution = .fill

        name.translatesAutoresizingMaskIntoConstraints = false
        name.adjustsFontSizeToFitWidth = false
        layout.addArrangedSubview(name)

        self.contentView.addSubview(layout)
        layout.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        layout.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        layout.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        layout.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class MapboxSearchResultsDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    unowned let searchController: SearchController

    init(_ searchController: SearchController) {
        self.searchController = searchController
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = searchController.searchResults[indexPath.row] 
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapbox_result", for: indexPath) as! MapboxSearchResultsCell
        cell.name.text = result.name

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchController.moveToSearchResult(at: indexPath.row)
    }
}

class MapboxSearchAgent: ApiKeyCallback {
    let mapboxSearchController: MapboxSearchController
    var keyword: String?

    init(_ mapboxSearchController: MapboxSearchController) {
        self.mapboxSearchController = mapboxSearchController
    }

    func apiKey(_ key: String) {
        guard let center = mapboxSearchController.searchController?.getMapCenter() else {
            return
        }
        let params = [
            "access_token": key,
            "proximity": String(format: "%f,%f", center.longitude, center.latitude),
            ]
        DispatchQueue.global(qos: .background).async {
            Alamofire.request("https://api.mapbox.com/geocoding/v5/mapbox.places/"+self.keyword!.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!+".json", method: .get, parameters: params, encoding: URLEncoding.queryString, headers: ["Referer":"where.im"]).responseJSON{ response in
                guard let result = response.result.value else {
                    return
                }
                guard let data = result as? [String:Any] else {
                    return
                }
                guard let attribution = data["attribution"] as? String else {
                    return
                }
                guard let features = data["features"] as? [[String:Any]] else {
                    return
                }
                var res = [POI]()
                for feature in features {
                    guard let name = feature["place_name"] as? String else {
                        continue
                    }
                    guard let center = feature["center"] as? [Double] else {
                        continue
                    }
                    let poi = POI()
                    poi.name = name
                    poi.location = CLLocationCoordinate2D(latitude: center[1], longitude: center[0])
                    res.append(poi)
                }
                self.mapboxSearchController.searchController?.setTextAttribution(attribution)
                self.mapboxSearchController.searchController?.setSearchResults(res)
            }
        }
    }
}

class MapboxAutoCompletesCell: UITableViewCell {
    let prediction = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        prediction.translatesAutoresizingMaskIntoConstraints = false
        prediction.adjustsFontSizeToFitWidth = false

        self.contentView.addSubview(prediction)
        prediction.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        prediction.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        prediction.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        prediction.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class MapboxAutoCompletesDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    unowned let searchController: SearchController

    init(_ searchController: SearchController) {
        self.searchController = searchController
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.autoCompeltes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let prediction = searchController.autoCompeltes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapbox_autocomplete", for: indexPath) as! MapboxAutoCompletesCell
        cell.prediction.text = prediction

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let prediction = searchController.autoCompeltes[indexPath.row]
        searchController.keyword.text = prediction
        searchController.search(prediction)
    }
}

class MapboxAutoCompleteAgent: ApiKeyCallback {
    let mapboxSearchController: MapboxSearchController
    var keyword: String?

    init(_ mapboxSearchController: MapboxSearchController) {
        self.mapboxSearchController = mapboxSearchController
    }

    func apiKey(_ key: String) {
        guard let center = mapboxSearchController.searchController?.getMapCenter() else {
            return
        }
        let params = [
            "access_token": key,
            "autocomplete": "true",
            "proximity": String(format: "%f,%f", center.longitude, center.latitude),
        ]
        DispatchQueue.global(qos: .background).async {
            Alamofire.request("https://api.mapbox.com/geocoding/v5/mapbox.places/"+self.keyword!.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!+".json", method: .get, parameters: params, encoding: URLEncoding.queryString, headers: ["Referer":"where.im"]).responseJSON{ response in
                guard let result = response.result.value else {
                    return
                }
                guard let data = result as? [String:Any] else {
                    return
                }
                guard let attribution = data["attribution"] as? String else {
                    return
                }
                guard let features = data["features"] as? [[String:Any]] else {
                    return
                }
                var res = [String]()
                for feature in features {
                    if let name = feature["place_name"] as? String {
                        res.append(name)
                    }
                }
                self.mapboxSearchController.searchController?.setTextAttribution(attribution)
                self.mapboxSearchController.searchController?.setAutoCompletes(res)
            }
        }
    }
}

class MapboxSearchController: SearchControllerInterface {
    weak var searchController: SearchController?
    let service = CoreService.bind()
    let searchDelegate: MapboxSearchResultsDelegate
    let autoCompleteDelegate: MapboxAutoCompletesDelegate
    var searchAgent: MapboxSearchAgent?
    var autoCompleteAgent: MapboxAutoCompleteAgent?

    init(_ searchController: SearchController) {
        self.searchController = searchController
        searchDelegate = MapboxSearchResultsDelegate(searchController)
        autoCompleteDelegate = MapboxAutoCompletesDelegate(searchController)
    }

    func viewDidLoad() {
        searchAgent = MapboxSearchAgent(self)
        autoCompleteAgent = MapboxAutoCompleteAgent(self)
        searchController?.listView.register(MapboxSearchResultsCell.self, forCellReuseIdentifier: "mapbox_result")
        searchController?.listView.register(MapboxAutoCompletesCell.self, forCellReuseIdentifier: "mapbox_autocomplete")
    }

    func getSearchResultsDelegate() -> UITableViewDelegate {
        return searchDelegate
    }

    func getSearchResultsDataSource() -> UITableViewDataSource {
        return searchDelegate
    }

    func getAutoCompletesDelegate() -> UITableViewDelegate {
        return autoCompleteDelegate
    }

    func getAutoCompletesDataSource() -> UITableViewDataSource {
        return autoCompleteDelegate
    }

    func search(_ keyword: String) {
        searchAgent!.keyword = keyword
        searchAgent!.apiKey(Config.MAPBOX_KEY)
    }

    func autoComplete(_ keyword: String) {
        autoCompleteAgent!.keyword = keyword
        autoCompleteAgent!.apiKey(Config.MAPBOX_KEY)
    }
}
