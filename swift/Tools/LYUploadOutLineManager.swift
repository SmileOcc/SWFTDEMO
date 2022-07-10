//
//  LYUploadOutLineManager.swift
//  LYProductModel
//
//  Created by 航电 on 2020/11/30.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

class LYUploadOutLineManager: NSObject {

    //MARK: 单例
    public static let sharedInstance:LYUploadOutLineManager = {
        let uploadManager = LYUploadOutLineManager();
        return uploadManager;
    }();
    
    //TODO: 上传离线问题
    public func onUploadDataForQuestion(_ questions: NSArray, _ successBlock: (@escaping () -> Void), _ failureBlock: (@escaping (_ msg: String) -> Void)) {
        if questions.count > 0 {
            DispatchQueue.global().async {
                self.onUploadQuestionToPicture(questions, 0, successBlock, failureBlock);
            }
        } else {
            successBlock();
        }
    }
    
    private func onUploadQuestionToPicture(_ questions: NSArray, _ index: Int, _ successBlock: (@escaping () -> Void), _ failureBlock: (@escaping (_ msg: String) -> Void)) {
        if questions.count > index {
            let questionDictionary = questions[index] as! NSDictionary;
            
            let image = questionDictionary["image"] as! String;
            if image.count > 0 {
                //有图片，就上传
                let mutPicArray = NSMutableArray();
                
                let imgArray = image.components(separatedBy: "$$$$");
                
                let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first;
                let picFilePath = "\(documentPath ?? "")"+"/questionImages";
                let fileManager = FileManager.default;
                if fileManager.isExecutableFile(atPath: picFilePath) == true {
                    for i in 0..<imgArray.count {
                        let imgName = imgArray[i] ;
                        let imgPath = "\(picFilePath)"+"/"+"\(imgName)";
                        if fileManager.fileExists(atPath: imgPath) {
                            let img = UIImage(contentsOfFile: imgPath);
                            if img != nil {
                                mutPicArray.add(img!);
                            }
                        }
                    }
                }
                
                self.onUpdataPicture(questions, index, mutPicArray, 0, successBlock, failureBlock);
            } else {
                //无图片
                self.onUploadQuestionToData(questions, index, "", successBlock, failureBlock);
            }
        } else {
            //上传完毕，返回
            successBlock();
        }
    }
    
