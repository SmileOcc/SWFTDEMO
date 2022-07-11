//
//  Passport.swift
//  NFCPassportReaderApp
//
//  Created by Mac on 2019/10/17.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
//import NFCPassportReader

public struct Passport {
    public var documentType : String
    public var documentSubType : String
    public var personalNumber : String
    public var documentNumber : String
    public var issuingAuthority : String
    public var documentExpiryDate : String
    public var firstName : String
    public var lastName : String
    public var dateOfBirth : String
    public var gender : String
    public var nationality : String
    public var image : UIImage
    
    public var passportSigned : Bool = false    //护照是否签名正确
    public var passportDataValid : Bool = false //护照数据是否有效
    public var errors : [Error] = []
    
    public init( fromNFCPassportModel model : NFCPassportModel ) {
        self.image = model.passportImage ?? UIImage() //UIImage(named:"head")!
        
        let elements = model.passportDataElements ?? [:]
        
        let type = elements["5F03"] //值为：PO //类型
        documentType = type?[0] ?? "?"      //文档类型
        documentSubType = type?[1] ?? "?"   //文档子类型
        
        issuingAuthority = elements["5F28"] ?? "?" //发行机关
        documentNumber = (elements["5A"] ?? "?").replacingOccurrences(of: "<", with: "" ) //护照编号
        nationality = elements["5F2C"] ?? "?"   //国籍
        dateOfBirth = elements["5F57"]  ?? "?"  //出生日期
        gender = elements["5F35"] ?? "?"        //性别
        documentExpiryDate = elements["59"] ?? "?"  //过期日期
        personalNumber = (elements["53"] ?? "?").replacingOccurrences(of: "<", with: "" )   //个人编号
        
        let names = (elements["5B"] ?? "?").components(separatedBy: "<<")   //姓名，值为："HU<<HUAXIANG<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        lastName = names[0].replacingOccurrences(of: "<", with: " " )   //姓
        
        var name = ""
        if names.count > 1 {
            let fn = names[1].replacingOccurrences(of: "<", with: " " ).strip()
            name += fn + " "
        }
        firstName = name.strip()    //名
        
    }
    
    init( passportMRZData: String, image : UIImage, signed:Bool, dataValid:Bool ) {
        
        self.image = image
        self.passportSigned = signed
        self.passportDataValid = dataValid
        let line1 = passportMRZData[0..<44]
        let line2 = passportMRZData[44...]
        
        // Line 1
        documentType = line1[0..<1]
        documentSubType = line1[1..<2]
        issuingAuthority = line1[2..<5]
        
        let names = line1[5..<44].components(separatedBy: "<<")
        lastName = names[0].replacingOccurrences(of: "<", with: " " )
        
        var name = ""
        if names.count > 1 {
            let fn = names[1].replacingOccurrences(of: "<", with: " " ).strip()
            name += fn + " "
        }
        firstName = name.strip()
        
        
        // Line 2
        documentNumber = line2[0..<9].replacingOccurrences(of: "<", with: "" )
        nationality = line2[10..<13]
        dateOfBirth = line2[13..<19]
        gender = line2[20..<21]
        documentExpiryDate = line2[21..<27]
        personalNumber = line2[28..<42].replacingOccurrences(of: "<", with: "" )
    }
}
