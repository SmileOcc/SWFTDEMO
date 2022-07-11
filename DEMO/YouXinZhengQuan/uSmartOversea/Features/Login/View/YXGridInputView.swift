//
//  YXGridInputView.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXGridInputView: UIView, UITextFieldDelegate {
    
    var textLabArr: [UILabel] = []
    var circularArr: [UILabel] = []
    var borderArr: [UIView] = []
    var textArr: [String] = []
//    override var width: CGFloat {return 0}
    var viewWidth: CGFloat = 0
    var gridHeight: CGFloat = 0
    var timer = Timer()
    var isDel = false
    var textFieldEnable = true
    // 是否加密（加密就显示边框)
    var isSecure = true
    // 是否显示边框
    var isShowBorder = false
    
    var normalColor = QMUITheme().separatorLineColor()
    var seletedColor = QMUITheme().themeTextColor() {
        didSet {
            for x in 0..<self.borderArr.count {
                let borderView:UIView = self.borderArr[x]
                if x == 0  {
                    borderView.layer.borderColor = self.seletedColor.cgColor
                }else {
                    borderView.layer.borderColor = self.normalColor.cgColor
                }
            }
        }
    }
    
    var textField: YXTextField = {
        let textField = YXTextField()
        textField.banAction = true
        textField.keyboardType = .numberPad
        textField.tintColor = UIColor.clear
        textField.textColor = UIColor.clear
        return textField
    }()
    
    convenience init(gridWidth: CGFloat, viewWidth:CGFloat, isSecure: Bool) {
        self.init(frame:.zero)
        self.width = gridWidth;
        self.viewWidth = viewWidth;
        self.isSecure = isSecure
        initUI()
    }
    
    //设置了宽高
    convenience init(gridWidth: CGFloat, gridHeight: CGFloat,  viewWidth:CGFloat, isSecure: Bool, isShowBorder: Bool) {
        self.init(frame:.zero)
        self.width = gridWidth;
        self.gridHeight = gridHeight;
        self.viewWidth = viewWidth;
        self.isSecure = isSecure
        self.isShowBorder = isShowBorder
        initUI()
    }

    func initUI() {
        
        self.textField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tapGesture)
        
        textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        self.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self)
        }
        
        for x in 0...5 {
          
            let view = UIView()
            view.layer.borderWidth = 1
            if x == 0 {
                view.layer.borderColor = self.seletedColor.cgColor
            }else {
                view.layer.borderColor = self.normalColor.cgColor
            }
            if isSecure || isShowBorder {
                view.layer.cornerRadius = 6
                view.layer.masksToBounds = true
            }
            self.borderArr.append(view)
            self.addSubview(view)
            
            let lab = UILabel()
            lab.font = .systemFont(ofSize: 30)
            lab.textAlignment = .center
            lab.isUserInteractionEnabled = true
            self.textLabArr.append(lab)
            self.addSubview(lab)
            
            let space = (self.viewWidth - self.width * 6)/5
            lab.snp.makeConstraints { (make) in
                make.width.height.equalTo(self.width - 3)
                make.top.equalTo(self)
                make.left.equalTo((self.width+space)*CGFloat(x))
            }
            
            view.snp.makeConstraints { (make) in
                if isSecure || isShowBorder {
                    if self.gridHeight > 0 {//设置了宽高
                        make.width.equalTo(self.width)
                        make.height.equalTo(self.gridHeight)
                    } else {
                        make.width.height.equalTo(self.width)
                    }
                    make.center.equalTo(lab)
                }else {
                    make.width.equalTo(self.width)
                    make.height.equalTo(1)
                    make.bottom.equalTo(self)
                    make.left.equalTo(lab)
                    
                }
            }
            
            let circularLab = UILabel()
            circularLab.text = "*"
            circularLab.font = UIFont.systemFont(ofSize: 30)
            circularLab.isHidden = true
            self.addSubview(circularLab)
            circularLab.snp.makeConstraints { (make) in
                make.centerX.equalTo(lab)
                make.centerY.equalTo(lab).offset(4)
            }
            self.circularArr.append(circularLab)
            
        }
    }

    @objc func tapAction() {
        self.textField.becomeFirstResponder()
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if self.textArr.count > textField.text!.count {
            self.isDel = true
        }else {
            self.isDel = false
        }
        
        self.textArr.removeAll()
        
        for x in 0..<textField.text!.count {
            let str = textField.text!
            let index1 = str.index(str.startIndex, offsetBy: x)
            let index2 = str.index(str.startIndex, offsetBy: x+1)
            let tempString = str[index1..<index2]
            self.textArr.append(String(tempString))
        }
        
        for x in 0..<self.textLabArr.count {
            let label:UILabel = self.textLabArr[x]
            let borderView:UIView = self.borderArr[x]
            if x < self.textArr.count  {
                label.text = self.textArr[x]
            }else {
                label.text = nil
            }
            
            if x == self.textArr.count  {
                borderView.layer.borderColor = self.seletedColor.cgColor
            }else {
                borderView.layer.borderColor = self.normalColor.cgColor
            }
        }
        
        if isSecure {
            timer.fireDate = Date.distantFuture
            timer.invalidate()
            self.setCircular()
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if !self.textFieldEnable {
            return false
        }
        
        if string.count == 0 {
            return true
        } else if textField.text!.count >= 6 {
            textField.text = String(textField.text!.prefix(6))
            return false
        }
        return true
    }
    //清空 验证码
    func clearText() {
        self.textArr.removeAll()
        self.textField.text = ""
        for i in 0...5 {
            let c = self.circularArr[i]
            let lab = self.textLabArr[i]
            let b = self.borderArr[i]
            if i == 0 {
                b.layer.borderColor = self.seletedColor.cgColor
            }else {
                b.layer.borderColor = self.normalColor.cgColor
            }
            c.isHidden = true
            lab.isHidden = false
            lab.text = ""
        }
    }
    
    func setCircular() {
        if !self.isDel {
            let c = self.circularArr[textArr.count-1]
            let lab = self.textLabArr[textArr.count-1]
            c.isHidden = true
            lab.isHidden = false
        }
        
        if textArr.count > 1 {
            let v: UILabel? = circularArr[textArr.count - 2]
            let lab: UILabel? = textLabArr[textArr.count - 2]
            v?.isHidden = false
            lab?.isHidden = true
        }
        
        if textArr.count < 6 {
            let v: UILabel? = circularArr[textArr.count]
            let lab: UILabel? = textLabArr[textArr.count]
            v?.isHidden = true
            lab?.isHidden = false
        }

    }
    
    @objc func timerAction() {
        var i = 0
        while textArr.count > i {
            let v: UILabel? = circularArr[i]
            let lab: UILabel? = textLabArr[i]
            v?.isHidden = false
            lab?.isHidden = true
            i += 1
        }
    }
    
    deinit {
        timer.fireDate = Date.distantFuture
        timer.invalidate()
    }
}