    private func onUploadQuestionToData(_ questions: NSArray, _ index: Int, _ picName: String, _ successBlock: (@escaping () -> Void), _ failureBlock: (@escaping (_ msg: String) -> Void)) {
        if questions.count > index {
            let questionDictionary = questions[index] as! NSDictionary;
            
            //1.项目
            let projectId = questionDictionary["projectId"] as! Int64;
            let projectName = questionDictionary["projectName"] as! String;
            let projectNumber = questionDictionary["projectNumber"] as! String;
            //2.空间
            let spaceAddress = questionDictionary["spaceAddress"] as! Int64;
            if spaceAddress < 0 {
                //该问题的空间是离线的
                self.onUploadQuestionToPicture(questions, index+1, successBlock, failureBlock);
                return;
            }
            let spaceAddressName = questionDictionary["spaceAddressName"] as! String;
            //3.专业
            let major = questionDictionary["major"] as! Int64;
            let majorName = questionDictionary["majorName"] as! String;
            let majorCode = questionDictionary["majorCode"] as! String;
            //4.设备或部位
            let equipmentId = questionDictionary["equipmentId"] as! Int64;
            let equipmentOrPart = questionDictionary["equipmentOrPart"] as! String;
            let equipmentOrPartDic = NSMutableDictionary(dictionary: self.getArrayOrDicFromJSONString(jsonString: equipmentOrPart));
            equipmentOrPartDic.removeObject(forKey: "createTime");
            equipmentOrPartDic.removeObject(forKey: "updateTime");
            //5.查验类型 == -1过滤
            let checkType = questionDictionary["checkType"] as! Int;
            //6.问题描述
            let questionDescribe = questionDictionary["questionDescribe"] as! String;
            //7.隐患
            let harm = questionDictionary["harm"] as! String;
            //8.整改建议
            let measures = questionDictionary["measures"] as! String;
            //9.问题类别
            let questionCategoryId = questionDictionary["questionCategoryId"] as! Int64;
            let questionCategory = questionDictionary["questionCategory"] as! String;
            //10.问题属性
            let questionPropertyId = questionDictionary["questionPropertyId"] as! Int64;
            let questionProperty = questionDictionary["questionProperty"] as! String;
            //11.紧急情况
            let emergencyId = questionDictionary["emergencyId"] as! Int64;
            let emergency = questionDictionary["emergency"] as! String;
            //12.造成问题原因
            let questionReasonId = questionDictionary["questionReasonId"] as! Int64;
            let questionReason = questionDictionary["questionReason"] as! String;
            //13.预估整改难度
            let estimatedDifficultyId = questionDictionary["estimatedDifficultyId"] as! Int64;
            let estimatedDifficulty = questionDictionary["estimatedDifficulty"] as! String;
            //14.整改建议方
            let suggestRectificationPartyId = questionDictionary["suggestRectificationPartyId"] as! Int64;
            let suggestRectificationParty = questionDictionary["suggestRectificationParty"] as! String;
            //15.问题整改预估价
            let estimatedAmount = questionDictionary["estimatedAmount"] as! String;
            //16.图片
            let image = picName;
                    
            let parameters = [
                "projectId":projectId,
                "projectName":projectName,
                "projectNumber":projectNumber,
                "spaceAddress":spaceAddress,
                "spaceAddressName":spaceAddressName,
                "major":major,
                "majorName":majorName,
                "majorCode":majorCode,
                "equipmentId":equipmentId,
                "equipmentOrPart":equipmentOrPartDic,
                "questionDescribe":questionDescribe
                ] as [String : Any];
                    
            let mutParameters = NSMutableDictionary(dictionary: parameters);
            if checkType != -1 {
                mutParameters.setValue(NSNumber(value: checkType), forKey: "checkType");
            }
            if harm.count > 0 {
                mutParameters.setValue(harm, forKey: "harm");
            }
            if measures.count > 0 {
                mutParameters.setValue(measures, forKey: "measures");
            }
            if questionCategoryId != -1 {
                mutParameters.setValue(questionCategoryId, forKey: "questionCategoryId");
                mutParameters.setValue(questionCategory, forKey: "questionCategory");
            }
            if questionPropertyId != -1 {
                mutParameters.setValue(questionPropertyId, forKey: "questionPropertyId");
                mutParameters.setValue(questionProperty, forKey: "questionProperty");
            }
            if emergencyId != -1 {
                mutParameters.setValue(emergencyId, forKey: "emergencyId");
                mutParameters.setValue(emergency, forKey: "emergency");
            }
            if questionReasonId != -1 {
                mutParameters.setValue(questionReasonId, forKey: "questionReasonId");
                mutParameters.setValue(questionReason, forKey: "questionReason");
            }
            if estimatedDifficultyId != -1 {
                mutParameters.setValue(estimatedDifficultyId, forKey: "estimatedDifficultyId");
                mutParameters.setValue(estimatedDifficulty, forKey: "estimatedDifficulty");
            }
            if suggestRectificationPartyId != -1 {
                mutParameters.setValue(suggestRectificationPartyId, forKey: "suggestRectificationPartyId");
                mutParameters.setValue(suggestRectificationParty, forKey: "suggestRectificationParty");
            }
            if estimatedAmount.count > 0 {
                mutParameters.setValue(estimatedAmount, forKey: "estimatedAmount");
            }
            if image.count > 0 {
                mutParameters.setValue(image, forKey: "image");
            }
            
            let did = questionDictionary["id"] as! Int64;
            
            weak var weakSelf = self
            HDWebserviseManager.sharedInstance.onRequestForPost(url: "/question/add", parameters: mutParameters as! [String : Any], success: { (dataDic) in
                
                let code = dataDic["code"] as! String
                if code == "200" {
                    //删除
                    HDSQLiteManager.sharedInstance.questionsTableLampDeleteItem(did, projectId);
                    
                    //继续下一个问题
                    weakSelf?.onUploadQuestionToPicture(questions, index+1, successBlock, failureBlock);
                } else {
                    let message = dataDic["message"] as? String
                    if message != nil {
                        if message!.contains("无权限") == true {
//                            failureBlock("您没有该项目的查验权限,请联系管理器授权");
                            HDSQLiteManager.sharedInstance.questionsTableLampUpdateItem(did, "2");
                        }
                    }
                    
                    //继续下一个问题
                    weakSelf?.onUploadQuestionToPicture(questions, index+1, successBlock, failureBlock);
                }
                

            }) { (errorName) in
                failureBlock("上传问题失败");
            }
        } else {
            //上传完毕，返回
            successBlock();
        }
    }
    
    
    //TODO: 上传离线空间
    public func onUploadDataForSpaceTree(_ spaces: NSArray, _ successBlock: (@escaping () -> Void), _ failureBlock: (@escaping (_ msg: String) -> Void)) {
        if spaces.count > 0 {
            DispatchQueue.global().async {
                self.onUploadQuestionToSpaceTreeDB( successBlock, failureBlock);
            }
        } else {
            successBlock();
        }
    }
    
