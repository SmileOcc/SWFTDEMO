//
//  UnderLineMessageView.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

///输入框下划线，消息
class UnderLineMessageView: UIView {

    var messageColor:UIColor?{
        didSet{
            messageLbl?.textColor = messageColor
            lineView?.backgroundColor = messageColor
        }
    }
    var attributeMessage:NSAttributedString?{
        didSet{
            messageLbl?.attributedText = attributeMessage
            updateMessageHeight()
        }
    }
    var message:String?{
        didSet{
            messageLbl?.text = message
            updateMessageHeight()
        }
    }
    
    weak var messageLbl:UILabel?
    weak var lineView:UIView?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        let lineView = UIView(frame: .zero)
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(self.snp.top)
            make.height.equalTo(0.5)
        }
        self.lineView = lineView
        lineView.backgroundColor = OSSVThemesColors.col_CCCCCC()
        
        let messageLbl = UILabel()
        addSubview(messageLbl)
        messageLbl.numberOfLines = 0
        messageLbl.lineBreakMode = .byCharWrapping
        self.messageLbl = messageLbl
        messageLbl.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(2)
            make.leading.trailing.equalTo(self)
            make.height.equalTo(12)
            make.bottom.equalTo(self.snp.bottom)
        }
        
        messageLbl.font = UIFont.systemFont(ofSize: 10)
        updateMessageHeight()
        
        messageLbl.textAlignment = OSSVSystemsConfigsUtils.isRightToLeftShow() ? .right : .left
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateMessageHeight() {
        var messageH:CGFloat = 0
        if( !(message?.isEmpty ?? true) || (attributeMessage?.length ?? 0) > 0 ){
            let h = messageLbl?.sizeThatFits(CGSize(width: bounds.width, height: .infinity)).height
            messageH = max(h ?? 0, 12)
        }else{
            messageH = 0
        }
        messageLbl?.snp.updateConstraints { make in
            make.height.equalTo(messageH)
        }
    }
    
}
