//
//  OSSVAccountHeadServicTableView.swift
// XStarlinkProject
//
//  Created by odd on 2021/8/5.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class OSSVAccountHeadServicTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    typealias selectTempBlock = (_ index:NSInteger,_ model: OSSVAccountsMenuItemsModel)->Void
    @objc var didSelectBlock: selectTempBlock?
    
    var datas: NSMutableArray = NSMutableArray.init()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: STLAccountServicesTableCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(STLAccountServicesTableCell.self), for: indexPath) as! STLAccountServicesTableCell
        
        if self.datas.count > indexPath.row {
            if let model: OSSVAccountsMenuItemsModel = self.datas[indexPath.row] as? OSSVAccountsMenuItemsModel {
                cell.model = model
            }
            cell.lineView.isHidden = indexPath.row == self.datas.count - 1 ? true : false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: .screenWidth - 24, height: 40))
        
        let titleLab: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 12, width: .screenWidth - 24 - 28, height: 30))
        headerView.addSubview(titleLab)

        titleLab.snp.makeConstraints { make in
            make.leading.equalTo(headerView.snp.leading).offset(14)
            make.top.equalTo(headerView.snp.top).offset(14)
        }
        
        titleLab.text = STLLocalizedString_("More_services");
        titleLab.textColor = OSSVThemesColors.col_0D0D0D()
        titleLab.font = UIFont.boldSystemFont(ofSize: 14)
        if OSSVSystemsConfigsUtils.isRightToLeftShow() {
            titleLab.textAlignment = NSTextAlignment.right
        } else {
            titleLab.textAlignment = NSTextAlignment.left
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.datas.count > indexPath.row {
            if let model: OSSVAccountsMenuItemsModel = self.datas[indexPath.row] as? OSSVAccountsMenuItemsModel {
                if (self.didSelectBlock != nil) {
                    self.didSelectBlock!(indexPath.row, model)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    @objc func updateDatas(datas: NSArray) {
        self.datas.removeAllObjects()
        
        if STLJudgeNSArray(datas) {
            self.datas.addObjects(from: datas as! [Any])
        }
        self.reloadData()
    }
    

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .grouped)
        
        self.delegate = self
        self.dataSource = self
        self.isScrollEnabled = false
        self.register(STLAccountServicesTableCell.self, forCellReuseIdentifier: NSStringFromClass(STLAccountServicesTableCell.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class STLAccountServicesTableCell: UITableViewCell {
    
    var imgView: UIImageView = {
        let imagV = UIImageView.init()
        return imagV
    }()
    
    var titleLab: UILabel = {
        let lab = UILabel.init()
        lab.textColor = OSSVThemesColors.col_0D0D0D()
        lab.font = UIFont.systemFont(ofSize: 14)
        if OSSVSystemsConfigsUtils.isRightToLeftShow() {
            lab.textAlignment = NSTextAlignment.right
        } else {
            lab.textAlignment = NSTextAlignment.left
        }
        return lab
    }()
    
    var lineView: UIView = {
        let line = UIView.init()
        line.backgroundColor = OSSVThemesColors.col_EEEEEE()
        return line
    }()
    
    var arrowImgView: UIImageView = {
        let imgV = UIImageView.init()
        imgV.image = UIImage.init(named: "account_arrow")
        imgV.convertUIWithARLanguage()

        return imgV
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = SelectionStyle.none
        self.contentView.addSubview(imgView)
        self.contentView.addSubview(titleLab)
        self.contentView.addSubview(lineView)
        self.contentView.addSubview(self.arrowImgView)

        self.imgView.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView.snp.leading).offset(14)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
        self.titleLab.snp.makeConstraints { make in
            make.leading.equalTo(self.imgView.snp.trailing).offset(12)
            make.centerY.equalTo(self.imgView)
        }
        
        self.lineView.snp.makeConstraints { make in
            make.bottom.equalTo(self.contentView.snp.bottom)
            make.leading.equalTo(self.contentView.snp.leading).offset(12)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-12)
            make.height.equalTo(0.5)
        }
        
        self.arrowImgView.snp.makeConstraints { make in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-14)
            make.centerY.equalTo(self.imgView.snp.centerY)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var model:OSSVAccountsMenuItemsModel? {
        didSet{
            self.imgView.image = UIImage.init(named: STLToString(model?.itemImage))
            self.titleLab.text = STLToString(model?.itemTitle)
        }
    }
    
}
