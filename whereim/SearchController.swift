//
//  SearchController.swift
//  whereim
//
//  Created by Buganini Q on 29/04/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import CoreLocation
import GoogleMobileAds
import UIKit

protocol SearchControllerInterface {
    func viewDidLoad()
    func getSearchResultsDataSource() -> UITableViewDataSource
    func getSearchResultsDelegate() -> UITableViewDelegate
    func search(_ keyword: String)
    func getAutoCompletesDataSource() -> UITableViewDataSource
    func getAutoCompletesDelegate() -> UITableViewDelegate
    func autoComplete(_ keyword: String)
}

class SearchHistoryCell: UITableViewCell {
    let keyword = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        keyword.translatesAutoresizingMaskIntoConstraints = false
        keyword.adjustsFontSizeToFitWidth = false

        self.contentView.addSubview(keyword)
        keyword.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        keyword.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        keyword.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        keyword.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class SearchHistoryDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    unowned let searchController: SearchController

    init(_ searchController: SearchController) {
        self.searchController = searchController
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.history.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let keyword = searchController.history[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "search_history", for: indexPath) as! SearchHistoryCell
        cell.keyword.text = keyword

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let keyword = searchController.history[indexPath.row]
        searchController.keyword.text = keyword
        searchController.search(keyword)
    }
}

class SearchController: UIViewController, UITextFieldDelegate {
    let service = CoreService.bind()
    let searchBar = UIStackView()
    let searchBarBackground = UIView()
    let keyword = UITextField()
    let btn_search = UIButton()
    let btn_clear = UIButton()
    let listView = UITableView()
    let contentArea = UIView()
    let loading = UIActivityIndicatorView()
    let adView = GADNativeExpressAdView()
    let adViewRequest = GADRequest()
    var history = [String]()

