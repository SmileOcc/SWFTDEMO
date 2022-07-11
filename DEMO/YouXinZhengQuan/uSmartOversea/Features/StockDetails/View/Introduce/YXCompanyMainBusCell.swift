//
//  YXCompanyMainBusCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXCompanyMainBusCell: UITableViewCell {

    var selecIndexCallBack: (() -> ())?
    
    var model: YXStockIntroduceModel? {
        didSet {
            self.mainView.model = model
        }
    }
    
    var HSModel: YXHSStockIntroduceModel? {
        didSet {
            self.mainView.HSModel = HSModel
        }
    }
    
    var configModel: YXStockIntroduceConfigModel? {
        didSet {
            self.mainView.configModel = configModel ?? YXStockIntroduceConfigModel.init()
        }
    }
    
    var mainView = YXStockCompanyMainBusView.init()
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        self.selectionStyle = .none
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.mainView.selecIndexCallBack = { [weak self] in
            self?.selecIndexCallBack?()
        }
    }
}
