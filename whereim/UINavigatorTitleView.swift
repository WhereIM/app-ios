//
//  UINavigatorTitleView.swift
//  whereim
//
//  Created by Buganini Q on 18/12/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit

class UINavigatorTitleView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
}