    var searchControllerImpl: SearchControllerInterface?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        _init()
    }

    func _init() {
        searchControllerImpl = GoogleSearchController(self)
    }

    func getMapCenter() -> CLLocationCoordinate2D {
        let parent = self.tabBarController as! ChannelController
        return parent.getMapCenter()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        history_or_autocomplete()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        search(textField.text!)
    }

    func search(_ keyword: String) {
        let keyword = keyword.trim()
        if keyword.isEmpty {
            setSearchResults([])
            adView.isHidden = false
            return
        }
        if let i = history.index(of: keyword) {
            history.remove(at: i)
        }
        history.insert(keyword, at: 0)
        while history.count > 15 {
            history.remove(at: history.count-1)
        }
        UserDefaults.standard.set(history, forKey: Key.SEARCH_HISTORY)

        adView.isHidden = true
        listView.isHidden = true
        loading.startAnimating()
        searchControllerImpl!.search(keyword)
    }

    var searchResults = [POI]()
    func setSearchResults(_ results: [POI]) {
        searchResults = results
        let parent = self.tabBarController as! ChannelController
        parent.setSearchResults(results)
        listView.dataSource = searchResultsDataSource
        listView.delegate = searchResultsDelegate
        listView.reloadData()
        btn_search.isHidden = true
        btn_clear.isHidden = false
        loading.stopAnimating()
        listView.isHidden = false
    }

    var autoCompeltes = [String]()
    func setAutoCompletes(_ autocompletes: [String]) {
        autoCompeltes = autocompletes
        listView.dataSource = autoCompletesDataSource
        listView.delegate = autoCompletesDelegate
        listView.reloadData()
        adView.isHidden = true
        loading.stopAnimating()
        listView.isHidden = false
    }

    func moveToSearchResult(at: Int) {
        let parent = self.tabBarController as! ChannelController
        parent.moveToSearchResult(at: at)
    }

    var searchResultsDataSource: UITableViewDataSource?
    var searchResultsDelegate: UITableViewDelegate?
    var autoCompletesDataSource: UITableViewDataSource?
    var autoCompletesDelegate: UITableViewDelegate?
    var searchHistoryDataSource: UITableViewDataSource?
    var searchHistoryDelegate: UITableViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.axis = .horizontal
        searchBar.alignment = .leading
        searchBar.distribution = .fill
        searchBar.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        searchBar.isLayoutMarginsRelativeArrangement = true

        searchBarBackground.translatesAutoresizingMaskIntoConstraints = false
        searchBarBackground.backgroundColor = .gray
        searchBar.insertSubview(searchBarBackground, at: 0)

        searchBarBackground.topAnchor.constraint(equalTo: searchBar.topAnchor).isActive = true
        searchBarBackground.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor).isActive = true
        searchBarBackground.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor).isActive = true
        searchBarBackground.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true

        keyword.translatesAutoresizingMaskIntoConstraints = false
        keyword.backgroundColor = .white
        keyword.layer.cornerRadius = 10
        keyword.delegate = self
        keyword.addTarget(self, action: #selector(keyword_changed(sender:)), for: .editingChanged)
        searchBar.addArrangedSubview(keyword)

        btn_search.translatesAutoresizingMaskIntoConstraints = false
        btn_search.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 5)
        btn_search.setTitle("🔍", for: .normal)
        btn_search.addTarget(self, action: #selector(search_clicked(sender:)), for: .touchUpInside)
        searchBar.addArrangedSubview(btn_search)

        btn_clear.translatesAutoresizingMaskIntoConstraints = false
        btn_clear.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 5)
        btn_clear.setTitle("✘", for: .normal)
        btn_clear.isHidden = true
        btn_clear.addTarget(self, action: #selector(clear_clicked(sender:)), for: .touchUpInside)
        searchBar.addArrangedSubview(btn_clear)

        keyword.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor).isActive = true
        btn_search.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor).isActive = true
        btn_clear.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor).isActive = true

        self.view.addSubview(searchBar)
        searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true

        listView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(listView)
        listView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        listView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        listView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        listView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
        listView.isHidden = true

        contentArea.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(contentArea)
        contentArea.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        contentArea.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        contentArea.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        contentArea.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true

        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.activityIndicatorViewStyle = .whiteLarge
        loading.color = UIColor.gray
        loading.hidesWhenStopped = true
        self.view.addSubview(loading)
        loading.centerXAnchor.constraint(equalTo: contentArea.centerXAnchor).isActive = true
        loading.centerYAnchor.constraint(equalTo: contentArea.centerYAnchor).isActive = true
        loading.stopAnimating()

        adView.translatesAutoresizingMaskIntoConstraints = false
        adView.rootViewController = self
        self.view.addSubview(adView)
        adView.centerXAnchor.constraint(equalTo: contentArea.centerXAnchor).isActive = true
        adView.centerYAnchor.constraint(equalTo: contentArea.centerYAnchor).isActive = true
        adWidth = adView.widthAnchor.constraint(equalTo: contentArea.widthAnchor, multiplier: 1)
        adHeight = adView.heightAnchor.constraint(equalTo: contentArea.heightAnchor, multiplier: 1)
        adMaxWidth = adView.widthAnchor.constraint(equalToConstant: 1200)
        adMaxHeight = adView.heightAnchor.constraint(equalToConstant: 1200)

        self.view.sendSubview(toBack: contentArea)

        searchResultsDataSource = searchControllerImpl!.getSearchResultsDataSource()
        searchResultsDelegate = searchControllerImpl!.getSearchResultsDelegate()
        autoCompletesDataSource = searchControllerImpl!.getAutoCompletesDataSource()
        autoCompletesDelegate = searchControllerImpl?.getAutoCompletesDelegate()
        let searchHistoryAdapter = SearchHistoryDelegate(self)
        searchHistoryDataSource = searchHistoryAdapter
        searchHistoryDelegate = searchHistoryAdapter

        listView.register(SearchHistoryCell.self, forCellReuseIdentifier: "search_history")

        searchControllerImpl!.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }

    var adWidth: NSLayoutConstraint?
    var adHeight: NSLayoutConstraint?
    var adMaxWidth: NSLayoutConstraint?
    var adMaxHeight: NSLayoutConstraint?
    var requestedSize = CGSize(width: -1, height: -1)
    override func viewDidLayoutSubviews() {
        let size = contentArea.bounds.size
        if size.width == requestedSize.width && size.height == requestedSize.height {
            return
        }
        requestedSize = size
        if size.width > 1200 {
            adWidth?.isActive = false
            adMaxWidth?.isActive = true
        } else {
            adMaxWidth?.isActive = false
            adWidth?.isActive = true
        }
        if size.height > 1200 {
            adHeight?.isActive = false
            adMaxHeight?.isActive = true
        } else {
            adMaxHeight?.isActive = false
            adHeight?.isActive = true
        }
        if size.width >= 280 && size.height >= 250 {
            adView.adUnitID = "ca-app-pub-5449795846702141/8341425315"
            adView.load(adViewRequest)
            return
        }
        if size.width >= 280 && size.height >= 132 {
            adView.adUnitID = "ca-app-pub-5449795846702141/5174306118"
            adView.load(adViewRequest)
            return
        }
        if size.width >= 280 && size.height >= 80 {
            adView.adUnitID = "ca-app-pub-5449795846702141/3557972113"
            adView.load(adViewRequest)
            return
        }
        adView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        history = UserDefaults.standard.stringArray(forKey: Key.SEARCH_HISTORY) ?? [String]()
    }

    func keyword_changed(sender: Any) {
        btn_clear.isHidden = true
        btn_search.isHidden = false
        history_or_autocomplete()
    }

    func history_or_autocomplete() {
        if keyword.text != nil && !keyword.text!.trim().isEmpty {
            searchControllerImpl!.autoComplete(keyword.text!.trim())
        } else {
            listView.dataSource = searchHistoryDataSource
            listView.delegate = searchHistoryDelegate
            listView.reloadData()
            adView.isHidden = true
            loading.stopAnimating()
            listView.isHidden = false
        }
    }

    func search_clicked(sender: Any) {
        keyword.resignFirstResponder()
        search(keyword.text!)
    }

    func clear_clicked(sender: Any) {
        keyword.text = ""
        keyword.resignFirstResponder()
        search("")
        adView.isHidden = false
        listView.isHidden = true
        btn_clear.isHidden = true
        btn_search.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardShown(_ n:NSNotification) {
        let d = n.userInfo!
        var r = (d[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        r = self.listView.convert(r, from:nil)
        self.listView.contentInset.bottom = r.size.height
        self.listView.scrollIndicatorInsets.bottom = r.size.height
    }

    func keyboardHide(_ n:NSNotification) {
        self.listView.contentInset.bottom = 0
        self.listView.scrollIndicatorInsets.bottom = 0
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