    private func onUploadQuestionToSpaceTreeDB( _ successBlock: (@escaping () -> Void), _ failureBlock: (@escaping (_ msg: String) -> Void)) {
        let mutSpaceTreeArray = NSMutableArray();
        let selectArray = HDSQLiteManager.sharedInstance.spaceTreesListTableLampSelectAllItem(projectId: -1);
        for i in 0..<selectArray.count {
            let spaceDic = selectArray[i] as! NSDictionary;
            let isLoad = spaceDic["isLoad"] as! String;
            if isLoad == "0" {//将离线的空间加入
                if mutSpaceTreeArray.contains(spaceDic) == false {
                    mutSpaceTreeArray.add(spaceDic);
                }
            }
        }
        
        if mutSpaceTreeArray.count > 0 {
            self.onUploadQuestionToSpaceTree(mutSpaceTreeArray, 0, successBlock, failureBlock);
        } else {
            successBlock();
        }
    }
    
    private func onUploadQuestionToSpaceTree(_ spaces: NSArray, _ index: Int, _ successBlock: (@escaping () -> Void), _ failureBlock: (@escaping (_ msg: String) -> Void)) {
        
        if spaces.count > index {
            let spaceDic = spaces[index] as! NSDictionary;
            let sid = spaceDic["iid"] as! Int64
            let oldId = spaceDic["id"] as! Int64
            let projectId = spaceDic["projectId"] as! Int64
            let name = spaceDic["name"] as! String
            let orgId = spaceDic["orgId"] as! Int
            let pid = spaceDic["pid"] as! Int
            let pname = spaceDic["pname"] as! String
            
            let parameters = ["name" : name,//空间名称
                "projectId": projectId,//项目ID
                "pid":pid,
                "pname": pname,
                "orgId": orgId//组织ID
                ] as [String:Any];
   
            weak var weakSelf = self
            HDWebserviseManager.sharedInstance.onRequestForPost(url: "/space/add", parameters: parameters , success: { (dataDic) in
               
                let code = dataDic["code"] as? String
                if code == "200" {

                    let dataDictinary = dataDic["data"] as? NSDictionary;
                    if dataDictinary != nil {
                        let did = dataDictinary!["id"] as? Int64;
                        if did != nil {
                            //1.更新当前空间数据
                            HDSQLiteManager.sharedInstance.spaceTreesTableLampUpdateItem(sid, projectId, did!);
                            
                            //2.更新其他空间数据，已当前空间为父节点
                            HDSQLiteManager.sharedInstance.spaceTreesTableLampUpdatePidItem(oldId, projectId, did!)
                            
                            //3.更新问题里面的空间数据
                            HDSQLiteManager.sharedInstance.questionsTableLampUpdateSpaceTree(projectId, oldId, did!)
                        }
                    }
                    //继续下一个问题
                    weakSelf?.onUploadQuestionToSpaceTreeDB( successBlock, failureBlock);
                } else {
                    let message = dataDic["message"] as? String
                    if message != nil {
                        if message!.contains("重复") == true {
                            let newId = -10086 + oldId;
                            //1.更新空间数据
                            HDSQLiteManager.sharedInstance.spaceTreesTableLampUpdateItem(sid, projectId, newId);
                            
                            //2.更新其他空间数据，已当前空间为父节点
                            HDSQLiteManager.sharedInstance.spaceTreesTableLampUpdatePidItem(oldId, projectId, newId)
                            
                            //3.更新问题里面的空间数据
                            HDSQLiteManager.sharedInstance.questionsTableLampUpdateSpaceTree(projectId, oldId, newId)
                        }
                        
                    }
                    weakSelf?.onUploadQuestionToSpaceTreeDB(successBlock, failureBlock);
                }
            }) { (errorName) in
                failureBlock("上传问题失败");
            }
        } else {
            successBlock();
        }
    }
    
