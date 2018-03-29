//
//  ImageViewerController.swift
//  whereim
//
//  Created by Buganini Q on 28/03/2018.
//  Copyright © 2018 Where.IM. All rights reserved.
//

import Alamofire
import UIKit

class ImageViewerController: UIViewController, UIScrollViewDelegate {
    var sender: String
    var time: Int64
    var image: Image

    let titleLayout = UIStackView()
    let senderView = UILabel()
    let timeView = UILabel()

    let loading = UIActivityIndicatorView()
    let scrollView = UIScrollView()
    let imageView = UIImageView()

    init(_ sender: String, _ time: Int64, _ image: Image) {
        self.sender = sender
        self.time = time
        self.image = image
        super.init(nibName:nil, bundle:nil)
    }

    override func viewDidLoad() {
        let navigator = UINavigatorTitleView(frame: (self.navigationController?.navigationBar.bounds)!)

        titleLayout.translatesAutoresizingMaskIntoConstraints = false
        titleLayout.axis = .vertical
        titleLayout.alignment = .leading
        titleLayout.distribution = .fill

        senderView.translatesAutoresizingMaskIntoConstraints = false
        senderView.adjustsFontSizeToFitWidth = false
        senderView.text = sender

        let lymdFormatter = DateFormatter()
        let eeeFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        lymdFormatter.dateStyle = .medium
        lymdFormatter.timeStyle = .none
        eeeFormatter.dateFormat = "EEE"
        timeFormatter.dateFormat = "HH:mm"
        let t = Date(timeIntervalSince1970: TimeInterval(time))
        let lymd = lymdFormatter.string(from: t)
        let eee = eeeFormatter.string(from: t)
        let dateString = String(format: "date_format".localized, eee, lymd)
        let timeString = timeFormatter.string(from: t)

        timeView.translatesAutoresizingMaskIntoConstraints = false
        timeView.font = timeView.font.withSize(12)
        timeView.adjustsFontSizeToFitWidth = false
        timeView.text = "\(dateString) \(timeString)"

        titleLayout.addArrangedSubview(senderView)
        titleLayout.addArrangedSubview(timeView)

        navigator.addSubview(titleLayout)

        titleLayout.leadingAnchor.constraint(equalTo: navigator.leadingAnchor).isActive = true
        titleLayout.centerYAnchor.constraint(equalTo: navigator.centerYAnchor).isActive = true

        self.navigationItem.titleView = navigator

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.backgroundColor = .black
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.flashScrollIndicators()

        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(tap)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)

        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true

        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.hidesWhenStopped = true
        loading.startAnimating()
        view.addSubview(loading)
        loading.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loading.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.bringSubview(toFront: loading)

        self.edgesForExtendedLayout = []
        super.viewDidLoad()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        let root = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let pvpath = root.appendingPathComponent("preview/\(self.image.key).\(self.image.ext)")

        if FileManager.default.fileExists(atPath: pvpath.path) {
            showImage(pvpath)
        } else {
            let pvfolder = root.appendingPathComponent("preview")
            do {
                try FileManager.default.createDirectory(atPath: pvfolder.path, withIntermediateDirectories: false, attributes: nil)
            } catch {
                // noop
            }

            Alamofire.request(Config.getPreview(image)).responseData { response in
                let data = response.result.value!
                do {
                    try data.write(to: pvpath)
                    DispatchQueue.main.async {
                        self.showImage(pvpath)
                    }
                } catch {
                    print(error)
                }
            }
        }
    }

    func showImage(_ path: URL){
        do {
            let data = try Data(contentsOf: URL(string: path.absoluteString)!)
            let im = UIImage(data: data)!
            imageView.image = im

            let scale = min(scrollView.bounds.size.width/im.size.width, scrollView.bounds.size.height/im.size.height)
            scrollView.minimumZoomScale = scale
            scrollView.maximumZoomScale = max(scale, 1.2)
            scrollView.setZoomScale(scale, animated: false)

            let ox = ((scrollView.bounds.size.width - im.size.width*scale))*0.5
            let oy = ((scrollView.bounds.size.height - im.size.height*scale))*0.5
            scrollView.contentInset = UIEdgeInsets.init(top: oy, left: ox, bottom: oy, right: ox)

            loading.isHidden = true
        } catch {
            print("Unable to load data: \(error)")
        }
    }

    @objc func doubleTapped(gestureReconizer: UITapGestureRecognizer) {
        if (gestureReconizer.state == UIGestureRecognizerState.ended) {
            if let im = imageView.image {
                if scrollView.zoomScale >= 1 {
                    let scale = min(scrollView.bounds.size.width/im.size.width, scrollView.bounds.size.height/im.size.height)
                    scrollView.setZoomScale(scale, animated: true)
                } else {
                    scrollView.setZoomScale(1.0, animated: true)
                }
            }
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
