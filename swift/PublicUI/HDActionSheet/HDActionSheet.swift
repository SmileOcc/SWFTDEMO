//
//  HDActionSheet.swift
//  HDPublicUIProject
//
//  Created by MountainZhu on 2020/6/18.
//  Copyright © 2020 航电. All rights reserved.
//

//使用说明
//使用HDActionSheet()，可以定制public部分，可以选择block或者delegate
//

import Foundation
import UIKit

public typealias handlerAction = (Int) -> ()

public protocol HDActionSheetDelegate: NSObjectProtocol {
   func actionSheet(_ actionSheet: HDActionSheet, clickedButtonAt index: Int)
}

public class HDActionSheet: UIViewController {
    
    //MARK: - public property
    public var handler: handlerAction?
    public weak var delegate: HDActionSheetDelegate?
    public var textColor: UIColor?
    public var textFont: UIFont?
    public var cancelTextColor: UIColor?
    public var cancelTextFont: UIFont?
    public var actionSheetTitle: String?
    public var actionSheetTitleFont: UIFont?
    public var actionSheetTitleColor: UIColor?
    
    /// 弹出框默认alpha是0.7，默认是true，可以设置为ture、false
    public var actionSheetTranslucent: Bool = true {
        didSet {
            if !actionSheetTranslucent {
                self.tableView.alpha = 1.0
            }
        }
    }
    
    /// 半透明=true，false=透明
    public var translucent: Bool = true {
        didSet{
            if !translucent {
                self.overlayView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0)
            }
        }
    }
    
    //MARK: - private property
    fileprivate var seletedRow: Int!
    fileprivate let hasCancelButton: Bool
    fileprivate let screenWidth = UIScreen.main.bounds.size.width
    fileprivate let screenHeight = UIScreen.main.bounds.size.height
    fileprivate let buttonList: [String]!
    fileprivate var overlayView: UIView!
    fileprivate var tableView: UITableView!
    fileprivate let headerHeight: CGFloat = 5
    fileprivate let overlayBackgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.5)
    fileprivate let reuseIdentifier = "PGTableViewCell"
    fileprivate let reuseIdentifier1 = "PGTableViewTitleCell"
    
    //MARK: - system cycle
    public init(cancelButton: Bool = false, buttonList:[String]!) {
        self.buttonList = buttonList
        self.hasCancelButton = cancelButton
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.clear
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = .custom
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name:UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var height: CGFloat = 50
        var index: Int = 0
        if actionSheetTitle != nil && actionSheetTitle?.count != 0 {
            if hasCancelButton {
                index = 2
            }else {
                index = 1
            }
        } else if hasCancelButton {
            index = 1
        }
        if buttonList != nil && buttonList.count != 0 {
            var buttonCount = buttonList.count
            tableView.isScrollEnabled = false
            if buttonList.count > 8 {
                buttonCount = 8
                tableView.isScrollEnabled = true
            }
            if hasCancelButton {
                height = CGFloat(buttonCount + index) * height + headerHeight
            }else {
                height = CGFloat(buttonCount + index) * height
            }
        }
        var bottom: CGFloat = 0
        if #available(iOS 11.0, *) {
            bottom = self.view.safeAreaInsets.bottom
        }
        let frame = CGRect(x: 0, y: screenHeight - height - bottom, width: screenWidth, height: height + bottom)
        UIView.animate(withDuration: 0.2) {
            self.tableView.frame = frame
            self.overlayView.alpha = 1.0
        }
    }
    
    //MARK: - private method
    fileprivate func setup() {
        overlayView = UIView(frame: self.view.bounds)
        overlayView.backgroundColor = overlayBackgroundColor
        overlayView.alpha = 0
        self.view.addSubview(overlayView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(overlayViewTapHandler))
        overlayView.addGestureRecognizer(tap)
        
        var frame = self.view.frame
        frame.origin.y = self.screenHeight
        tableView = UITableView(frame: frame, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alpha = 0.7
        tableView.register(HDActionSheetTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(HDActionSheetTableViewTitleCell.self, forCellReuseIdentifier: reuseIdentifier1)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
    }
    
    @objc fileprivate func overlayViewTapHandler() {
        UIView.animate(withDuration: 0.2, animations: {
            var frame = self.tableView.frame
            frame.origin.y = self.view.bounds.size.height
            self.tableView.frame = frame
            self.overlayView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0)
        }) { _ in
            self.dismiss(animated: false, completion: {
                if self.seletedRow != nil {
                    self.handler?(self.seletedRow)
                    self.delegate?.actionSheet(self, clickedButtonAt: self.seletedRow)
                }
            })
        }
    }
    
    @objc fileprivate func deviceOrientationDidChange() {
        let height = self.tableView.bounds.size.height
        let width = self.view.bounds.size.width
        let y = self.view.bounds.size.height - height
        let frame = CGRect(x: 0, y: y, width: width, height: height)
        UIView.animate(withDuration: 0.2) {
            self.overlayView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2));
            self.tableView.frame = frame
            self.overlayView.frame = self.view.bounds
        }
    }
}

