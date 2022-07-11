//
//  AddressSelectView.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/13.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON
import RxSwift

class AddressSelectView: UIControl {
    let disposeBag = DisposeBag()
    
    lazy var addressPub:PublishSubject<JSON?> = {
        let pub = PublishSubject<JSON?>()
        pub.subscribe(onNext:{[weak self] data in
            let firstname = data?["first_name"].string
            let lastname = data?["last_name"].string
            let nameText = (firstname ?? "") + " " + (lastname ?? "")
            self?.nameLbl.text = nameText.trimmingCharacters(in: .whitespaces)
            self?.phoneLbl.text = data?["phone"].string
            
            let email = data?["email"].string
            let zipCode = data?["zip"].string
            let zipText = (zipCode ?? "") + " " + (email ?? "")
            self?.emailLine.text = zipText.trimmingCharacters(in: .whitespaces)
            
            let country = data?["country"].string ?? ""
            let state = data?["state"].string ?? ""
            let city = data?["city"].string ?? ""
            let area = data?["area"].string ?? ""
            
            var countryText = city + ", " + state + ", " + country
            if area.count > 0{
                countryText = area + ", " + countryText
            }
            
            self?.countryLine.text = countryText
            
            let street = data?["street"].string ?? ""
            let streetMore = data?["streetmore"].string ?? ""
            let streetText = streetMore + " " + street
            self?.streetLine.text = streetText.trimmingCharacters(in: .whitespaces)
            
        }).disposed(by: disposeBag)
        return pub
    }()
    
    ///姓名
    weak var nameLbl:UILabel!
    ///电话
    weak var phoneLbl:UILabel!
    ///街道
    weak var streetLine:UILabel!
    ///国家省份城市
    weak var countryLine:UILabel!
    ///邮编邮箱
    weak var emailLine:UILabel!


    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        
        let locationImg = UIImageView()
        locationImg.image = UIImage(named: "logistics_address")
        addSubview(locationImg)
        locationImg.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalTo(self.snp.centerY)
            make.leading.equalTo(15)
        }
        
        let arrImg = UIImageView(image:  UIImage(named: "address_arr"))
        addSubview(arrImg)
        arrImg.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.centerY.equalTo(self.snp.centerY)
            make.trailing.equalTo(-15)
        }
        
        let nameLbl = UILabel()
        nameLbl.font = UIFont.boldSystemFont(ofSize: 12)
        nameLbl.textColor = OSSVThemesColors.col_000000(0.5)
        let phoneLbl = UILabel()
        phoneLbl.font = UIFont.boldSystemFont(ofSize: 12)
        phoneLbl.textColor = OSSVThemesColors.col_000000(0.5)
        addSubview(nameLbl)
        addSubview(phoneLbl)
        self.nameLbl = nameLbl
        self.phoneLbl = phoneLbl
        nameLbl.snp.makeConstraints { make in
            make.leading.equalTo(54)
            make.bottom.equalTo(-18)
            make.height.equalTo(14)
        }
        phoneLbl.snp.makeConstraints { make in
            make.trailing.equalTo(-38)
            make.bottom.equalTo(-18)
            make.height.equalTo(14)
        }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(54)
            make.trailing.equalTo(-38)
            make.top.equalTo(15)
            make.bottom.equalTo(nameLbl.snp.top).offset(-8)
        }
        
        let streetLine = UILabel()
        streetLine.numberOfLines = 0
        streetLine.font = UIFont.boldSystemFont(ofSize: 14)
        streetLine.textColor = OSSVThemesColors.col_000000(1)
        stackView.addArrangedSubview(streetLine)
        self.streetLine = streetLine
        
        let countryLine = UILabel()
        countryLine.numberOfLines = 0
        countryLine.font = UIFont.systemFont(ofSize: 12)
        countryLine.textColor = OSSVThemesColors.col_000000(0.5)
        stackView.addArrangedSubview(countryLine)
        self.countryLine = countryLine
        
        let emailLine = UILabel()
        emailLine.font = UIFont.systemFont(ofSize: 12)
        emailLine.textColor = OSSVThemesColors.col_000000(0.5)
        stackView.addArrangedSubview(emailLine)
        self.emailLine = emailLine
    }
}
