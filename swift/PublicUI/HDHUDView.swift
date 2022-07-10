//
//  HDHUDView.swift
//  HDPublicUIProject
//
//  Created by MountainZhu on 2020/6/17.
//  Copyright © 2020 航电. All rights reserved.
//

//使用说明
//使用(view).showLoading || (vc).showLoading
//

import UIKit

extension UIResponder {
    
    //MARK: -加载框 不带文字
    public func showLoading(isSupportClick: Bool? = false) {
        if Thread.isMainThread {
            HDHUDView.showLoading(text: nil, isClickHidden: isSupportClick)
        } else {
            DispatchQueue.main.async {
                self.showLoading(isSupportClick: isSupportClick)
            }
        }
    }
    
    //MARK: -加载框 带文字
    public func showLoading(text: String? = nil, isSupportClick: Bool? = false) {
        if Thread.isMainThread {
            HDHUDView.showLoading(text: text, isClickHidden: isSupportClick)
        } else {
            DispatchQueue.main.async {
                self.showLoading(text: text, isSupportClick: isSupportClick)
            }
        }
    }
    
    //MARK: -提示框
    public func show(text: String?) {
        if Thread.isMainThread {
            HDHUDView.show(text: text)
        } else {
            DispatchQueue.main.async {
                self.show(text: text)
            }
        }
    }
    
    //MARK: -成功
    public func showSuccess(text: String?) {
        if Thread.isMainThread {
            HDHUDView.showDetail(text: text, iconType: true)
        } else {
            DispatchQueue.main.async {
                self.showSuccess(text: text)
            }
        }
    }
    
    //MARK: -失败
    public func showFail(text: String?) {
        if Thread.isMainThread {
            HDHUDView.showDetail(text: text, iconType: false)
        } else {
            DispatchQueue.main.async {
                self.showFail(text: text)
            }
        }
    }
    
    //MARK: -隐藏所有HUD
    public func hideHUD() {
        if Thread.isMainThread {
            HDHUDView.hidden()
        } else {
            DispatchQueue.main.async {
                self.hideHUD()
            }
        }
    }
}

enum LoadingPositionType {
    case centerType, bottomType
}

class HDHUDView: UIView {

    static let initTool: HDHUDView = HDHUDView.initView()
    // MARK: -文字框属性设置
    /// 单行高度
    static let singleRowHeight: CGFloat = 35.0
    /// 最小文字宽度
    static let minTextWidth: CGFloat = 100.0
    /// 最大文字宽度
    static let maxTextWidth: CGFloat = HDConst.SCREENW - 100.0
    /// 是否自动隐藏 对文字框有效 默认自动隐藏
    static var isAutoHidden: Bool = true
    /// 自动隐藏时间 对文字框有效 默认1秒隐藏 需要先设置isAutoHidden属性
    static var autoHiddenTime: Double = 1.0
    /// 展示位置 对文字框有效 默认在中间
    static var positionType: LoadingPositionType = LoadingPositionType.centerType
    static var textCornerRadius: CGFloat = 5.0
    static var textViewBgColor: UIColor = UIColor.black
    static var fontSize: CGFloat = 14.0
    static var textColor: UIColor = UIColor.white
    
    // MARK: -菊花框属性设置
    /// 加载菊花大小
    static let loadViewWH: CGFloat = 75.0
    /// 加载菊花大小 带文字
    static let loadTextViewWH: CGFloat = 100.0
    /// 菊花框圆角大小 默认10.0
    static var loadViewCornerRadius: CGFloat = 10.0

    // MARK: -私有属性
    /// 控件tag值
    private let tooltag = 121212
    /// 是否点击隐藏 默认为NO
    private var isClickHidden: Bool = false
    /// 是否展示loading
    private var isShowLoading: Bool = true
    /// 是否已隐藏之前的控件
    private var isHiddenBefore: (()->Void)?
    
    /// 是否已经存在提示框
    lazy var isAleradlyExit: Bool = {
        let fatherWindow = UIApplication.shared.keyWindow
        return fatherWindow?.viewWithTag(tooltag) != nil
    }()
    
    /// 初始化
    class func initView() -> HDHUDView {
        let tool = HDHUDView.init(frame: UIScreen.main.bounds)
        tool.tag = tool.tooltag
        tool.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        tool.alpha = 0.0
        
        return tool
    }
    
