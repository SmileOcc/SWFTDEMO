//
//  PullToRefreshTool.swift
//  reuseTest
//
//  Created by wanwu on 2017/4/11.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

/**
 *  header和footer只可以添加一个，后面的覆盖前面的
 */
class PullToRefreshControl: NSObject {
    var header: PullToRefreshView?
    var footer: PullToRefreshView?
    weak var scrollView: UIScrollView!
    
    convenience init(scrollView: UIScrollView) {
        self.init()
        self.scrollView = scrollView
        
        setup()
    }
    
    //MARK: 横向
    @discardableResult
    func addDefaultHorizontalHeader(config: ((_ header: PullToRefreshDefaultHorizontalHeader) -> Void)? = nil) -> Self {
        let x = -scrollView.contentInset.left - 40
        header = PullToRefreshDefaultHorizontalHeader(frame: CGRect(x: x, y: 0, width: 40, height: scrollView.frame.height), scrollView: scrollView)
        scrollView.insertSubview(header!, at: 0)
        config?(header as! PullToRefreshDefaultHorizontalHeader)
        return self
    }
    
    @discardableResult
    func addDefaultHorizontalFooter(config: ((_ footer: PullToRefreshDefaultHorizontalFooter) -> Void)? = nil) -> Self {
        let width = max(scrollView.contentSize.width, scrollView.frame.width)
        let x = width + scrollView.contentInset.right
        footer = PullToRefreshDefaultHorizontalFooter(frame: CGRect(x: x, y: 0, width: 40, height: scrollView.frame.height), scrollView: scrollView)
        scrollView.insertSubview(footer!, at: 1)
        config?(footer as! PullToRefreshDefaultHorizontalFooter)
        return self
    }
    
    
    //MARK: 纵向
    @discardableResult
    func addDefaultFooter(config: ((_ footer: PullToRefreshDefaultFooter) -> Void)? = nil) -> Self {
        let y = maxHeight() + scrollView.contentInset.bottom
        footer = PullToRefreshDefaultFooter(frame: CGRect(x: 0, y: y, width: scrollView.frame.width, height: 50), scrollView: scrollView)
        scrollView.insertSubview(footer!, at: 1)
        config?(footer as! PullToRefreshDefaultFooter)
        return self
    }
    
    @discardableResult
    func addDefaultHeader(config: ((_ header: PullToRefreshDefaultHeader) -> Void)? = nil) -> Self {
        let y = -scrollView.contentInset.top - 60
        header = PullToRefreshDefaultHeader(frame: CGRect(x: 0, y: y, width: scrollView.frame.width, height: 60), scrollView: scrollView)
        scrollView.insertSubview(header!, at: 0)
        
        config?(header as! PullToRefreshDefaultHeader)
        return self
    }
    
    @discardableResult
    func addGifHeader(config: (_ header: PullToRefreshDefaultGifHeader) -> Void) -> Self {
        let y = -scrollView.contentInset.top - 80
        let gifHeader = PullToRefreshDefaultGifHeader(frame: CGRect(x: 0, y: y, width: scrollView.frame.width, height: 80), scrollView: scrollView)
        header = gifHeader
        scrollView.insertSubview(header!, at: 0)
        
        config(gifHeader)
        
        gifHeader.gifFrame = CGRect(x: 40, y: 20, width: 100, height: 60)
        
        return self
    }
    
    @discardableResult
    func addGifFooter(config: (_ footer: PullToRefreshDefaultGifFooter) -> Void) -> Self {
        let y = maxHeight() + scrollView.contentInset.bottom
        let gifFooter = PullToRefreshDefaultGifFooter(frame: CGRect(x: 0, y: y, width: scrollView.frame.width, height: 60), scrollView: scrollView)
        footer = gifFooter
        footer?.margin = 0
        scrollView.insertSubview(gifFooter, at: 0)
        
        config(gifFooter)
        
        gifFooter.gifFrame = CGRect(x: 40, y: gifFooter.margin, width: 100, height: 60)
        
        return self
    }
    
