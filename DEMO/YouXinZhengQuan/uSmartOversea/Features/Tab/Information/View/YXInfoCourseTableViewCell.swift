//
//  YXInfoCourseTableViewCell.swift
//  uSmartOversea
//
//  Created by Mac on 2020/3/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

enum YXInfoCourseCellType: Int {
    case all    = 1 //全部课程
    case my     = 2 //我的课程
}

class YXInfoCourseTableViewCell: UITableViewCell {
    
    var model: YXInfoCourseSubModel? {
        didSet {
            if let model = self.model {
                if let courseCover = model.courseCover, let coverURL = URL(string: courseCover) {
                    let transformer = SDImageResizingTransformer(size: CGSize(width: INFOMATION_CELL_IMAGE_VIEW_WIDTH * UIScreen.main.scale, height: INFOMATION_CELL_IMAGE_VIEW_HEIGHT * UIScreen.main.scale), scaleMode: .aspectFill)
                    
                    let placeholderImage = UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "#EEEEEE"), size: CGSize.init(width: 8, height: 2), cornerRadius: 0)
                    
                    leftImgView.sd_setImage(with: coverURL, placeholderImage: placeholderImage, options: [], context: [SDWebImageContextOption.imageTransformer: transformer])
                }
                titleLab.text = model.courseTitle
                descLab.text = model.courseBrief
                
            }
        }
    }
    
    var type: YXInfoCourseCellType = .all {
        didSet {
            if self.type == .all {
                leftImgView.snp.updateConstraints { (make) in
                    make.top.equalToSuperview().offset(12)
                }
                titleLab.snp.updateConstraints { (make) in
                    make.top.equalToSuperview().offset(12)
                }
                
            }
            else if self.type == .my {
                leftImgView.snp.updateConstraints { (make) in
                    make.top.equalToSuperview().offset(14)
                }
                titleLab.snp.updateConstraints { (make) in
                    make.top.equalToSuperview().offset(14)
                }
                
                contentView.addSubview(deleteBtn)
                deleteBtn.snp.makeConstraints { (make) in
                    make.left.equalTo(leftImgView.snp.right).offset(14)
                    make.top.equalTo(descLab.snp.bottom).offset(-2)
                }
            }
        }
    }
    
    var deleteBlock:((YXInfoCourseSubModel)->())?
    
    lazy var leftImgView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 4
        iv.layer.masksToBounds = true
        return iv
    }()
    
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.numberOfLines = 1
        return lab
    }()
    lazy var descLab: UILabel = {
        let lab = UILabel()
        lab.textColor = QMUITheme().textColorLevel1().qmui_color(withAlpha: 0.65, backgroundColor: .white)
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.numberOfLines = 2
        return lab
    }()
    
    private lazy var deleteBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(QMUITheme().themeTintColor(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        btn.setTitle(YXLanguageUtility.kLang(key: "common_delete"), for: .normal)
        
        btn.rx.tap.subscribe(onNext: {
            [weak self] (sender) in
            guard let `self` = self, let model = self.model else { return }
            if let block = self.deleteBlock {
                block(model)
            }
        }).disposed(by: rx.disposeBag)
        
        return btn
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        contentView.addSubview(leftImgView)
        leftImgView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(12)
            make.width.equalTo(109)
            make.height.equalTo(69)
        }
        
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(leftImgView.snp.right).offset(14)
            make.right.equalToSuperview().offset(-12)
        }
        contentView.addSubview(descLab)
        descLab.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom).offset(4)
            make.left.equalTo(leftImgView.snp.right).offset(14)
            make.right.equalToSuperview().offset(-12)
        }
        
        let line = UIView()
        line.backgroundColor = QMUITheme().textColorLevel1().qmui_color(withAlpha: 0.05, backgroundColor: .white)
        contentView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview()
        }
    }


}