    //MARK:- 展示加载菊花 是否支持点击取消 默认为可不支持点击取消
    static func showLoading(text: String?, isClickHidden: Bool? = false) {
        HDHUDView.hidden {
            let tool = HDHUDView.initTool
            tool.isShowLoading = true
            if let isClickHidden = isClickHidden {
                tool.isClickHidden = isClickHidden
            }
            
            let fatherWindow = UIApplication.shared.keyWindow
            fatherWindow?.addSubview(tool)
            
            if let text = text {
                // 菊花
                tool.loadingTool.center = CGPoint.init(x: HDHUDView.loadTextViewWH / 2.0, y: HDHUDView.loadTextViewWH / 2.0 - 10.0)
                tool.loadingTextView.addSubview(tool.loadingTool)
                tool.addSubview(tool.loadingTextView)
                
                // 文字
                tool.alertLabel.backgroundColor = UIColor.clear
                tool.updateLabelFrame(text: text, maxSize: CGSize.init(width: HDHUDView.loadTextViewWH - 10.0, height: HDHUDView.singleRowHeight))
                
                tool.alertLabel.center = CGPoint.init(x: HDHUDView.loadTextViewWH / 2.0, y: HDHUDView.loadTextViewWH / 2.0 + 30.0)
                tool.loadingTextView.addSubview(tool.alertLabel)
            } else {
                // 菊花
                tool.loadingTool.center = CGPoint.init(x: HDHUDView.loadViewWH / 2.0, y: HDHUDView.loadViewWH / 2.0)
                tool.loadingView.addSubview(tool.loadingTool)
                
                tool.addSubview(tool.loadingView)
            }
            
            tool.loadingTool.startAnimating()
            UIView.animate(withDuration: 0.3) {
                tool.alpha = 1.0
                if let _ = text {
                    tool.loadingTextView.alpha = tool.alpha
                    tool.alertLabel.alpha = tool.alpha
                } else {
                    tool.loadingView.alpha = tool.alpha
                }
            }
        }
    }
    
    //MARK:- 展示加载文字
    static func show(text: String?) {
        HDHUDView.hidden {
            let tool = HDHUDView.initTool
            let fatherWindow = UIApplication.shared.keyWindow
            fatherWindow?.addSubview(tool)
            
            // 文字
            tool.alertLabel.backgroundColor = HDHUDView.textViewBgColor
            tool.addSubview(tool.alertLabel)
            tool.updateLabelFrame(text: text, maxSize: CGSize.init(width: HDHUDView.maxTextWidth, height: HDConst.SCREENH))

            if HDHUDView.positionType == .centerType {
                tool.alertLabel.center = CGPoint.init(x: HDConst.SCREENW / 2.0, y: HDConst.SCREENH / 2.0)
            } else {
                tool.alertLabel.center = CGPoint.init(x: HDConst.SCREENW / 2.0, y: HDConst.SCREENH - tool.alertLabel.frame.size.height - 60.0)
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                tool.alpha = 1.0
                tool.alertLabel.alpha = tool.alpha
            }) { (isOk) in
                if HDHUDView.isAutoHidden {
                    self.perform(#selector(hidden), with: nil, afterDelay:HDHUDView.autoHiddenTime)
                }
            }
        }
    }
    