    //TODO: 图片 type: 0 问题,1 空间，2 台账
    private func onUpdataPicture(_ questions: NSArray, _ index: Int, _ picArr: NSArray , _ type: Int, _ successBlock: (@escaping () -> Void), _ failureBlock: (@escaping (_ msg: String) -> Void)) {
        weak var weakSelf = self;
        WYFileService.sharedInstance().onUpdateAliYunImage(withPostData: picArr as! [Any], withSuccess: { (data) in
            let picUrls = data["picUrls"] as? NSArray;
            if picUrls != nil {
                let mutPicName = NSMutableString();
                for i in 0..<picUrls!.count {
                    let picName = picUrls![i] as? String;
                    if picName != nil {
                        if mutPicName.length > 0 {
                            mutPicName.append(",");
                        }
                        mutPicName.append(picName!);
                    }
                }
                
                if type == 0 {
                    weakSelf?.onUploadQuestionToData(questions, index, mutPicName as String, successBlock, failureBlock);
                }
            }
        }) { (msg) in
            
            failureBlock("图片上传失败");
        }
    }
    
    //将字符串转化为 数组/字典
    func getArrayOrDicFromJSONString(jsonString:String) -> NSDictionary {
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        //可能是字典也可能是数组，再转换类型就好了
        if let info = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) {
            return info as! NSDictionary
        }
        return NSDictionary();
    }
    
    //TODO: 上传离线设备台帐
    public func onUploadDataForDeviceList(_ devices: NSArray, _ successBlock: (@escaping () -> Void), _ failureBlock: (@escaping (_ msg: String) -> Void)) {
        if devices.count > 0 {
            for item in devices {
                DispatchQueue.global().async {
                    let deviceDic = item as! NSDictionary
                    self.onUploadDeviceToPicture(deviceDic, successBlock, failureBlock);
                }
            }
        } else {
            successBlock();
        }
    }
    
    private func onUploadDeviceToPicture(_ deviceDictionary: NSDictionary, _ successBlock: (@escaping () -> Void), _ failureBlock: (@escaping (_ msg: String) -> Void)) {
        let equipmentNameplate = deviceDictionary["equipmentNameplate"] as! String
        let equipmentPicture = deviceDictionary["equipmentPicture"] as! String
        
        let tempImagesDic = NSMutableDictionary()
        if equipmentNameplate.count > 0 || equipmentPicture.count > 0 {
            //有图片，就上传
            let mutPicArray = NSMutableArray();
            let equipmentNameplateArray = equipmentNameplate.components(separatedBy: "$$$$");
            let equipmentPictureArray = equipmentPicture.components(separatedBy: "$$$$");
            let upImages = NSMutableArray.init(array: equipmentNameplateArray)
            upImages.addObjects(from: equipmentPictureArray)
            
            let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first;
            let picFilePath = "\(documentPath ?? "")"+"/devicesImages";
            let fileManager = FileManager.default;
            if fileManager.isExecutableFile(atPath: picFilePath) == true {
                for i in 0..<upImages.count {
                    let imgName = upImages[i] ;
                    let imgPath = "\(picFilePath)"+"/"+"\(imgName)";
                    if fileManager.fileExists(atPath: imgPath) {
                        let img = UIImage(contentsOfFile: imgPath);
                        if img != nil {
                            mutPicArray.add(img!);
                        }
                    }
                }
            }

            weak var weakSelf = self;
            WYFileService.sharedInstance().onUpdateAliYunImage(withPostData: mutPicArray as! [Any], withSuccess: { (data) in
                let picUrls = data["picUrls"] as? NSArray;
                if picUrls != nil {
                    let equipmentNameplatePicName = NSMutableString();
                    let equipmentPicturePicName = NSMutableString();
                    for i in 0..<picUrls!.count {
                        let picName = picUrls![i] as? String;
                        if picName != nil {
                            if i < equipmentNameplateArray.count {
                                if equipmentNameplatePicName.length > 0 {
                                    equipmentNameplatePicName.append(";");
                                }
                                equipmentNameplatePicName.append(picName!);
                            } else {
                                if equipmentPicturePicName.length > 0 {
                                    equipmentPicturePicName.append(";");
                                }
                                equipmentPicturePicName.append(picName!);
                            }
                            
                        }
                    }
                    tempImagesDic.setValue(equipmentNameplatePicName, forKey: "equipmentNameplate")
                    tempImagesDic.setValue(equipmentPicturePicName, forKey: "equipmentPicture")
                    
                    weakSelf!.onUploadDevices(deviceDictionary, tempImagesDic, successBlock, failureBlock)
                }
            }) { (msg) in
                failureBlock("图片上传失败");
            }
        } else {
            self.onUploadDevices(deviceDictionary, tempImagesDic, successBlock, failureBlock)
        }
    }
    
    private func onUploadDevices(_ dictionary: NSDictionary, _ picDic: NSDictionary, _ successBlock: (@escaping () -> Void), _ failureBlock: (@escaping (_ msg: String) -> Void)) {
        let postDic = NSMutableDictionary.init(dictionary: picDic)
        let deviceCode = dictionary["deviceCode"] as? String ?? ""
        postDic.setValue(deviceCode, forKey: "deviceCode")
        let deviceName = dictionary["deviceName"] as? String ?? ""
        postDic.setValue(deviceName, forKey: "deviceName")
        let deviceStatus = dictionary["deviceStatus"] as? Int64 ?? 0
        if deviceStatus != 0 {
            postDic.setValue(deviceStatus, forKey: "deviceStatus")
        }
        let deviceType = dictionary["deviceType"] as? Int64 ?? 0
        postDic.setValue(deviceType, forKey: "deviceType")
        if deviceType == 0 {
            postDic.setValue("未分类", forKey: "deviceTypeStr")
        } else {
            let deviceTypeStr = dictionary["deviceTypeStr"] as? String ?? ""
            postDic.setValue(deviceTypeStr, forKey: "deviceTypeStr")
        }
        let equipmentBrand = dictionary["equipmentBrand"] as? String ?? ""
        postDic.setValue(equipmentBrand, forKey: "equipmentBrand")
        let equipmentLabel = dictionary["equipmentLabel"] as? String ?? ""
        postDic.setValue(equipmentLabel, forKey: "equipmentLabel")
        
        let fixedAssetsCode = dictionary["fixedAssetsCode"] as? String ?? ""
        postDic.setValue(fixedAssetsCode, forKey: "fixedAssetsCode")
        let importantInformation = dictionary["importantInformation"] as? String ?? ""
        postDic.setValue(importantInformation, forKey: "importantInformation")
        let installationDate = dictionary["installationDate"] as? Int64 ?? 0
        if installationDate != 0 {
            postDic.setValue(installationDate, forKey: "installationDate")
        }
        let launchDate = dictionary["launchDate"] as? Int64 ?? 0
        if launchDate != 0 {
            postDic.setValue(launchDate, forKey: "launchDate")
        }
        let maintenance = dictionary["maintenance"] as? Int64 ?? 0
        if maintenance != 0 {
            postDic.setValue(maintenance, forKey: "maintenance")
        }
        let manufacturer = dictionary["manufacturer"] as? String ?? ""
        postDic.setValue(manufacturer, forKey: "manufacturer")
        let manufacturingNo = dictionary["manufacturingNo"] as? String ?? ""
        postDic.setValue(manufacturingNo, forKey: "manufacturingNo")
    
        let meterReading = dictionary["meterReading"] as? Int64 ?? 0
        if meterReading != 0 {
            postDic.setValue(meterReading, forKey: "meterReading")
        }
        
        let pid = dictionary["pid"] as? Int64 ?? 0
        postDic.setValue(pid, forKey: "pid")
        if pid == 0 {
            postDic.setValue("顶级", forKey: "pname")
        } else {
            let pname = dictionary["pname"] as? String ?? ""
            postDic.setValue(pname, forKey: "pname")
        }
        let productionDate = dictionary["productionDate"] as? Int64 ?? 0
        if productionDate != 0 {
            postDic.setValue(productionDate, forKey: "productionDate")
        }
        let projectId = dictionary["projectId"] as? Int64 ?? 0
        if projectId != 0 {
            postDic.setValue(projectId, forKey: "projectId")
        }
        let projectName = dictionary["projectName"] as? String ?? ""
        postDic.setValue(projectName, forKey: "projectName")
        let remark = dictionary["remark"] as? String ?? ""
        postDic.setValue(remark, forKey: "remark")
        let responsiblePerson = dictionary["responsiblePerson"] as? String ?? ""
        postDic.setValue(responsiblePerson, forKey: "responsiblePerson")
        let routingInspection = dictionary["routingInspection"] as? Int64 ?? 0
        if routingInspection != 0 {
            postDic.setValue(routingInspection, forKey: "routingInspection")
        }
        
        let serviceRegion = dictionary["serviceRegion"] as? String ?? ""
        postDic.setValue(serviceRegion, forKey: "serviceRegion")
        let spaceName = dictionary["spaceName"] as? String ?? ""
        postDic.setValue(spaceName, forKey: "spaceName")
        let speciality = dictionary["speciality"] as? Int64 ?? 0
        if speciality != 0 {
            postDic.setValue(speciality, forKey: "speciality")
        }
        let specialityName = dictionary["specialityName"] as? String ?? ""
        postDic.setValue(specialityName, forKey: "specialityName")
        let specificationsModel = dictionary["specificationsModel"] as? String ?? ""
        postDic.setValue(specificationsModel, forKey: "specificationsModel")
        
        let status = dictionary["status"] as? Int64 ?? 0
        if status != 0 {
            postDic.setValue(status, forKey: "status")
        }
        let ubietyAddress = dictionary["ubietyAddress"] as? Int64 ?? 0
        if ubietyAddress != 0 {
            postDic.setValue(ubietyAddress, forKey: "ubietyAddress")
        }
        let ubietyAddressStr = dictionary["ubietyAddressStr"] as? String ?? ""
        postDic.setValue(ubietyAddressStr, forKey: "ubietyAddressStr")
        
        let ubietyBuilding = dictionary["ubietyBuilding"] as? String ?? ""
        postDic.setValue(ubietyBuilding, forKey: "ubietyBuilding")
        let unitType = dictionary["unitType"] as? Int64 ?? 0
        if unitType != 0 {
            postDic.setValue(unitType, forKey: "unitType")
        }
        let updateTime = dictionary["updateTime"] as? Int64 ?? 0
        postDic.setValue(updateTime, forKey: "updateTime")
        let useStatus = dictionary["useStatus"] as? Int64 ?? 0
        if useStatus != 0 {
            postDic.setValue(useStatus, forKey: "useStatus")
        }
        
        let bigUpdateDate = dictionary["bigUpdateDate"] as? Int64 ?? 0
        if bigUpdateDate != 0 {
            postDic.setValue(bigUpdateDate, forKey: "bigUpdateDate")
        }
        let bigUpdateText = dictionary["bigUpdateText"] as? String ?? ""
        postDic.setValue(bigUpdateText, forKey: "bigUpdateText")
        let updateRecord = dictionary["updateRecord"] as? String ?? ""
        postDic.setValue(updateRecord, forKey: "updateRecord")
        let maintainUnit = dictionary["maintainUnit"] as? String ?? ""
        postDic.setValue(maintainUnit, forKey: "maintainUnit")
        let autoId = dictionary["autoId"] as? Int64 ?? 0
        
        let userInfo = HDUserManager.sharedInstance
        let userId = userInfo.id
        let userName = userInfo.userName
        let orgId = userInfo.orgId
        postDic.setValue(userId, forKey: "userId")
        postDic.setValue(userName, forKey: "userName")
        postDic.setValue(orgId, forKey: "orgId")
        
        let deviceId = dictionary["id"] as? Int64 ?? 0
        if deviceId != 0 {
            postDic.setValue(deviceId, forKey: "id")
            HDWebserviseManager.sharedInstance.onRequestForPost(url: "/equipment/update", parameters: postDic as! [String : Any], success: { (dataDic) in
                let code = dataDic["code"] as! String
                if code == "200" {
                    HDSQLiteManager.sharedInstance.deviceDetailListTableLampUpdate(autoId: autoId, deviceId: deviceId, deviceCode: deviceCode, isUpload: 1, projectId: projectId, deviceType: deviceType)
                    successBlock()
                } else {
                    failureBlock("设备上传失败")
                }
            }) { (errorName) in
                failureBlock("设备上传失败")
            }
        } else {
            HDWebserviseManager.sharedInstance.onRequestForPost(url: "/equipment/add", parameters: postDic as! [String : Any], success: { (dataDic) in
                let code = dataDic["code"] as! String
                if code == "200" {
                    HDSQLiteManager.sharedInstance.deviceDetailListTableLampUpdate(autoId: autoId, deviceId: deviceId, deviceCode: deviceCode, isUpload: 1, projectId: projectId, deviceType: deviceType)
                    successBlock()
                } else {
                    failureBlock("设备上传失败")
                }
            }) { (errorName) in
                failureBlock("设备上传失败")
            }
        }
    }
}
