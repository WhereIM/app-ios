//
//  UIFrameView.swift
//  whereim
//
//  Created by Buganini Q on 24/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class UIFrameView: UIView, AUIView {
    func requestLayout() {
        var max_width = 0.0
        var max_height = 0.0
        for view in self.subviews {
            if let v = view as? AUIView {
                v.requestLayout()
            }
            if view.bounds.size.width > 0 && view.bounds.size.height > 0 {
                max_width = max(max_width, Double(view.bounds.size.width))
                max_height = max(max_height, Double(view.bounds.size.height))
            } else {
                max_width = max(max_width, Double(view.intrinsicContentSize.width))
                max_height = max(max_height, Double(view.intrinsicContentSize.height))
            }
        }
        self.frame = CGRect(x: 0, y: 0, width: max_width, height: max_height)
    }
}
