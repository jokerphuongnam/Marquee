//
//  MarqueeCollectionView.swift
//  Marquee
//
//  Created by P.Nam on 19/11/2022.
//

import InfiniteScrollCollectionView
import UIKit

private let maxAutoScrollSpeed: CGFloat = 100
private let minAutoScrollSpeed: CGFloat = 0
private let centimeterOf1Inch: CGFloat = 2.54

open class MarqueeInfiniteCollectionView: InfiniteScrollCollectionView {
    public static let scrollParent = -1
    
    private var isConfig = false
    private var autoScrollSpeed: CGFloat = .zero
    private var timerInterval: CGFloat = .zero
    private var movePointAmountForTimerInterval: CGFloat = .zero
    private var timer = Timer()
    
    open var autoScrollDefaultTimerInterval: CGFloat = 0.01
    open var autoScrollForSection: Int = .zero
    open var scrollSpeed: CGFloat = 30
    open var isAutoScroll = true
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if !isConfig {
            isConfig = true
            let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
            addGestureRecognizer(tapGesture)
            if isAutoScroll {
                setAutoScrollSpeed(scrollSpeed)
            }
        }
    }
    
    open func startAutoScroll() {
        setAutoScrollSpeed(scrollSpeed)
    }
    
    open func stopAutoScroll() {
        invalidateTimer()
    }
    
    private func setAutoScrollSpeed(_ autoScrollSpeed: CGFloat) {
        var availableAutoScrollSpeed: CGFloat
        if autoScrollSpeed > maxAutoScrollSpeed {
            availableAutoScrollSpeed = maxAutoScrollSpeed
        } else if autoScrollSpeed < minAutoScrollSpeed {
            availableAutoScrollSpeed = minAutoScrollSpeed
        } else {
            availableAutoScrollSpeed = autoScrollSpeed
        }
        
        self.autoScrollSpeed = availableAutoScrollSpeed
        if (self.autoScrollSpeed > 0) {
            let movePixelAmountForOneSeconds = self.autoScrollSpeed * CGFloat(DeviceInfo.getPixelPerInch()) * 0.1 / centimeterOf1Inch
            let movePointForOneSeconds = movePixelAmountForOneSeconds / UIScreen.main.scale
            let movePointAmountForTimerInterval = movePointForOneSeconds * autoScrollDefaultTimerInterval
            let floorMovePointAmountForTimerInterval = floor(movePointAmountForTimerInterval)
            if floorMovePointAmountForTimerInterval < 1 {
                self.movePointAmountForTimerInterval = 1
            } else {
                self.movePointAmountForTimerInterval = floorMovePointAmountForTimerInterval
            }
            timerInterval = movePointAmountForTimerInterval / movePointForOneSeconds
        }
        
        setupTimer()
    }
    
    private func setupTimer() {
        if timer.isValid {
            return
        }
        
        if autoScrollSpeed == 0 {
            invalidateTimer()
        } else {
            timer = Timer.scheduledTimer(
                timeInterval: TimeInterval(timerInterval),
                target: self,
                selector: #selector(timerDidFire),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    private func invalidateTimer() {
        if timer.isValid {
            timer.invalidate()
        }
    }
    
    private func setContentOffset(for scrollView: UIScrollView) {
        let isHorizontalScroll = scrollView.frame.width < scrollView.contentSize.width
        let nextContentOffset = CGPoint(
            x: scrollView.contentOffset.x + (isHorizontalScroll ? movePointAmountForTimerInterval : 0),
            y: scrollView.contentOffset.y + (isHorizontalScroll ? 0 : movePointAmountForTimerInterval)
        )
        scrollView.contentOffset = nextContentOffset
    }
    
    @objc private func timerDidFire() {
        let subScrollViews = subScrollViews
        if subScrollViews.isEmpty || autoScrollForSection < 0 {
            setContentOffset(for: self)
        } else if autoScrollForSection >= subScrollViews.count - 1 {
            setContentOffset(for: subScrollViews[subScrollViews.count - 1])
        } else {
            setContentOffset(for: subScrollViews[autoScrollForSection])
        }
    }
    
    @objc private func tapHandler(_ sender: UITapGestureRecognizer) {
        if sender.state == .began {
            stopAutoScroll()
        } else if sender.state == .ended {
            startAutoScroll()
        }
    }
}
