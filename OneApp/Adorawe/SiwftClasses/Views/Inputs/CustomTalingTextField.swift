//
//  CustomTalingTextField.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class CustomTalingTextField: NormalInputFiled {
    
    var isHiddingTralling:Bool = true{
        didSet{
            traillingView?.isHidden = isHiddingTralling
            inputContainer?.snp.remakeConstraints({ make in
                make.height.equalTo(35)
                make.leading.equalTo(self)
                make.top.equalTo(floatingLbl!.snp.bottom).offset(0)
                make.bottom.equalTo(messageView!.snp.top).offset(-5)
                if isHiddingTralling{
                    make.trailing.equalTo(self.snp.trailing)
                }else{
                    make.trailing.equalTo(traillingView!.snp.leading).offset(-4)
                }
            })
        }
    }

    weak var traillingView:UIView?
    
    override func buildInputs() {
        super.buildInputs()
        let traillingView = UIView()
        addSubview(traillingView)
        self.traillingView = traillingView
        
        traillingView.snp.makeConstraints { make in
            make.trailing.equalTo(self).offset(-14)
            make.centerY.equalTo(inputContainer!.snp.centerY)
            make.height.equalTo(36)
        }
        inputContainer?.snp.remakeConstraints{ make in
            make.height.equalTo(35)
            make.leading.equalTo(self)
            make.trailing.equalTo(traillingView.snp.leading).offset(-4)
            make.top.equalTo(floatingLbl!.snp.bottom).offset(0)
            make.bottom.equalTo(messageView!.snp.top).offset(0)
        }
    }

}
