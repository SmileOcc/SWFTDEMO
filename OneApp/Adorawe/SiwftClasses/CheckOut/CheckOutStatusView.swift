//
//  CheckOutStatusView.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/8.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit


///> Address > Shipping > Payment  状态组件
class CheckOutStatusView: UIView {

    ///从0开始
    @objc var currentStep:NSNumber?{
        didSet{
            if let currentStep = currentStep as? Int {
                if currentStep >= self.statesItems!.count{
                    return
                }
                for i in 0..<currentStep {
                    self.statesItems?[i].process = .finished
                }
                self.statesItems?[currentStep].process = .processing
            }
        }
    }
    
    private var states = ["Address","help_Shipping","pay_PAYMENT"]
    private var statesItems:[ProgressItem]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setupViews(){
        backgroundColor = .white
        let stackView = UIStackView()
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.centerX.equalTo(self.snp.centerX)
        }
        
        statesItems = states.map({ title in
            let item =  ProgressItem(frame: .zero)
            stackView.addArrangedSubview(item)
            item.stateText = STLLocalizedString_(title)
            item.process = .pending
            return item
        })

    }

}

enum ProgressStatus{
    case processing
    case finished
    case pending
}

///每一项状态
class ProgressItem:UIView{
    
    var process:ProgressStatus = .pending{
        didSet{
            statusLabel.textColor = process == .processing ? OSSVThemesColors.col_000000(1) : OSSVThemesColors.col_000000(0.5)
            switch process {
            case .processing:
                statusImage.image = UIImage(named: "state_on")
            case .finished:
                statusImage.image = UIImage(named: "state_done")
            case .pending:
                statusImage.image = UIImage(named: "state_off")
            }
        }
    }
    
    var stateText:String?{
        didSet{
            statusLabel.text = stateText
        }
    }
    
    private weak var statusImage:UIImageView!
    private weak var statusLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setupViews(){
//        backgroundColor = .systemPink
        let statusImage = UIImageView()
        statusImage.image = UIImage(named: "state_off")
        addSubview(statusImage)
        statusImage.convertUIWithARLanguage()
        
        self.statusImage = statusImage
        
        let statusLabel = UILabel()
        statusLabel.setTextWidthPriorityMax()
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        addSubview(statusLabel)
        
        self.statusLabel = statusLabel
        
        statusImage.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.leading.equalTo(0)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(statusImage.snp.trailing).offset(10)
            make.trailing.equalTo(-10)
            make.centerY.equalTo(self.snp.centerY)
        }
    }
    
}