extension HDActionSheet {
    fileprivate func hasTitle() -> Bool {
        return actionSheetTitle != nil && actionSheetTitle!.count != 0
    }
    
    fileprivate func hasButtonList() -> Bool {
        return buttonList != nil && buttonList.count != 0
    }
    
    fileprivate func setCancelButtonTextColorAndTextFont(cell: HDActionSheetTableViewCell) {
        if cancelTextColor != nil {
            cell.signlabel.textColor = cancelTextColor
        } else {
            cell.signlabel.textColor = UIColor.black
        }
        if cancelTextFont != nil {
            cell.signlabel.font = cancelTextFont
        } else {
            cell.signlabel.font = UIFont.systemFont(ofSize: 17)
        }
    }
    
    fileprivate func setTextButtonTextColorAndTextFont(cell: HDActionSheetTableViewCell) {
        if textColor != nil {
            cell.signlabel.textColor = textColor
        } else {
            cell.signlabel.textColor = UIColor.black
        }
        if textFont != nil {
            cell.signlabel.font = textFont
        } else {
            cell.signlabel.font = UIFont.systemFont(ofSize: 17)
        }
    }
    
    fileprivate func setTitleColorAndTextFont(cell: HDActionSheetTableViewTitleCell) {
        if actionSheetTitleFont != nil {
            cell.titlelabel.font = actionSheetTitleFont
        } else {
            cell.titlelabel.font = UIFont.boldSystemFont(ofSize: 17)
        }
        if actionSheetTitleColor != nil {
            cell.titlelabel.textColor = actionSheetTitleColor
        } else {
            cell.titlelabel.textColor = UIColor.darkGray
        }
    }
}

extension HDActionSheet: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        if hasButtonList() && hasCancelButton {
            if hasTitle() {
                return 3
            }
            return 2
        }
        
        if hasTitle() {
            return 2
        }
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasTitle() {
            if section == 0 {
                return 1
            }
            if hasCancelButton && section == 2 {
                return 1
            }
            if hasButtonList() {
                return buttonList.count
            }
        }
        if section == 1 {
            return 1
        }
        if hasButtonList() {
            return buttonList.count
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if hasTitle() {
            if  indexPath.section == 0 {
                let cell: HDActionSheetTableViewTitleCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier1, for: indexPath) as! HDActionSheetTableViewTitleCell
                cell.titlelabel.text = self.actionSheetTitle
                setTitleColorAndTextFont(cell: cell)
                return cell
            }
            let cell: HDActionSheetTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! HDActionSheetTableViewCell
            if hasCancelButton && indexPath.section == 2 {
                cell.signlabel.text = "取消"
                self.setCancelButtonTextColorAndTextFont(cell: cell)
            } else {
                cell.signlabel.text = buttonList[indexPath.row]
                self.setTextButtonTextColorAndTextFont(cell: cell)
            }
            return cell
        }
        
        let cell: HDActionSheetTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! HDActionSheetTableViewCell
        if indexPath.section == 1 {
            cell.signlabel.text = "取消"
            self.setCancelButtonTextColorAndTextFont(cell: cell)
            return cell
        }
        if hasButtonList() {
            cell.signlabel.text = buttonList[indexPath.row]
            self.setTextButtonTextColorAndTextFont(cell: cell)
        }
        return cell
    }
}

extension HDActionSheet: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if hasTitle() {
            if indexPath.section == 2 {
                self.overlayViewTapHandler()
                return
            }
            if indexPath.section == 0 {
                return
            }
        } else if hasCancelButton && indexPath.section == 1 {
            self.overlayViewTapHandler()
            return
        }
        seletedRow = indexPath.row
        self.overlayViewTapHandler()
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let reuseIdentifier = "header"
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier)
        if (view == nil) {
            view = UITableViewHeaderFooterView(reuseIdentifier: reuseIdentifier)
            view?.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if hasCancelButton && self.buttonList != nil && self.buttonList.count != 0 {
            if actionSheetTitle != nil && actionSheetTitle?.count != 0 {
                if section == 2 {
                    return headerHeight
                }
            } else if section == 1 {
                return headerHeight
            }
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

