//
//  HDFixTypeSelectView.swift
//  HDPublicUIProject
//
//  Created by 航电 on 2020/8/31.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

public enum HDFixTypeSelectType {
    case twoScroll
    case threeScroll
}

public protocol HDFixTypeSelectViewDelegate: NSObjectProtocol {
    func fixTypeSelectView(selectView: HDFixTypeSelectView, selectIndex: Int, selectDic: NSDictionary)
}

public class HDFixTypeSelectView: UIView {

    public var dataDic:NSDictionary {
        set {
            scrollDataDic = newValue;
            
            onChangeUIForData();
        }
        get {
            return scrollDataDic;
        }
    }
    
    public var inputDic: NSDictionary {
        set {
            if selectDic == newValue {
                return
            }
            selectDic = newValue
            self.viewToSelect(selectDic: selectDic)
        }
        get {
            return selectDic;
        }
    }
    
    public var cancelBlock:(() -> Void)?
    public var selectBlock:((NSDictionary,NSInteger) -> Void)?
    public var currentTag:NSInteger = 0;
    public var selectFixType:HDFixTypeSelectType?
    
    private var titleName:NSString?
    private var contentName:NSString?
    private var mainRequestMutArr:NSMutableArray = NSMutableArray();
    
    //UI
    private var bgView:UIView?
    private var mainScrollView:UIScrollView?
    private var mainLineView:UIView?
    private var selectWindow:UIWindow?
    
    //三个表数据
    private var firstFixArr:NSMutableArray = NSMutableArray();
    private var secondFixArr:NSMutableArray = NSMutableArray();
    private var threeFixArr:NSMutableArray = NSMutableArray();
    //三个表选中
    private var firstSelectIndex:NSInteger = -1;
    private var secondSelectIndex:NSInteger = -1;
    private var threeSelectIndex:NSInteger = -1;
    //选中的标题数据
    private var titleMutArr:NSMutableArray?;
    
    private var scrollDataDic:NSDictionary = NSDictionary();
    private var selectDic: NSDictionary = NSDictionary()
    private var selectFixNum = 0
    public weak var delegate: HDFixTypeSelectViewDelegate?
    
    public init(frame: CGRect,title:NSString,contentName:NSString,type:HDFixTypeSelectType) {
        super.init(frame: frame);
        
        self.titleName = title;
        self.contentName = contentName;
        self.selectFixType = type;
        
        if type == .twoScroll {
            self.onCreaeUIForTwoScroll();
        }
        else if type == .threeScroll {
            self.onCreaeUIForTwoScroll();
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: ***** UI *****
    private func onCreaeUIForOneScroll() {
        
    }
    
    private func onCreaeUIForTwoScroll() {
        let allHeight:CGFloat = .scaleH(45.0) + .scaleH(40.0) + .scaleH(430.0);
        self.bgView = self.onCreateUIForView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - allHeight, width: UIScreen.main.bounds.size.width, height: allHeight), bgColor: .WhiteToBlack());
        self.addSubview(self.bgView!);
        
        //头部
        let headerView = self.onCreateUIForView(frame: CGRect(x: 0, y: 0, width: self.bgView!.width, height: .scaleH(45.0)), bgColor: .clear);
        self.bgView?.addSubview(headerView);
        self.onCreateUIForHeaderView(view: headerView);
        
        var titleName = "请选择";
        if self.selectFixType == .twoScroll {
            titleName = "请选择维修类型";
        }
        else if self.selectFixType == .threeScroll {
            titleName = "请选择服务细则";
        }
        self.titleMutArr = NSMutableArray(array: [titleName]);
        
        //生成标题内容
        let titleLb = self.onAddSubTitleLb(currentTg: 0);
        
        //内容
        self.mainScrollView = UIScrollView(frame: CGRect(x: 0, y: titleLb.bottom, width: headerView.width, height: self.bgView!.height-titleLb.bottom));
        self.mainScrollView?.backgroundColor = .clear;
        self.mainScrollView?.isPagingEnabled = true;
        self.mainScrollView?.bounces = false;
        self.mainScrollView?.delegate = self;
        self.bgView?.addSubview(self.mainScrollView!);
        
        self.onAddsubTableView(currentTg: 0);
    }
    
