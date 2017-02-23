//
//  UICompactStackView.swift
//  whereim
//
//  Created by Buganini Q on 24/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class UICompactStackView: UIStackView, AUIView {
    func requestLayout() {
        switch self.axis {
        case .horizontal:
            var max_edge = 0.0
            var total_edge = 0.0
            for view in self.subviews {
                if let v = view as? AUIView {
                    v.requestLayout()
                }
                if view.bounds.width > 0 && view.bounds.height > 0 {
                    max_edge = max(max_edge, Double(view.bounds.height))
                    total_edge += Double(view.bounds.width)
                } else {
                    max_edge = max(max_edge, Double(view.intrinsicContentSize.height))
                    total_edge += Double(view.intrinsicContentSize.width)
                }
            }
            self.frame = CGRect(x: 0, y: 0, width: total_edge, height: max_edge)
        case .vertical:
            var max_edge = 0.0
            var total_edge = 0.0
            for view in self.subviews {
                if let v = view as? AUIView {
                    v.requestLayout()
                }
                if view.bounds.width > 0 && view.bounds.height > 0 {
                    max_edge = max(max_edge, Double(view.bounds.width))
                    total_edge += Double(view.bounds.height)
                } else {
                    max_edge = max(max_edge, Double(view.intrinsicContentSize.width))
                    total_edge += Double(view.intrinsicContentSize.height)
                }
            }
            self.frame = CGRect(x: 0, y: 0, width: max_edge, height: total_edge)
        }
    }
}
