//
//  YXStockSTRankCell.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2019/4/1.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit
import Rswift

class YXStockSTRankCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    fileprivate var linePatternLayer: CALayer?
    
    
    func reloadData() {
        tableView.reloadData()
        titleLabel.text = "港股漲跌"
    }
    
    override func draw(_ rect: CGRect) {
        if  linePatternLayer == nil {
            linePatternLayer = YXDrawHelper.drawDashLine(superView: backView, strokeColor: (QMUICMI().dashLineColor(withAlpha: 0.05))!)
        }
    }
    //MARK: initialization Method
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initializeViews()
        
    }
    
    func initializeViews() {
        self.contentView.addSubview(belowView)
        
        let margin: CGFloat = 14
        let innerMargin: CGFloat = 12
        belowView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        belowView.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        backView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(innerMargin)
            make.right.lessThanOrEqualToSuperview().offset(-20)
        }
        
        backView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-innerMargin)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.width.equalTo(7)
            make.height.equalTo(12)
        }
        
        backView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(46)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = 66
        size.height += kCellHeight * 3
        
        return size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var belowView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = QMUICMI().themeBackgroundColor().cgColor
        view.layer.cornerRadius = 8
        view.layer.shadowColor = QMUICMI().shadowColor(withAlpha: 0.5).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 10
        return view
    }()
    
    lazy var backView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = QMUICMI().themeBackgroundColor().cgColor
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.dinProMedium(size: 16)
        label.textColor = QMUICMI().themeTextColor()
        label.textAlignment = .left
        return label
    }()
    
    lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIView.ContentMode.scaleToFill
        imageView.image = UIImage(named: "common_arrow")
        return imageView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(YXStockSTNumberCell.self, forCellReuseIdentifier: "YXStockSTNumberCell")
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderHeight = 0
        return tableView
    }()
    
}

extension YXStockSTRankCell: UITableViewDelegate, UITableViewDataSource {
    
    var kCellHeight: CGFloat {
        return 59.0
    }
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YXStockSTNumberCell", for: indexPath) as! YXStockSTNumberCell
        cell.nameLabel.text = "小米集团"
        cell.codeLabel.text = "01810.HK"
        cell.priceLabel.text = "0.85"
        cell.quoteChangeLabel.text = "-1.91%%"
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeight
    }
    
    
}