    private func onCreateUIForHeaderView(view:UIView) {
        let titleLb = self.onCreateUIForLabel(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height - 1.0), title: self.titleName! as String, font: UIFont.systemFont(ofSize: .scaleW(16.0), weight: .medium), align: .center, textColor: .DarkGrayTitle());
        view.addSubview(titleLb);
        
        let titleArray = ["取消","确定"];
        for i in 0 ..< titleArray.count {
            let bt = UIButton(type: .custom);
            bt.frame = CGRect(x: (i==0 ? 0 : view.width - .scaleW(80.0)), y: 0, width: .scaleW(80.0), height: view.height);
            bt.backgroundColor = .clear;
            bt.setTitle(titleArray[i], for: .normal);
            bt.setTitleColor(.DarkGrayTitle(), for: .normal);
            bt.titleLabel?.font = UIFont.systemFont(ofSize: .scaleW(16.0), weight: .regular);
            bt.tag = 4100 + i;
            bt.addTarget(self, action: #selector(onCancelOrSureAction(bt:)), for: .touchUpInside);
            view.addSubview(bt);
        }
        
    }
    
    //MARK: ***** Actions *****
    //TODO: 自动生成label
    private func onCreateUIForLabel(frame:CGRect,title:String,font:UIFont,align:NSTextAlignment,textColor:UIColor) -> UILabel {
        let lb = UILabel(frame: frame);
        lb.text = title;
        lb.font = font;
        lb.textAlignment = align;
        lb.textColor = textColor;
        lb.backgroundColor = .clear
        return lb;
    }
    
    //TODO: 自动生成view
    private func onCreateUIForView(frame:CGRect,bgColor:UIColor) -> UIView {
        let view = UIView(frame: frame);
        view.backgroundColor = bgColor;
        return view;
    }
    
    //TODO: 获取label的宽度/高度
    private func onGetTitleWidthFromText(lb:UILabel,isWidth:Bool) -> CGFloat {
        var lbWidth:CGFloat = 0.0;
        let stringName = NSString(string: lb.text!) ;
        if isWidth {
            lbWidth = stringName.boundingRect(with: CGSize(width: 1000, height: lb.height), options: .usesLineFragmentOrigin, attributes: [.font : lb.font as UIFont], context: nil).size.width;
        } else {
            lbWidth = stringName.boundingRect(with: CGSize(width: lb.width, height: 1000), options: .usesLineFragmentOrigin, attributes: [.font : lb.font as UIFont], context: nil).size.height;
        }
        return lbWidth;
    }
    
