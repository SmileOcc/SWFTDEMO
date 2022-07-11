//
//  AutoCompleteView.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/10.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON
import RxSwift
import RxCocoa
///google 自动匹配View
class AutoCompleteView: UIView {
    
    let selectedObj = PublishSubject<JSON?>()
    
    var predications : [JSON]?{
        didSet{
            tableView.reloadData()
        }
    }
    
    weak var tableView:UITableView!

    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        let borderView = BorderView()
        addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0))
        }
        borderView.borderColor = OSSVThemesColors.col_E1E1E1()
        borderView.borderWidth = 1
        let tableView = UITableView()
        addSubview(tableView)
        let switchManual = UIView()
        addSubview(switchManual)
        switchManual.snp.makeConstraints { make in
            make.leading.equalTo(2)
            make.trailing.equalTo(-2)
            make.bottom.equalTo(-2)
            make.height.equalTo(26)
        }
        tableView.snp.makeConstraints { make in
            make.leading.equalTo(2)
            make.trailing.equalTo(-2)
            make.top.equalTo(2)
            make.bottom.equalTo(switchManual.snp.top)
        }
        tableView.flashScrollIndicators()
        self.tableView = tableView
        
        switchManual.backgroundColor = OSSVThemesColors.col_F2F2F2()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AutoCompletedCell.self, forCellReuseIdentifier: "AutoCompletedCell")
    }

}

extension AutoCompleteView:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predications?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompletedCell", for: indexPath)
        if let data = predications?[indexPath.row,true],
           let description = data["description"].string,
           let matched_substrings = data["matched_substrings"].array,
           let cell = cell as? AutoCompletedCell{
            let attr = NSMutableAttributedString(string: description)
            attr.yy_font = UIFont.systemFont(ofSize: 14)
            attr.yy_color = OSSVThemesColors.col_000000(1)
            for item in matched_substrings {
                if let offset = item["offset"].int,
                   let length = item["length"].int{
                    attr.yy_setColor(OSSVThemesColors.col_000000(0.5), range: NSRange(location: offset, length: length))
                }
                
            }
            cell.titleLbl.attributedText = attr
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let obj = predications?[indexPath.row,true]
        selectedObj.onNext(obj)
    }
}

//MARK: -cell

class AutoCompletedCell:UITableViewCell{
    
    weak var titleLbl:UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let titLBL = UILabel()
        contentView.addSubview(titLBL)
        self.titleLbl = titLBL
        
        let imag = UIImageView()
        imag.image = UIImage(named: "arrow_beveled")
        contentView.addSubview(imag)
        
        imag.snp.makeConstraints { make in
            make.width.height.equalTo(18)
            make.trailing.equalTo(-16)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        titLBL.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.trailing.equalTo(imag.snp.leading).offset(-12)
            make.centerY.equalTo(contentView.snp.centerY)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