    //MARK:- 展示图标icon
    static func showDetail(text: String?, iconType: Bool) {
        HDHUDView.hidden {
            let tool = HDHUDView.initTool
            tool.isShowLoading = true
            let fatherWindow = UIApplication.shared.keyWindow
            fatherWindow?.addSubview(tool)
            
            // icon
            tool.iconImageView.center = CGPoint.init(x: HDHUDView.loadTextViewWH / 2.0, y: HDHUDView.loadTextViewWH / 2.0 - 10.0)
            tool.loadingTextView.addSubview(tool.iconImageView)
            tool.addSubview(tool.loadingTextView)
            
            // 文字
            tool.alertLabel.backgroundColor = UIColor.clear
            tool.updateLabelFrame(text: text, maxSize: CGSize.init(width: HDHUDView.loadTextViewWH - 10.0, height: HDHUDView.singleRowHeight))
            
            tool.alertLabel.center = CGPoint.init(x: HDHUDView.loadTextViewWH / 2.0, y: HDHUDView.loadTextViewWH / 2.0 + 30.0)
            tool.loadingTextView.addSubview(tool.alertLabel)
            
            let successPath = "true_icon.png"
            let failPath = "false_icon.png"
            if iconType {
                tool.iconImageView.image = UIImage(named: successPath)
            } else {
                tool.iconImageView.image = UIImage(named: failPath)
            }
            UIView.animate(withDuration: 0.3, animations: {
                tool.alpha = 1.0
                if let _ = text {
                    tool.loadingTextView.alpha = tool.alpha
                    tool.iconImageView.alpha = tool.alpha
                    tool.alertLabel.alpha = tool.alpha
                } else {
                    tool.iconImageView.alpha = tool.alpha
                    tool.loadingView.alpha = tool.alpha
                }
            }) { (isOk) in
                if HDHUDView.isAutoHidden {
                    self.perform(#selector(hidden), with: nil, afterDelay:HDHUDView.autoHiddenTime)
                }
            }
        }
    }
    
    //MARK:- 隐藏所有
    @objc static func hidden(isCompetion: (()->Void)? = nil) {
        let tool = HDHUDView.initTool
        tool.isHiddenBefore = isCompetion
        if tool.isShowLoading {
            tool.loadingTool.stopAnimating()
        }
        UIView.animate(withDuration: 0.3, animations: {
            tool.alpha = 0.0
            tool.alertLabel.alpha = tool.alpha
            if tool.isShowLoading {
                tool.loadingTextView.alpha = tool.alpha
                tool.loadingView.alpha = tool.alpha
                tool.iconImageView.alpha = tool.alpha
                tool.isShowLoading = false
            }
        }) { (isOk) in
            tool.removeFromSuperview()
            tool.isHiddenBefore?()
        }
    }

    /// 更新大小
    func updateLabelFrame(text: String?, maxSize: CGSize) {
        if text == nil {
            return
        }
        let tool = HDHUDView.initTool
        let size = text?.getSize(maxSize: maxSize)
        var newTextFrame = tool.alertLabel.frame
        newTextFrame.size.width = size!.width
        newTextFrame.size.height = size!.height
        tool.alertLabel.frame = newTextFrame
        tool.alertLabel.text = text
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if HDHUDView.initTool.isClickHidden {
            HDHUDView.hidden()
        }
    }
    
    //MARK: -懒加载
    
    /// 文字提示框
    lazy var alertLabel: UILabel = {
        let label = UILabel.init()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: HDHUDView.fontSize)
        label.textColor = HDHUDView.textColor
        label.layer.cornerRadius = HDHUDView.textCornerRadius
        label.layer.masksToBounds = true
        
        return label
    }()
    
    /// 加载等待框 带文字
    lazy var loadingTextView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: HDHUDView.loadTextViewWH, height: HDHUDView.loadTextViewWH))
        view.center = CGPoint.init(x: HDConst.SCREENW / 2.0, y: HDConst.SCREENH / 2.0)
        view.backgroundColor = HDHUDView.textViewBgColor
        view.layer.cornerRadius = HDHUDView.loadViewCornerRadius
        view.layer.masksToBounds = true
        
        return view
    }()
    
    /// 加载等待框
    lazy var loadingView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: HDHUDView.loadViewWH, height: HDHUDView.loadViewWH))
        view.center = CGPoint.init(x: HDConst.SCREENW / 2.0, y: HDConst.SCREENH / 2.0)
        view.backgroundColor = UIColor.black
        view.layer.cornerRadius = HDHUDView.loadViewCornerRadius
        view.layer.masksToBounds = true
        
        return view
    }()
    
    /// 系统菊花
    lazy var loadingTool: UIActivityIndicatorView = {
        let tool = UIActivityIndicatorView.init(style: .whiteLarge)
        tool.hidesWhenStopped = true
        
        return tool
    }()
    
    /// icon
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: HDHUDView.loadTextViewWH / 3, y: HDHUDView.loadTextViewWH / 4, width: HDHUDView.loadTextViewWH / 2.5, height: HDHUDView.loadTextViewWH / 2.5))
        imageView.center = CGPoint.init(x: HDConst.SCREENW / 2.0, y: HDConst.SCREENH / 2.0)
        return imageView
    }()
}

extension String {
    func getSize(maxSize: CGSize) -> CGSize {
        if self.isEmpty {
            return CGSize.init(width: HDHUDView.minTextWidth, height: HDHUDView.singleRowHeight)
        }
        let str: NSString = NSString.init(string: self)
        var rect = str.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: HDHUDView.fontSize)], context: nil)
        rect.size.width < HDHUDView.minTextWidth ? (rect.size.width = HDHUDView.minTextWidth) : (rect.size.width += 15.0)
        rect.size.height < HDHUDView.singleRowHeight ? (rect.size.height = HDHUDView.singleRowHeight) : (rect.size.height += 8.0)

        return rect.size
    }
}