    //TODO: 自动生成标题
    private func onAddSubTitleLb(currentTg:NSInteger) -> UILabel {
        
        var itemLeft:CGFloat = .scaleW(15.0);
        var titleName = "请选择";
        if self.selectFixType == .twoScroll {
            titleName = "请选择维修类型";
        }
        else if self.selectFixType == .threeScroll {
            titleName = "请选择服务细则";
        }
        
        if currentTg == 0 {
            itemLeft = .scaleW(15.0);
            titleName = "请选择";
            if self.selectFixType == .twoScroll {
                titleName = "请选择维修类型";
            }
            else if self.selectFixType == .threeScroll {
                titleName = "请选择服务细则";
            }
        }
        else if currentTg == 1 {
            let lastLb:UILabel = self.bgView?.viewWithTag((6000+currentTg-1)) as! UILabel;
            itemLeft = lastLb.right + .scaleW(30.0);
            titleName = "请选择";
            if self.selectFixType == .twoScroll {
                titleName = "请选择维修类型";
            }
            else if self.selectFixType == .threeScroll {
                titleName = "请选择服务细则";
            }
        }
        else if currentTg == 2 {
            let lastLb:UILabel = self.bgView?.viewWithTag((6000+currentTg-1)) as! UILabel;
            itemLeft = lastLb.right + .scaleW(30.0);
            titleName = "请选择";
            if self.selectFixType == .threeScroll {
                titleName = "请选择服务细则";
            }
        }
        
        var cLb = self.bgView?.viewWithTag(6000+currentTg);
        if cLb == nil {
            let newtitleLb = self.onCreateUIForLabel(frame: CGRect(x: itemLeft, y: .scaleH(45.0), width: .scaleW(80.0), height: .scaleH(40.0)), title: "", font: UIFont.systemFont(ofSize: .scaleW(15.0), weight: .medium), align: .left, textColor: .DarkGrayTitle());
            newtitleLb.isUserInteractionEnabled = true;
            newtitleLb.tag = 6000 + currentTg;
            self.bgView?.addSubview(newtitleLb);
            
            let tapGest = UITapGestureRecognizer(target: self, action: #selector(onTapForTitleChange(tap:)));
            newtitleLb.addGestureRecognizer(tapGest);
            cLb = newtitleLb;
        }
        let titleLb = (cLb as! UILabel);
        titleLb.left = itemLeft;
        titleLb.text = titleName;
        let titleWidth = self.onGetTitleWidthFromText(lb: titleLb, isWidth: true);
        titleLb.width = titleWidth;
        
        if self.mainLineView == nil {
            self.mainLineView = self.onCreateUIForView(frame: CGRect(x: titleLb.centerX - .scaleW(15.0), y: titleLb.bottom-1, width: .scaleW(30.0), height: 1), bgColor: .BlueTextColor());
            self.bgView?.addSubview(self.mainLineView!);
        } else {
            self.mainLineView?.frame = CGRect(x: titleLb.centerX - self.mainLineView!.width / 2.0, y: titleLb.bottom-1, width: self.mainLineView!.width, height: self.mainLineView!.height);
        }
        
        return titleLb;
    }
    
    //TODO: 自动生成表格内容
    private func onAddsubTableView(currentTg:NSInteger) {
        var tbV = self.mainScrollView?.viewWithTag(7000+currentTg);
        if tbV == nil {
            let tableV = UITableView(frame: CGRect(x: self.mainScrollView!.width * CGFloat(currentTg), y: 0, width: self.mainScrollView!.width, height: self.mainScrollView!.height), style: .plain);
            tableV.separatorStyle = .none;
            tableV.delegate = self;
            tableV.dataSource = self;
            tableV.backgroundColor = .clear;
            tableV.tag = 7000 + currentTg;
            self.mainScrollView?.addSubview(tableV);
            tbV = tableV;
        }
        let tableV = (tbV as! UITableView);
        self.mainScrollView?.contentSize = CGSize(width: self.mainScrollView!.width * CGFloat(currentTg+1), height: 0.0);
        tableV.reloadData();
        self.mainScrollView?.setContentOffset(CGPoint(x: self
            .mainScrollView!.width*CGFloat(currentTg), y: 0), animated: true);
    }
    
    //TODO: 根据父类ID筛选子类
    private func onSortChildFixFromSuper(_ superId:String,_ childArray:NSArray) -> NSArray {
        let selectArray:NSMutableArray = NSMutableArray();
        
        if childArray.count > 0 && superId.count > 0 {
            for i in 0..<childArray.count {
                let dic = childArray[i] as! NSDictionary;
                let pid = String(dic["pid"] as! Int);
                if superId == pid {
                    selectArray.add(dic);
                }
            }
        }
        
        return selectArray;
    }
    
    //TODO: 标题内容点击
    @objc private func onTapForTitleChange(tap:UITapGestureRecognizer) {
        if self.mainScrollView?.isScrollEnabled ?? true {
            let lb = tap.view as! UILabel;
            if lb.isKind(of: UILabel.self) {
                let tag = lb.tag - 6000;
                self.mainScrollView?.setContentOffset(CGPoint(x: self.mainScrollView!.width * CGFloat(tag), y: 0), animated: true);
                
                UIView.animate(withDuration: 0.15) {
                    self.mainLineView?.frame = CGRect(x: lb.centerX - self.mainLineView!.width / 2.0, y: self.mainLineView!.top, width: self.mainLineView!.width, height: self.mainLineView!.height);
                };
            }
        }
    }
    
    //TODO: 根据选择字典选定
    func viewToSelect(selectDic: NSDictionary) {
        self.firstSelectIndex = 0
        self.secondSelectIndex = 0
        self.threeSelectIndex = -1
            
        if self.firstFixArr.count > 0 {
            for (index, tempDic) in self.firstFixArr.enumerated() {
                let firstDic = tempDic as? NSDictionary
                let parentId = selectDic["maintainTypeParentId"] as? Int
                let firstId = firstDic?["id"] as? Int
                if parentId == firstId {
                    self.firstSelectIndex = index
                }
            }
            let dic = self.firstFixArr.object(at: self.firstSelectIndex) as! NSDictionary;
            if self.mainRequestMutArr.count > 1 {
                //更加选中的第一个表id获取第二表数据
                let secondArray = self.mainRequestMutArr[1] as! NSArray;
                let fixId = String(dic.object(forKey: "id") as! Int);
                let secondSelectArray = self.onSortChildFixFromSuper(fixId, secondArray);
                
                self.secondFixArr.removeAllObjects();
                self.secondFixArr.addObjects(from: secondSelectArray as! [Any]);
                
                let titleName = NSString.checkStringName(value: NSString(string: dic.object(forKey: "typeName") as! String)) as NSString;
                let lastLb = self.bgView?.viewWithTag(6000) as! UILabel;
                lastLb.text = titleName as String;
                let titleWidth = self.onGetTitleWidthFromText(lb: lastLb, isWidth: true);
                lastLb.width = titleWidth;
            }
            
            //添加新的标题
            let nextLb = self.onAddSubTitleLb(currentTg: 1);
            let lastLb = self.bgView?.viewWithTag(6002);
            if lastLb != nil {
                let lastLabel = lastLb as! UILabel;
                lastLabel.left = nextLb.right + .scaleW(30.0);
                lastLabel.text = "请选择服务细则";
                let titleWidth = self.onGetTitleWidthFromText(lb: lastLabel, isWidth: true);
                lastLabel.width = titleWidth;
            }
            //添加表
            self.onAddsubTableView(currentTg: 1);
        }
        
        if self.secondFixArr.count > 0 {
            for (index, tempDic) in self.secondFixArr.enumerated() {
                let secondFixDic = tempDic as? NSDictionary
                let selectSecondId = selectDic["maintainTypeChildId"] as? Int
                let secondFixId = secondFixDic?["id"] as? Int
                if selectSecondId == secondFixId {
                    self.secondSelectIndex = index
                }
            }
            let dic = self.secondFixArr.object(at: self.secondSelectIndex) as! NSDictionary;
            if self.mainRequestMutArr.count > 2 {
                //更加选中的第2个表id获取第3表数据
                let therrArray = self.mainRequestMutArr[2] as! NSArray;
                let fixId = String(dic.object(forKey: "id") as! Int);
                let threeSelectArray = self.onSortChildFixFromSuper(fixId, therrArray);

                self.threeFixArr.removeAllObjects();
                self.threeFixArr.addObjects(from: threeSelectArray as! [Any]);
                
                let titleName = NSString.checkStringName(value: NSString(string: dic.object(forKey: "typeName") as! String)) as NSString;
                let lastLb = self.bgView?.viewWithTag(6001) as! UILabel;
                lastLb.text = titleName as String;
                let titleWidth = self.onGetTitleWidthFromText(lb: lastLb, isWidth: true);
                lastLb.width = titleWidth;
            }
                
            //添加新的标题
            let nextLb = self.onAddSubTitleLb(currentTg: 2);
            let lastLb = self.bgView?.viewWithTag(6001) as! UILabel;
            if nextLb.width > (self.width - lastLb.right - .scaleW(30.0)) {
                nextLb.width = (self.width - lastLb.right - .scaleW(30.0));
            }
            
            //添加表
            self.onAddsubTableView(currentTg: 2);
        }
    }
    
    //TODO: 取消、确定
    @objc private func onCancelOrSureAction(bt:UIButton) {
        let index = bt.tag - 4100;
        if index == 0 {
            //取消
            self.onHideInWindow();
            
            if (self.cancelBlock != nil) {
                self.cancelBlock!();
            }
        }
        else if index == 1 {
            //确定
            if self.selectFixType == .twoScroll {
                if self.firstSelectIndex == -1 || self.secondSelectIndex == -1 {//直选两级
                    return;
                }
                if (self.selectBlock != nil) {
                    if self.threeFixArr.count > self.threeSelectIndex {
                        let firstDic = self.firstFixArr.object(at: self.firstSelectIndex) as! NSDictionary
                        let secondDic = self.secondFixArr.object(at: self.secondSelectIndex) as! NSDictionary
                        
                        self.selectBlock!(["firstDic": firstDic,"secondDic": secondDic] as NSDictionary,self.currentTag);
                    }
                }
            }
            else if self.selectFixType == .threeScroll {
                if self.firstSelectIndex == -1 || self.secondSelectIndex == -1 || self.threeSelectIndex == -1 {//直选三级
                    return;
                }
                if (self.selectBlock != nil) {
                    if self.threeFixArr.count > self.threeSelectIndex {
                        let firstDic = self.firstFixArr.object(at: self.firstSelectIndex) as! NSDictionary
                        let secondDic = self.secondFixArr.object(at: self.secondSelectIndex) as! NSDictionary
                        let threeDic = self.threeFixArr.object(at: self.threeSelectIndex) as! NSDictionary
                        
                        self.selectBlock!(["firstDic": firstDic,"secondDic": secondDic,"threeDic": threeDic] as NSDictionary,self.currentTag);
                    }
                }
            }
            
            self.onHideInWindow();
        }
    }
    
    //TODO: 更改UI
    private func onChangeUIForData() {
        self.mainRequestMutArr.removeAllObjects();
        let fix1Arr:NSArray = scrollDataDic.object(forKey: "fix1") as! NSArray;
        let fix2Arr:NSArray = scrollDataDic.object(forKey: "fix2") as! NSArray;
        let fix3Arr:NSArray = scrollDataDic.object(forKey: "fix3") as! NSArray;
        self.mainRequestMutArr.add(fix1Arr);
        self.mainRequestMutArr.add(fix2Arr);
        self.mainRequestMutArr.add(fix3Arr);
        
        if self.selectFixNum == 0 {
            //第一个表显示的数据
            self.firstFixArr.removeAllObjects();
            self.firstFixArr.addObjects(from: fix1Arr as! [Any]);
            
            //刷新数据
            let tbv = self.mainScrollView?.viewWithTag(7000) as! UITableView;
            tbv.reloadData();
        } else {
            if self.mainRequestMutArr.count > self.selectFixNum {
                //更加选中的第一个表id获取第二表数据
                let selectArray = self.mainRequestMutArr[self.selectFixNum] as! NSArray;

                if self.selectFixNum == 1 {
                    self.secondFixArr.removeAllObjects();
                    self.secondFixArr.addObjects(from: selectArray as! [Any]);
                } else {
                    self.threeFixArr.removeAllObjects();
                    self.threeFixArr.addObjects(from: selectArray as! [Any]);
                }
            }
            
            //添加表
            self.onAddsubTableView(currentTg: self.selectFixNum);
        }
    }
    
    //MARK: >>>>> 声明公共方法
    //TODO: 显示窗口
    public func onShowInWindow() {
        if self.selectWindow == nil {
            let frame = UIApplication.shared.keyWindow?.frame;
            self.selectWindow = UIWindow(frame: frame!);
            self.selectWindow?.backgroundColor = UIColor.black.withAlphaComponent(0.55);
            self.selectWindow?.windowLevel = .alert;
            self.selectWindow?.becomeKey();
        }
        self.selectWindow?.makeKeyAndVisible();
        self.selectWindow?.isHidden = false;
        
        self.frame = self.selectWindow!.bounds;
        self.selectWindow?.addSubview(self);
    }
    
    //TODO: 取消回调
    public func onBack(block:@escaping() -> Void) {
        self.cancelBlock = block;
    }
    
    //TODO: 选中确定回调
    public func onSelectBack(block:@escaping(NSDictionary,NSInteger) -> Void) {
        self.selectBlock = block;
    }
    
    //TODO: 隐藏窗口
    public func onHideInWindow() {
        if self.selectWindow != nil {
            self.selectWindow?.resignKey();
            self.selectWindow?.isHidden = true;
        }
    }
}

extension HDFixTypeSelectView: UITableViewDelegate,UITableViewDataSource {
    //MARK: 表的代理
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectFixType == .twoScroll {
            let tbTag = tableView.tag - 7000;
            if tbTag == 0 {
                return self.firstFixArr.count;
            }
            else if tbTag == 1 {
                return self.secondFixArr.count;
            }
        }
        else if self.selectFixType == .threeScroll {
            let tbTag = tableView.tag - 7000;
            if tbTag == 0 {
                return self.firstFixArr.count;
            }
            else if tbTag == 1 {
                return self.secondFixArr.count;
            }
            else if tbTag == 2 {
                return self.threeFixArr.count;
            }
        }
        return 0;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "HDFixTypeSelectView_ScrollView_Cell");
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "HDFixTypeSelectView_ScrollView_Cell");
            cell?.selectionStyle = .gray;
            
            let leftLb = self.onCreateUIForLabel(frame: CGRect(x: .scaleW(15.0), y: 0, width: cell!.width, height: cell!.height), title: "", font: UIFont.systemFont(ofSize: .scaleW(13.0), weight: .regular), align: .left, textColor: .DarkGrayTitle());
            leftLb.tag = 4500;
            cell?.contentView.addSubview(leftLb);
            
            let img = UIImage(named: "WO_Order_FixType_Select");
            let imgView = UIImageView(frame: CGRect(x: cell!.width - img!.size.width - .scaleW(60.0), y: (.scaleH(40.0) - img!.size.height)/2.0, width: img!.size.width, height: img!.size.height));
            imgView.backgroundColor = .clear;
            imgView.image = img;
            imgView.tag = 4600;
            cell?.contentView.addSubview(imgView);
        }
        
        let leftLb = cell?.contentView.viewWithTag(4500) as! UILabel;
        leftLb.textColor = .DarkGrayTitle();
        let imgView = cell?.contentView.viewWithTag(4600) as! UIImageView;
        imgView.isHidden = true;
        
        if self.selectFixType == .twoScroll {
            let tbTag = tableView.tag - 7000;
            if tbTag == 0 {
                if self.firstFixArr.count > indexPath.row {
                    let dic = self.firstFixArr.object(at: indexPath.row) as! NSDictionary;
                    leftLb.text = NSString.checkStringName(value: NSString(string: dic.object(forKey: "typeName") as! String)) as String;
                    
                    if self.firstSelectIndex != -1 && self.firstSelectIndex == indexPath.row {
                        imgView.isHidden = false;
                        leftLb.textColor = .BlueTextColor();
                    }
                }
            }
            else if tbTag == 1 {
                 if self.secondFixArr.count > indexPath.row {
                    let dic = self.secondFixArr.object(at: indexPath.row) as! NSDictionary;
                    leftLb.text = NSString.checkStringName(value: NSString(string: dic.object(forKey: "typeName") as! String)) as String;
                   
                    if self.secondSelectIndex != -1 && self.secondSelectIndex == indexPath.row {
                        imgView.isHidden = false;
                        leftLb.textColor = .BlueTextColor();
                    }
               }
            }
        }
        else if self.selectFixType == .threeScroll {
            let tbTag = tableView.tag - 7000;
            if tbTag == 0 {
                if self.firstFixArr.count > indexPath.row {
                    let dic = self.firstFixArr.object(at: indexPath.row) as! NSDictionary;
                    leftLb.text = NSString.checkStringName(value: NSString(string: dic.object(forKey: "typeName") as! String)) as String;
                    
                    if self.firstSelectIndex != -1 && self.firstSelectIndex == indexPath.row {
                        imgView.isHidden = false;
                        leftLb.textColor = .BlueTextColor();
                    }
                }
            }
            else if tbTag == 1 {
                 if self.secondFixArr.count > indexPath.row {
                    let dic = self.secondFixArr.object(at: indexPath.row) as! NSDictionary;
                    leftLb.text = NSString.checkStringName(value: NSString(string: dic.object(forKey: "typeName") as! String)) as String;
                   
                    if self.secondSelectIndex != -1 && self.secondSelectIndex == indexPath.row {
                        imgView.isHidden = false;
                        leftLb.textColor = .BlueTextColor();
                    }
               }
            }
            else if tbTag == 2 {
                 if self.threeFixArr.count > indexPath.row {
                    let dic = self.threeFixArr.object(at: indexPath.row) as! NSDictionary;
                    leftLb.text = NSString.checkStringName(value: NSString(string: dic.object(forKey: "typeName") as! String)) as String;
                   
                    if self.threeSelectIndex != -1 && self.threeSelectIndex == indexPath.row {
                        imgView.isHidden = false;
                        leftLb.textColor = .BlueTextColor();
                    }
               }
            }
        }
        
        return cell!;
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return .scaleH(40.0);
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.selectFixType == .twoScroll {
            let tbTag = tableView.tag - 7000;
            self.selectFixNum = tbTag + 1
            var dic = NSDictionary()
            if tbTag == 0 {
                //第一表选中后，其余2个表选中清空
                self.firstSelectIndex = indexPath.row;
                self.secondSelectIndex = -1;
                self.threeSelectIndex = -1;
                tableView.reloadData()
                
                if self.firstFixArr.count > 0 {
                    dic = self.firstFixArr.object(at: self.firstSelectIndex) as! NSDictionary;
                    
                    let titleName = NSString.checkStringName(value: NSString(string: dic.object(forKey: "typeName") as! String)) as NSString;
                    let lastLb = self.bgView?.viewWithTag(6000) as! UILabel;
                    lastLb.text = titleName as String;
                    let titleWidth = self.onGetTitleWidthFromText(lb: lastLb, isWidth: true);
                    lastLb.width = titleWidth;
                }
                
                //添加新的标题
                let nextLb = self.onAddSubTitleLb(currentTg: 1);
                let lastLb = self.bgView?.viewWithTag(6002);
                if lastLb != nil {
                    let lastLabel = lastLb as! UILabel;
                    lastLabel.left = nextLb.right + .scaleW(30.0);
                    lastLabel.text = "请选择服务细则";
                    let titleWidth = self.onGetTitleWidthFromText(lb: lastLabel, isWidth: true);
                    lastLabel.width = titleWidth;
                }
            }
            else if tbTag == 1 {
                //第2表选中后，其余1个表选中清空
                self.secondSelectIndex = indexPath.row;
                self.threeSelectIndex = -1;
                tableView.reloadData();
                
                if self.secondFixArr.count > 0 {
                    dic = self.secondFixArr.object(at: self.secondSelectIndex) as! NSDictionary;
                    
                    let titleName = NSString.checkStringName(value: NSString(string: dic.object(forKey: "typeName") as! String)) as NSString;
                    let lastLb = self.bgView?.viewWithTag(6001) as! UILabel;
                    lastLb.text = titleName as String;
                    let titleWidth = self.onGetTitleWidthFromText(lb: lastLb, isWidth: true);
                    lastLb.width = titleWidth;
                }
            }
            if self.delegate != nil {
                self.delegate?.fixTypeSelectView(selectView: self, selectIndex: tbTag, selectDic: dic)
            }
        }
        else if self.selectFixType == .threeScroll {
            let tbTag = tableView.tag - 7000;
            self.selectFixNum = tbTag + 1
            var dic = NSDictionary()
            if tbTag == 0 {
                //第一表选中后，其余2个表选中清空
                self.firstSelectIndex = indexPath.row;
                self.secondSelectIndex = -1;
                self.threeSelectIndex = -1;
                tableView.reloadData()
                
                if self.firstFixArr.count > 0 {
                    dic = self.firstFixArr.object(at: self.firstSelectIndex) as! NSDictionary;
                    
                    let titleName = NSString.checkStringName(value: NSString(string: dic.object(forKey: "typeName") as! String)) as NSString;
                    let lastLb = self.bgView?.viewWithTag(6000) as! UILabel;
                    lastLb.text = titleName as String;
                    let titleWidth = self.onGetTitleWidthFromText(lb: lastLb, isWidth: true);
                    lastLb.width = titleWidth;
                }
                
                //添加新的标题
                let nextLb = self.onAddSubTitleLb(currentTg: 1);
                let lastLb = self.bgView?.viewWithTag(6002);
                if lastLb != nil {
                    let lastLabel = lastLb as! UILabel;
                    lastLabel.left = nextLb.right + .scaleW(30.0);
                    lastLabel.text = "请选择服务细则";
                    let titleWidth = self.onGetTitleWidthFromText(lb: lastLabel, isWidth: true);
                    lastLabel.width = titleWidth;
                }
            }
            else if tbTag == 1 {
                //第2表选中后，其余1个表选中清空
                self.secondSelectIndex = indexPath.row;
                self.threeSelectIndex = -1;
                tableView.reloadData();
                
                if self.secondFixArr.count > 0 {
                    dic = self.secondFixArr.object(at: self.secondSelectIndex) as! NSDictionary;
                    
                    let titleName = NSString.checkStringName(value: NSString(string: dic.object(forKey: "typeName") as! String)) as NSString;
                    let lastLb = self.bgView?.viewWithTag(6001) as! UILabel;
                    lastLb.text = titleName as String;
                    let titleWidth = self.onGetTitleWidthFromText(lb: lastLb, isWidth: true);
                    lastLb.width = titleWidth;
                }
                
                //添加新的标题
                let nextLb = self.onAddSubTitleLb(currentTg: 2);
                let lastLb = self.bgView?.viewWithTag(6001) as! UILabel;
                if nextLb.width > (self.width - lastLb.right - .scaleW(30.0)) {
                    nextLb.width = (self.width - lastLb.right - .scaleW(30.0));
                }
            }
            else if tbTag == 2 {
                
                //第3表选中后
                self.threeSelectIndex = indexPath.row;
                tableView.reloadData();
                
                if self.threeFixArr.count > 0 {
                    dic = self.threeFixArr.object(at: self.threeSelectIndex) as! NSDictionary;
                    
                    let titleName = NSString.checkStringName(value: NSString(string: dic.object(forKey: "typeName") as! String)) as NSString;
                    let lastLb = self.bgView?.viewWithTag(6002) as! UILabel;
                    lastLb.text = titleName as String;
                    let titleWidth = self.onGetTitleWidthFromText(lb: lastLb, isWidth: true);
                    lastLb.width = titleWidth;
                    
                    self.mainLineView?.frame = CGRect(x: lastLb.centerX - self.mainLineView!.width / 2.0, y: lastLb.bottom-1, width: self.mainLineView!.width, height: self.mainLineView!.height);
                }
            }
            if self.delegate != nil {
                self.delegate?.fixTypeSelectView(selectView: self, selectIndex: tbTag, selectDic: dic)
            }
        }
    }
}

extension HDFixTypeSelectView: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.mainScrollView {
            let curTg = Int(scrollView.contentOffset.x / scrollView.width);
            let label = self.bgView?.viewWithTag((6000+curTg));
            UIView.animate(withDuration: 0.15) {
                self.mainLineView?.frame = CGRect(x: label!.centerX - self.mainLineView!.width / 2.0, y: self.mainLineView!.top, width: self.mainLineView!.width, height: self.mainLineView!.height);
            };
        }
    }
}
