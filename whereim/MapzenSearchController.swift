//
//  MapzenSearchController.swift
//  whereim
//
//  Created by Buganini Q on 15/12/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import Alamofire
import CoreLocation

class MapzenSearchResultsCell: UITableViewCell {
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
        layout.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        layout.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        layout.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        layout.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class MapzenSearchResultsDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapzen_result", for: indexPath) as! MapzenSearchResultsCell
        cell.name.text = result.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchController.moveToSearchResult(at: indexPath.row)
    }
}

class MapzenSearchAgent: ApiKeyCallback {
    let mapzenSearchController: MapzenSearchController
    var keyword: String?
    
    init(_ mapzenSearchController: MapzenSearchController) {
        self.mapzenSearchController = mapzenSearchController
    }
    
    func apiKey(_ key: String) {
        guard let center = mapzenSearchController.searchController?.getMapCenter() else {
            return
        }
        let params = [
            "api_key": key,
            "size": "50",
            "text": self.keyword!,
            "lang": "google_lang".localized,
            "focus.point.lat": String(format: "%f", center.latitude),
            "focus.point.lon": String(format: "%f", center.longitude)
        ]
        DispatchQueue.global(qos: .background).async {
            Alamofire.request("https://search.mapzen.com/v1/search/", method: .get, parameters: params, encoding: URLEncoding.queryString, headers: ["Referer":"where.im"]).responseJSON{ response in
                guard let result = response.result.value else {
                    return
                }
                guard let data = result as? [String:Any] else {
                    return
                }
                guard let features = data["features"] as? [[String:Any]] else {
                    return
                }
                var res = [POI]()
                for feature in features {
                    guard let geometry = feature["geometry"] as? [String:Any] else {
                        continue
                    }
                    guard let coordinates = geometry["coordinates"] as? [Double] else {
                        continue
                    }
                    guard let properties = feature["properties"] as? [String:Any] else {
                        continue
                    }
                    guard let name = properties["label"] as? String else {
                        continue
                    }
                    let poi = POI()
                    poi.name = name
                    poi.location = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
                    res.append(poi)
                }
                self.mapzenSearchController.searchController?.setSearchResults(res)
            }
        }
    }
}

class MapzenAutoCompletesCell: UITableViewCell {
    let prediction = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        prediction.translatesAutoresizingMaskIntoConstraints = false
        prediction.adjustsFontSizeToFitWidth = false
        
        self.contentView.addSubview(prediction)
        prediction.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        prediction.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        prediction.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        prediction.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class MapzenAutoCompletesDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapzen_autocomplete", for: indexPath) as! MapzenAutoCompletesCell
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

class MapzenAutoCompleteAgent: ApiKeyCallback {
    let mapzenSearchController: MapzenSearchController
    var keyword: String?
    
    init(_ mapzenSearchController: MapzenSearchController) {
        self.mapzenSearchController = mapzenSearchController
    }
    
    func apiKey(_ key: String) {
        guard let center = mapzenSearchController.searchController?.getMapCenter() else {
            return
        }
        let params = [
            "api_key": key,
            "size": "50",
            "text": self.keyword!,
            "lang": "google_lang".localized,
            "focus.point.lat": String(format: "%f", center.latitude),
            "focus.point.lon": String(format: "%f", center.longitude)
        ]
        DispatchQueue.global(qos: .background).async {
            Alamofire.request("https://search.mapzen.com/v1/autocomplete/", method: .get, parameters: params, encoding: URLEncoding.queryString, headers: ["Referer":"where.im"]).responseJSON{ response in
                guard let result = response.result.value else {
                    return
                }
                guard let data = result as? [String:Any] else {
                    return
                }
                guard let features = data["features"] as? [[String:Any]] else {
                    return
                }
                var res = [String]()
                for feature in features {
                    guard let properties = feature["properties"] as? [String:Any] else {
                        continue
                    }
                    if let name = properties["label"] as? String {
                        res.append(name)
                    }
                }
                self.mapzenSearchController.searchController?.setAutoCompletes(res)
            }
        }
    }
}

class MapzenSearchController: SearchControllerInterface {
    weak var searchController: SearchController?
    let service = CoreService.bind()
    let searchDelegate: MapzenSearchResultsDelegate
    let autoCompleteDelegate: MapzenAutoCompletesDelegate
    var searchAgent: MapzenSearchAgent?
    var autoCompleteAgent: MapzenAutoCompleteAgent?
    
    init(_ searchController: SearchController) {
        self.searchController = searchController
        searchDelegate = MapzenSearchResultsDelegate(searchController)
        autoCompleteDelegate = MapzenAutoCompletesDelegate(searchController)
    }
    
    func viewDidLoad() {
        searchAgent = MapzenSearchAgent(self)
        autoCompleteAgent = MapzenAutoCompleteAgent(self)
        searchController?.listView.register(MapzenSearchResultsCell.self, forCellReuseIdentifier: "mapzen_result")
        searchController?.listView.register(MapzenAutoCompletesCell.self, forCellReuseIdentifier: "mapzen_autocomplete")
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
        service.getKey(forApi: Key.MAPZEN, callback: searchAgent!)
    }
    
    func autoComplete(_ keyword: String) {
        autoCompleteAgent!.keyword = keyword
        service.getKey(forApi: Key.MAPZEN, callback: autoCompleteAgent!)
    }
}
