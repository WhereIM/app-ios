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

class GoogleSearchResult: SearchResult {
    var address: String?
    var attribution: NSAttributedString?
}

class GoogleSearchResultsListCell: UITableViewCell {
    let layout = UICompactStackView()
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

        layout.requestLayout()

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

class SearchResultsListDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
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
        let result = searchController.searchResults[indexPath.row] as! GoogleSearchResult
        let cell = tableView.dequeueReusableCell(withIdentifier: "google_result", for: indexPath) as! GoogleSearchResultsListCell
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

class GoogleSearchController: SearchControllerInterface, ApiKeyCallback {
    unowned let searchController: SearchController
    let service = CoreService.bind()
    let delegate: SearchResultsListDelegate

    init(_ searchController: SearchController) {
        self.searchController = searchController
        self.delegate = SearchResultsListDelegate(searchController)
    }

    func viewDidLoad() {
        searchController.listView.register(GoogleSearchResultsListCell.self, forCellReuseIdentifier: "google_result")
    }

    func viewWillAppear() {

    }

    func viewWillDisappear() {

    }

    func getSearchResultListDelegate() -> UITableViewDelegate {
        return delegate
    }

    func getSearchResultListDataSource() -> UITableViewDataSource {
        return delegate
    }

    var query: String?
    func search(_ keyword: String) {
        query = keyword
        service.getKey(forApi: Key.GOOGLE_SEARCH, callback: self)
    }

    func apiKey(_ key: String) {
        let center = searchController.getMapCenter()
        let params = [
            "key": key,
            "query": query!,
            "location": String(format: "%f,%f", center.latitude, center.longitude),
            "rankby": "distance"
        ]
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
                self.service.invalidateKey(forApi: Key.GOOGLE_SEARCH)
                self.service.getKey(forApi: Key.GOOGLE_SEARCH, callback: self)
            case "OVER_QUERY_LIMIT":
                DispatchQueue.main.async {
                    self.searchController.view.makeToast("error".localized)
                }
            case "ZERO_RESULTS":
                self.searchController.setSearchResults([])
            case "OK":
                guard let results = data["results"] as? [[String:Any]] else {
                    return
                }
                var res = [GoogleSearchResult]()
                for result in results {
                    print(result)
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
                    let r = GoogleSearchResult()
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
                self.searchController.setSearchResults(res)
            default:
                return
            }
        }
    }

}
