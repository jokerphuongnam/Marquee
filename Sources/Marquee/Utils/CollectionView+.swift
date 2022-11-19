//
//  CollectionView+.swift
//  Marquee
//
//  Created by P.Nam on 19/11/2022.
//

import UIKit

public extension UICollectionView {
    public var subScrollViews:[UIScrollView] {
        subviews.compactMap { subview in
            subview as? UIScrollView
        }
        .sorted { lhs, rhs in
            if lhs.frame.minX == rhs.frame.minX {
                return lhs.frame.minX < rhs.frame.minX
            } else {
                return lhs.frame.minY < rhs.frame.minY
            }
        }
    }
}
