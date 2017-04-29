//
//  SearchController.swift
//  whereim
//
//  Created by Buganini Q on 29/04/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import CoreLocation
import UIKit

protocol SearchControllerInterface {
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func getSearchResultListDataSource() -> UITableViewDataSource
    func getSearchResultListDelegate() -> UITableViewDelegate
    func search(_ keyword: String)
}

class SearchResult {
    var name: String?
    var location: CLLocationCoordinate2D?
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
        btn_clear.isHidden = true
        btn_search.isHidden = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        search(textField.text!)
    }

    func search(_ keyword: String) {
        if keyword.isEmpty {
            setSearchResults([])
            return
        }
        listView.isHidden = true
        loading.isHidden = false
        searchControllerImpl!.search(keyword)
    }

    var searchResults = [SearchResult]()
    func setSearchResults(_ results: [SearchResult]) {
        searchResults = results
        let parent = self.tabBarController as! ChannelController
        parent.setSearchResults(results)
        listView.reloadData()
        btn_search.isHidden = true
        btn_clear.isHidden = false
        loading.isHidden = true
        listView.isHidden = false
    }

    func moveToSearchResult(at: Int) {
        let parent = self.tabBarController as! ChannelController
        parent.moveToSearchResult(at: at)
    }

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
        self.view.addSubview(loading)
        loading.centerXAnchor.constraint(equalTo: contentArea.centerXAnchor).isActive = true
        loading.centerYAnchor.constraint(equalTo: contentArea.centerYAnchor).isActive = true
        loading.isHidden = true

        self.view.sendSubview(toBack: contentArea)

        listView.dataSource = searchControllerImpl!.getSearchResultListDataSource()
        listView.delegate = searchControllerImpl!.getSearchResultListDelegate()

        searchControllerImpl!.viewDidLoad()
    }

    func search_clicked(sender: Any) {
        keyword.resignFirstResponder()
        search(keyword.text!)
    }

    func clear_clicked(sender: Any) {
        keyword.text = ""
        search("")
        listView.isHidden = true
        btn_clear.isHidden = true
        btn_search.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