    private func setup() {
        scrollView.rx.observeWeakly(Int.self, "panGestureRecognizer.state")
            .subscribe(onNext: {
                [weak self] stateNum in
                guard let `self` = self else { return }
                var state = PullToRefreshState.wait
                switch stateNum {
                case UIGestureRecognizer.State.began.rawValue:
                    state = .begin
                case UIGestureRecognizer.State.ended.rawValue, UIGestureRecognizer.State.cancelled.rawValue:
                    state = .refreshing
                case UIGestureRecognizer.State.changed.rawValue:
                    state = .pulling
                default:
                    break
                }
                
                var visiableHeight_header: CGFloat = 0
                if let _ = self.header as? PullToRefreshHorizontalView {
                    visiableHeight_header = -self.scrollView.contentOffset.x - self.scrollView.contentInset.left
                } else {
                    visiableHeight_header = -self.scrollView.contentOffset.y - self.scrollView.contentInset.top
                }
                if visiableHeight_header > 0 {
                    if state != self.header?.state && self.header?.state != .refreshing {
                        if state == .refreshing {
                            if self.header?.state == .pullingComplate {
                                self.footer?.endRefresh()
                                self.header?.state = state
                                self.footer?.state = .wait
                            }
                        } else {
                            self.header?.state = state
                        }
                    }
                } else {
                    if state == .begin && self.header?.state != .refreshing {
                        self.header?.state = .begin
                    }
                }
                
                var visiableHeight_footer: CGFloat = 0
                if let _ = self.footer as? PullToRefreshHorizontalView {
                    let maxWidth = max(self.scrollView.contentSize.width, self.scrollView.frame.width)
                    visiableHeight_footer = self.scrollView.contentOffset.x + self.scrollView.frame.width - self.scrollView.contentInset.right - maxWidth
                } else {
                    visiableHeight_footer = self.scrollView.contentOffset.y + self.scrollView.frame.height - self.scrollView.contentInset.bottom - self.maxHeight()
                }
                if visiableHeight_footer > 0 && state != self.footer?.state && self.footer?.state != .refreshing && self.footer?.state != .noMoreData {
                    if state == .refreshing {
                        if self.footer?.state == .pullingComplate {
                            self.header?.endRefresh()
                            self.footer?.state = state
                        }
                    } else {
                        self.footer?.state = state
                    }
                } else {
                    if state == .begin && self.footer?.state != .noMoreData && self.footer?.state != .refreshing {
                        self.footer?.state = .begin
                    }
                }
            }).disposed(by: rx.disposeBag)
        
        
        scrollView.rx.observeWeakly(CGPoint.self, "contentOffset")
            .subscribe(onNext: {
                [weak self] tempPoint in
                guard let `self` = self else { return }
                if let header = self.header, let point = tempPoint {
                    var p: CGFloat = 0.0
                    
                    var visiableHeight: CGFloat = 0
                    //判断横向还是纵向
                    if let _ = header as? PullToRefreshHorizontalView {
                        visiableHeight = (-point.x - self.scrollView.contentInset.left)
                    } else {
                        visiableHeight = -point.y - self.scrollView.contentInset.top
                    }
                    if visiableHeight > 0 && header.state != .refreshing {
                        /// - header.margin - marginDely 防止进度增加过快，进度条还没显示就已经跑了一半的进度，，很尴尬。。。
                        if abs(visiableHeight) < header.margin + header.marginDely {
                            p = 0.001
                            header.progress = p
                        } else {
                            p = min(1.0, (abs(visiableHeight) - header.margin - header.marginDely) / header.refreshHeight)
                            if p >= 0 {
                                header.progress = p
                            }
                        }
                        
                        header.state = header.progress >= 1 ? .pullingComplate : .pulling
                        header.isHidden = header.hideWhenComplete && p <= 0
                    }
                }
                
                if let footer = self.footer, let point = tempPoint {
                    var visiableHeight: CGFloat = 0
                    
                    if let _ = footer as? PullToRefreshHorizontalView {
                        let maxWidth = max(self.scrollView.contentSize.width, self.scrollView.frame.width)
                        visiableHeight = point.x + self.scrollView.frame.width - self.scrollView.contentInset.right - maxWidth
                    } else {
                        visiableHeight = point.y + self.scrollView.frame.height - self.scrollView.contentInset.bottom - self.maxHeight()
                    }
                    
                    var p: CGFloat = 0.0
                    
                    if visiableHeight > 0 && footer.state != .refreshing && self.scrollView.contentSize.height > 0 {
                        /// - header.margin - marginDely 防止进度增加过快，
                        if footer.autoLoadWhenIsBottom && self.self.scrollView.contentSize.height > 0 {
                            footer.isHidden = false
                            footer.beginRefresh()
                        } else {
                            if abs(visiableHeight) < footer.margin + footer.marginDely {
                                p = 0.001
                                footer.progress = p
                            } else {
                                p = min(1.0, (abs(visiableHeight) - footer.margin - footer.marginDely) / footer.refreshHeight)
                                if p >= 0 {
                                    footer.progress = p
                                }
                            }
                            
                            if footer.state != .noMoreData {
                                footer.state = footer.progress >= 1 ? .pullingComplate : .pulling
                            }
                        }
                        
                        footer.isHidden = footer.hideWhenComplete && p <= 0
                    }
                    
                    if footer.state == .noMoreData || footer.state == .refreshing {
                        footer.isHidden = false
                    }
                }
            }).disposed(by: rx.disposeBag)
        
        scrollView.rx.observeWeakly(CGSize.self, "contentSize")
            .subscribe(onNext: {
                [weak self] size in
                guard let `self` = self else { return }
                
                guard let footer = self.footer else { return }
                
                if let f = footer as? PullToRefreshDefaultHorizontalFooter {
                    let maxWidth = max(self.scrollView.contentSize.width, self.scrollView.frame.width)
                    footer.frame.origin.x = maxWidth + f.originalRight
                } else {
                    let y = self.maxHeight() + footer.originalBottom
                    footer.frame.origin.y = y
                }
                
            }).disposed(by: rx.disposeBag)
        
        scrollView.rx.observeWeakly(CGRect.self, "bounds")
            .subscribe(onNext: {
                [weak self] tempBounds in
                guard let `self` = self, let bounds = tempBounds else { return }
                if self.header is PullToRefreshHorizontalView || self.footer is PullToRefreshHorizontalView {
                    self.header?.bounds.size.height = bounds.size.height
                    self.footer?.bounds.size.height = bounds.height
                    self.header?.frame.origin.y = 0
                    self.footer?.frame.origin.y = 0
                } else {
                    self.header?.bounds.size.width = bounds.size.width
                    self.footer?.bounds.size.width = bounds.width
                    self.header?.frame.origin.x = 0
                    self.footer?.frame.origin.x = 0
                }
            }).disposed(by: rx.disposeBag)
       
    }
    
    
    func maxHeight() -> CGFloat {
        max(scrollView.contentSize.height, scrollView.frame.height)
    }
}
