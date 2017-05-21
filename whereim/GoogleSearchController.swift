//
//  GoogleSearchController.swift
//  whereim
//
//  Created by Buganini Q on 29/04/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import Alamofire
import CoreLocation

extension String {
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
        guard let html = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) else { return nil }
        return html
    }
}

class GoogleSearchResultsCell: UITableViewCell {
    let layout = UIStackView()
    let name = UILabel()
    let address = UILabel()
    let attribution = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.axis = .vertical
        layout.alignment = .leading
        layout.distribution = .fill

        name.translatesAutoresizingMaskIntoConstraints = false
        name.adjustsFontSizeToFitWidth = false
        layout.addArrangedSubview(name)

        address.translatesAutoresizingMaskIntoConstraints = false
        address.adjustsFontSizeToFitWidth = false
        address.font = address.font.withSize(12)
        layout.addArrangedSubview(address)

        attribution.translatesAutoresizingMaskIntoConstraints = false
        attribution.adjustsFontSizeToFitWidth = false
        attribution.font = attribution.font.withSize(10)
        layout.addArrangedSubview(attribution)

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

class GoogleSearchResultsDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
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
        let result = searchController.searchResults[indexPath.row] as! GooglePOI
        let cell = tableView.dequeueReusableCell(withIdentifier: "google_result", for: indexPath) as! GoogleSearchResultsCell
        cell.name.text = result.name
        cell.address.text = result.address
        cell.attribution.attributedText = result.attribution
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchController.moveToSearchResult(at: indexPath.row)
    }
}

class GoogleSearchAgent: ApiKeyCallback {
    let googleSearchController: GoogleSearchController
    var keyword: String?

    init(_ googleSearchController: GoogleSearchController) {
        self.googleSearchController = googleSearchController
    }

    func apiKey(_ key: String) {
        guard let center = googleSearchController.searchController?.getMapCenter() else {
            return
        }
        let params = [
            "key": key,
            "query": keyword!,
            "language": "google_lang".localized,
            "location": String(format: "%f,%f", center.latitude, center.longitude),
            "rankby": "distance"
        ]
        DispatchQueue.global(qos: .background).async {
            Alamofire.request("https://maps.googleapis.com/maps/api/place/textsearch/json", method: .get, parameters: params, encoding: URLEncoding.queryString, headers: ["Referer":"where.im"]).responseJSON{ response in
                guard let result = response.result.value else {
                    return
                }
                guard let data = result as? [String:Any] else {
                    return
                }
                guard let status = data["status"] as? String else {
                    return
                }
                switch status {
                case "REQUEST_DENIED":
                    self.googleSearchController.service.invalidateKey(forApi: Key.GOOGLE_SEARCH)
                    self.googleSearchController.service.getKey(forApi: Key.GOOGLE_SEARCH, callback: self)
                case "OVER_QUERY_LIMIT":
                    DispatchQueue.main.async {
                        self.googleSearchController.searchController?.view.makeToast("error".localized)
                    }
                case "ZERO_RESULTS":
                    self.googleSearchController.searchController?.setSearchResults([])
                case "OK":
                    guard let results = data["results"] as? [[String:Any]] else {
                        return
                    }
                    var res = [GooglePOI]()
                    for result in results {
                        guard let name = result["name"] as? String else {
                            continue
                        }
                        guard let geometry = result["geometry"] as? [String:Any] else {
                            continue
                        }
                        guard let location = geometry["location"] as? [String:Any] else {
                            continue
                        }
                        guard let lat = location["lat"] as? Double else {
                            continue
                        }
                        guard let lng = location["lng"] as? Double else {
                            continue
                        }
                        let r = GooglePOI()
                        r.name = name
                        r.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        if let address = result["formatted_address"] as? String {
                            r.address = address
                        }
                        if let attribution = result["attribution"] as? String {
                            r.attribution = attribution.htmlAttributedString()
                        }
                        res.append(r)
                    }
                    self.googleSearchController.searchController?.setSearchResults(res)
                default:
                    return
                }
            }
        }
    }
}

class GoogleAutoCompletesCell: UITableViewCell {
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

class GoogleAutoCompletesDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "google_autocomplete", for: indexPath) as! GoogleAutoCompletesCell
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

class GoogleAutoCompleteAgent: ApiKeyCallback {
    let googleSearchController: GoogleSearchController
    var keyword: String?

    init(_ googleSearchController: GoogleSearchController) {
        self.googleSearchController = googleSearchController
    }

    func apiKey(_ key: String) {
        guard let center = googleSearchController.searchController?.getMapCenter() else {
            return
        }
        let params = [
            "key": key,
            "input": keyword!,
            "language": "google_lang".localized,
            "location": String(format: "%f,%f", center.latitude, center.longitude),
            "radius": "50000"
        ]
        DispatchQueue.global(qos: .background).async {
            Alamofire.request("https://maps.googleapis.com/maps/api/place/queryautocomplete/json", method: .get, parameters: params, encoding: URLEncoding.queryString, headers: ["Referer":"where.im"]).responseJSON{ response in
                guard let result = response.result.value else {
                    return
                }
                guard let data = result as? [String:Any] else {
                    return
                }
                guard let status = data["status"] as? String else {
                    return
                }
                switch status {
                case "REQUEST_DENIED":
                    self.googleSearchController.service.invalidateKey(forApi: Key.GOOGLE_SEARCH)
                    self.googleSearchController.service.getKey(forApi: Key.GOOGLE_SEARCH, callback: self)
                case "OVER_QUERY_LIMIT":
                    DispatchQueue.main.async {
                        self.googleSearchController.searchController?.view.makeToast("error".localized)
                    }
                case "ZERO_RESULTS":
                    self.googleSearchController.searchController?.setAutoCompletes([])
                case "OK":
                    guard let predictions = data["predictions"] as? [[String:Any]] else {
                        return
                    }
                    var res = [String]()
                    for prediction in predictions {
                        guard let description = prediction["description"] as? String else {
                            continue
                        }
                        res.append(description)
                    }
                    self.googleSearchController.searchController?.setAutoCompletes(res)
                default:
                    return
                }
            }
        }
    }
}

class GoogleSearchController: SearchControllerInterface {
    weak var searchController: SearchController?
    let service = CoreService.bind()
    let searchDelegate: GoogleSearchResultsDelegate
    let autoCompleteDelegate: GoogleAutoCompletesDelegate
    var searchAgent: GoogleSearchAgent?
    var autoCompleteAgent: GoogleAutoCompleteAgent?

    init(_ searchController: SearchController) {
        self.searchController = searchController
        searchDelegate = GoogleSearchResultsDelegate(searchController)
        autoCompleteDelegate = GoogleAutoCompletesDelegate(searchController)
    }

    func viewDidLoad() {
        searchAgent = GoogleSearchAgent(self)
        autoCompleteAgent = GoogleAutoCompleteAgent(self)
        searchController?.listView.register(GoogleSearchResultsCell.self, forCellReuseIdentifier: "google_result")
        searchController?.listView.register(GoogleAutoCompletesCell.self, forCellReuseIdentifier: "google_autocomplete")
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
        service.getKey(forApi: Key.GOOGLE_SEARCH, callback: searchAgent!)
    }

    func autoComplete(_ keyword: String) {
        autoCompleteAgent!.keyword = keyword
        service.getKey(forApi: Key.GOOGLE_SEARCH, callback: autoCompleteAgent!)
    }
}
