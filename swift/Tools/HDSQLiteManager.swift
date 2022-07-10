//
//  HDSQLiteManager.swift
//  HDDBStorageProject
//
//  Created by MountainZhu on 2020/6/15.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit
import SQLite
import SwiftyJSON

//用户名和密码
let LOGIN_TABLE_LAMP = Table("login_table_lamp")
public let LOGIN_TABLE_LAMP_ID = Expression<Int64>("login_lamp_id")
let LOGIN_TABLE_LAMP_NAME = Expression<String>("login_lamp_name")//用户名
let LOGIN_TABLE_LAMP_PASSWORD = Expression<String>("login_lamp_password")//密码
let LOGIN_TABLE_LAMP_LOGINTYPE = Expression<Bool>("login_lamp_loginType")//登录状态

//登陆者组织下的项目列表
let PROJECT_LIST_TABLE = Table("projectList_table")
public let PROJECT_LIST_TABLE_ID = Expression<Int64>("id")
let PROJECT_LIST_PROJECTID = Expression<Int64>("projectId")//项目id
let PROJECT_LIST_PROJECTNAME = Expression<String>("projectName")//项目名称
let PROJECT_LIST_PROJECTIDENTIFICATION = Expression<String>("projectIdentification")//项目标识
let PROJECT_LIST_ORGID = Expression<Int64>("orgId")//组织id
let PROJECT_LIST_ORGNAME = Expression<String>("orgName")//组织名称

//专业表
let PROFESSIONAL_LIST_TABLE = Table("professionalList_table")
public let PROFESSIONAL_LIST_TABLE_ID = Expression<Int64>("id")
let PROFESSIONAL_LIST_DID = Expression<Int64>("did")//专业ID
let PROFESSIONAL_LIST_NAME = Expression<String>("name")//专业名
let PROFESSIONAL_LIST_CHARACTER = Expression<String>("character")//专业编码
let PROFESSIONAL_LIST_ORDER = Expression<Int64>("order")//排序号
let PROFESSIONAL_LIST_STATUS = Expression<Int64>("status")//状态：1：启用，2：冻结，3：删除
let PROFESSIONAL_LIST_CREATETIME = Expression<Int64>("createTime")//创建时间
let PROFESSIONAL_LIST_UPDATETIME = Expression<Int64>("updateTime")//修改时间

//专业下的设备
let DEVICES_LIST_TABLE = Table("devicesList_table")
public let DEVICES_LIST_TABLE_ID = Expression<Int64>("id")
let DEVICES_LIST_DID = Expression<Int64>("did")//设备或部位id
let DEVICES_LIST_NAME = Expression<String>("name")//设备或部位名称
let DEVICES_LIST_ORDER = Expression<Int64>("order")//排序号
let DEVICES_LIST_SPECIALTYID = Expression<Int64>("specialtyId")//专业id
let DEVICES_LIST_SPECIALTYNAME = Expression<String>("specialtyName")//专业名称
let DEVICES_LIST_STATUS = Expression<Int64>("status")//状态：1：启用，2：冻结，3：删除
let DEVICES_LIST_ISEDIT = Expression<Int64>("isEdit")//是否可以编辑,0:不可编辑删除，1：可编辑删除
let DEVICES_LIST_CREATETIME = Expression<Int64>("createTime")//创建时间
let DEVICES_LIST_UPDATETIME = Expression<Int64>("updateTime")//修改时间

//设备下的配置字典
let EQUIPMENTPOSITION_LIST_TABLE = Table("equipmentPositionList_table")
public let EQUIPMENTPOSITION_LIST_TABLE_ID = Expression<Int64>("id")
let EQUIPMENTPOSITION_LIST_DID = Expression<Int64>("did")//配置字典id
let EQUIPMENTPOSITION_LIST_PROPOSE = Expression<String>("propose")//内容
let EQUIPMENTPOSITION_LIST_ORDER = Expression<Int64>("order")//排序号
let EQUIPMENTPOSITION_LIST_DICTYPE = Expression<Int64>("dicType")//配置字典类型：0、1查验标准，2问题描述，3隐患及危害，4整改建议
let EQUIPMENTPOSITION_LIST_EXAMINETYPE = Expression<Int64>("examineType")//查验类型 1：安全，2：功能，3：外观，4：管理，5：其他
let EQUIPMENTPOSITION_LIST_EQUIPMENTPOSITIONID = Expression<Int64>("equipmentPositionId")//设备或部位id
let EQUIPMENTPOSITION_LIST_STATUS = Expression<Int64>("status")//状态
let EQUIPMENTPOSITION_LIST_CREATETIME = Expression<Int64>("createTime")//创建时间
let EQUIPMENTPOSITION_LIST_UPDATETIME = Expression<Int64>("updateTime")//更新时间

//数据字典
let DATADICTIONARYS_LIST_TABLE = Table("dataDictionarysList_table")
public let DATADICTIONARYS_LIST_TABLE_ID = Expression<Int64>("id")
let DATADICTIONARYS_LIST_DID = Expression<Int64>("did")//id
let DATADICTIONARYS_LIST_CODE = Expression<String>("code")//编码(QUESTION_CLASS:问题类别,QUESTION_ARGS:问题属性,QUESTION_URGENT:紧急情况,QUESTION_REASON:造成问题的可能原因,QUESTION_DIFFICULTY:预估整改难度,QUESTION_RECTIFICATION:整改建议方)
let DATADICTIONARYS_LIST_NAME = Expression<String>("name")//名称
let DATADICTIONARYS_LIST_ORDER = Expression<Int64>("order")//排序号
let DATADICTIONARYS_LIST_LEVEL = Expression<Int64>("level")//检查人id
let DATADICTIONARYS_LIST_PID = Expression<Int64>("pid")//父id
let DATADICTIONARYS_LIST_PIDNAME = Expression<String>("pidName")//父名称
let DATADICTIONARYS_LIST_STATUS = Expression<Int64>("status")//状态
let DATADICTIONARYS_LIST_CREATETIME = Expression<Int64>("createTime")//创建时间
let DATADICTIONARYS_LIST_UPDATETIME = Expression<Int64>("updateTime")//更新时间

//空间
let SPACETREES_LIST_TABLE = Table("spaceTreesList_table")
public let SPACETREES_LIST_TABLE_ID = Expression<Int64>("id")
let SPACETREES_LIST_DID = Expression<Int64>("did")//空间id
let SPACETREES_LIST_NAME = Expression<String>("name")//空间名称
let SPACETREES_LIST_PID = Expression<Int64>("pid")//上级空间ID
let SPACETREES_LIST_PNAME = Expression<String>("pname")//上级空间名称
let SPACETREES_LIST_PROJECTID = Expression<Int64>("projectId")//项目ID
let SPACETREES_LIST_PROJECTNAME = Expression<String>("projectName")//项目名称
let SPACETREES_LIST_ORGID = Expression<Int64>("orgId")//组织ID
let SPACETREES_LIST_CREATETIME = Expression<Int64>("createTime")//创建时间
let SPACETREES_LIST_UPDATETIME = Expression<Int64>("updateTime")//更新时间
let SPACETREES_LIST_ISLOAD = Expression<String>("isLoad")//是否上传, 0:没上传，1:已上传

//未上传的问题
let QUESTIONS_LIST_TABLE = Table("questionsList_table")
public let QUESTIONS_LIST_TABLE_ID = Expression<Int64>("id")
let QUESTIONS_LIST_PROJECTID = Expression<Int64>("projectId")//项目ID
let QUESTIONS_LIST_PROJECTNAME = Expression<String>("projectName")//项目名
let QUESTIONS_LIST_PROJECTNUMBER = Expression<String>("projectNumber")//项目编码
let QUESTIONS_LIST_SPACEADDRESS = Expression<Int64>("spaceAddress")//空间位置ID
let QUESTIONS_LIST_SPACEADDRESSNAME = Expression<String>("spaceAddressName")//空间位置
let QUESTIONS_LIST_MAJOR = Expression<Int64>("major")//专业ID
let QUESTIONS_LIST_MAJORNAME = Expression<String>("majorName")//专业
let QUESTIONS_LIST_MAJORCODE = Expression<String>("majorCode")//专业code
let QUESTIONS_LIST_EQUIPMENTID = Expression<Int64>("equipmentId")//设备ID
let QUESTIONS_LIST_EQUIPMENTORPART = Expression<String>("equipmentOrPart")//设备或部位
let QUESTIONS_LIST_CHECKTYPE = Expression<Int64>("checkType")//检查类型
let QUESTIONS_LIST_QUESTIONDESCRIBE = Expression<String>("questionDescribe")//问题描述
let QUESTIONS_LIST_HARM = Expression<String>("harm")//危害
let QUESTIONS_LIST_MEASURES = Expression<String>("measures")//改善措施/整改建议
let QUESTIONS_LIST_QUESTIONCATEGORYID = Expression<Int64>("questionCategoryId")//问题类别ID
let QUESTIONS_LIST_QUESTIONCATEGORY = Expression<String>("questionCategory")//问题类别
let QUESTIONS_LIST_QUESTIONPROPERTYID = Expression<Int64>("questionPropertyId")//问题属性ID
let QUESTIONS_LIST_QUESTIONPROPERTY = Expression<String>("questionProperty")//问题属性
let QUESTIONS_LIST_EMERGENCYID = Expression<Int64>("emergencyId")//紧急情况ID
let QUESTIONS_LIST_EMERGENCY = Expression<String>("emergency")//紧急情况
let QUESTIONS_LIST_QUESTIONREASONID = Expression<Int64>("questionReasonId")//原因ID
let QUESTIONS_LIST_QUESTIONREASON = Expression<String>("questionReason")//造成问题的原因
let QUESTIONS_LIST_ESTIMATEDDIFFICULTYID = Expression<Int64>("estimatedDifficultyId")//预估整改难度ID
let QUESTIONS_LIST_ESTIMATEDDIFFICULTY = Expression<String>("estimatedDifficulty")//预估整改难度
let QUESTIONS_LIST_SUGGESTRECTIFICATIONPARTYID = Expression<Int64>("suggestRectificationPartyId")//建议整改方ID
let QUESTIONS_LIST_SUGGESTRECTIFICATIONPARTY = Expression<String>("suggestRectificationParty")//建议整改方
let QUESTIONS_LIST_ESTIMATEDAMOUNT = Expression<String>("estimatedAmount")//完成问题整改预估价
let QUESTIONS_LIST_IMAGE = Expression<String>("image")//图片 逗号分割的全路径URL
let QUESTIONS_LIST_UPDATETIME = Expression<String>("updateTime")//更新时间
let QUESTIONS_LIST_ISLOAD = Expression<String>("isLoad")//是否上传, 0:没上传，1:已上传,2:未上传，项目权限更动



//MARK: 设备台账
let DEVICE_DETAIL_TABLE = Table("spacetree_table")
public let DEVICE_DETAIL_TABLE_ID = Expression<Int64>("id")
let DEVICE_DETAIL_DEVICEID = Expression<Int64>("deviceId")//主键id
let DEVICE_DETAIL_CREATETIME = Expression<Int64>("createTime")//
let DEVICE_DETAIL_DEVICECODE = Expression<String>("deviceCode")//设备编号
let DEVICE_DETAIL_DEVICENAME = Expression<String>("deviceName")//设备名称
let DEVICE_DETAIL_DEVICESTATUS = Expression<Int64>("deviceStatus")//设备状态1正常、2故障、3报废
let DEVICE_DETAIL_DEVICETYPE = Expression<Int64>("deviceType")//设备分类Id
let DEVICE_DETAIL_DEVICETYPESTR = Expression<String>("deviceTypeStr")//设备分类名称
let DEVICE_DETAIL_EQUIPMENTBRAND = Expression<String>("equipmentBrand")//设备品牌
let DEVICE_DETAIL_EQUIPMENTLABEL = Expression<String>("equipmentLabel")//设备标签(多个用分号隔开)
let DEVICE_DETAIL_EQUIPMENTNAMEPLATE = Expression<String>("equipmentNameplate")//设备铭牌
let DEVICE_DETAIL_EQUIPMENTPICTURE = Expression<String>("equipmentPicture")//设备图片
let DEVICE_DETAIL_EQUIPMENTTHUMBNAIL = Expression<String>("equipmentThumbnail")//设备缩略图
let DEVICE_DETAIL_EQUIPMENTTYPECOUNT = Expression<Int64>("equipmentTypeCount")//设备分类总数
let DEVICE_DETAIL_FIXEDASSETSCODE = Expression<String>("fixedAssetsCode")//固定资产编号
let DEVICE_DETAIL_IMPORTANTINFORMATION = Expression<String>("importantInformation")//其它重要信息
let DEVICE_DETAIL_INSTALLATIONDATE = Expression<Int64>("installationDate")//安装日期
let DEVICE_DETAIL_LAUNCHDATE = Expression<Int64>("launchDate")//启用日期
let DEVICE_DETAIL_MAINTENANCE = Expression<Int64>("maintenance")//纳入维保覆盖率1:是，2：否
let DEVICE_DETAIL_MANUFACTURER = Expression<String>("manufacturer")//制造厂商
let DEVICE_DETAIL_MANUFACTURINGNO = Expression<String>("manufacturingNo")//出厂编号
let DEVICE_DETAIL_METERREADING = Expression<Int64>("meterReading")//纳入抄表覆盖率1:是，2：否
let DEVICE_DETAIL_PID = Expression<Int64>("pid")//上级设备id
let DEVICE_DETAIL_PNAME = Expression<String>("pname")//上级设备名称
let DEVICE_DETAIL_PRODUCTIONDATE = Expression<Int64>("productionDate")//出厂日期
let DEVICE_DETAIL_PROJECTID = Expression<Int64>("projectId")//所属项目
let DEVICE_DETAIL_PROJECTNAME = Expression<String>("projectName")//项目名称
let DEVICE_DETAIL_REMARK = Expression<String>("remark")//备注
let DEVICE_DETAIL_RESPONSIBLEPERSON = Expression<String>("responsiblePerson")//负责人
let DEVICE_DETAIL_ROUTINGINSPECTION = Expression<Int64>("routingInspection")//纳入巡检覆盖率1;是，2：否
let DEVICE_DETAIL_SERVICEREGION = Expression<String>("serviceRegion")//服务区域
let DEVICE_DETAIL_SPACENAME = Expression<String>("spaceName")//位置名称
let DEVICE_DETAIL_SPECIALITY = Expression<Int64>("speciality")//专业
let DEVICE_DETAIL_SPECIALITYNAME = Expression<String>("specialityName")//专业名称
let DEVICE_DETAIL_SPECIFICATIONSMODEL = Expression<String>("specificationsModel")//规格型号
let DEVICE_DETAIL_STATUS = Expression<Int64>("status")//状态 1正常、2故障、3报废
let DEVICE_DETAIL_UBIETYADDRESS = Expression<Int64>("ubietyAddress")//所属地址
let DEVICE_DETAIL_UBIETYADDRESSSTR = Expression<String>("ubietyAddressStr")//所属地址名称
let DEVICE_DETAIL_UBIETYBUILDING = Expression<String>("ubietyBuilding")//所属楼栋
let DEVICE_DETAIL_UBIETYTYPE = Expression<Int64>("unitType")//设备类型
let DEVICE_DETAIL_UPDATETIME = Expression<Int64>("updateTime")//修改时间
let DEVICE_DETAIL_USESTATUS = Expression<Int64>("useStatus")//1启用、2停用、3备用、4计划停用
let DEVICE_DETAIL_USERID = Expression<Int64>("userId")//用户id
let DEVICE_DETAIL_USERNAME = Expression<String>("userName")//用户名字
let DEVICE_DETAIL_BIGUPDATEDATE = Expression<Int64>("bigUpdateDate")//大修时间
let DEVICE_DETAIL_BIGUPDATETEXT = Expression<String>("bigUpdateText")//大修内容
let DEVICE_DETAIL_UPDATERECORD = Expression<String>("updateRecord")//更新配件记录
let DEVICE_DETAIL_MAINTAINUNIT = Expression<String>("maintainUnit")//单位
let DEVICE_DETAIL_ISUPLOAD = Expression<Int64>("isUpload")//是否上传0:未上传，1:已上传

public class HDSQLiteManager: NSObject {

    var db: Connection!
    var dbPath:String = "";
    //单例
    public static let sharedInstance: HDSQLiteManager = {
        let sqlManager = HDSQLiteManager()
        return sqlManager
    }()

    // 登录前，连接登录信息数据库
    public func connectLoginDatabase() -> Void {
        let sqlFilePath = NSHomeDirectory() + "/Documents" + "/user_db.sqlite3"
        self.dbPath = sqlFilePath;
        
        do {
            db = try Connection(sqlFilePath)
            print("与登录信息数据库建立连接 成功")
        } catch {
            print("与登录信息数据库建立连接 失败：\(error)")
        }
    }
    
    // 登录后，根据个人id连接数据库
    public func connectPersonDatabase(userId: String) -> Void {
        let sqlFilePath = NSHomeDirectory() + "/Documents" + "/\(userId)_db.sqlite3"
        self.dbPath = sqlFilePath;
        
        do {
            db = try Connection(sqlFilePath)
            print("与个人数据库建立连接 成功")
        } catch {
            print("与个人数据库建立连接 失败：\(error)")
        }
    }
    
    //MARK: 判断表是否存在
    public func tableExists(_ tableName:String) -> Bool{
        if self.dbPath.count == 0 {
            return false;
        }
        let isExit = FileManager.default.fileExists(atPath: self.dbPath) ;
        if isExit == false {
            return false;
        }
        
        do {
            let expression = Table(tableName).expression
            let colunmnNames = try db.prepare(expression.template,expression.bindings).columnNames
            if colunmnNames.count == 0 {
                return false;
            }
        } catch {
            return false;
        }
        return true;
    }

    //MARK: 表中新增字段
    private func addColumn<V:Value>(table:Table,coluName:String,column:Expression<V>,defaultValue:V) {
        do {
            var isExist = false
            let expression = table.expression
            
            let colunmnNames = try db.prepare(expression.template,expression.bindings).columnNames
            for  colName in colunmnNames {
                if colName == coluName {
                    isExist = true
                    break
                }
            }
            
            if !isExist {
                do {
                    try db.run(table.addColumn(column, defaultValue:defaultValue))
                } catch {
                    print("插入表 \("table") :字段\("coluName")失败")
                }
            }
        } catch {
            print("插入表 \("table") :字段\("coluName")失败")
        }
    }
    
    //MARK:用户信息 建表
    public func loginTableLampCreate() -> Void {
        do {
            try db.run(LOGIN_TABLE_LAMP.create { table in
                table.column(LOGIN_TABLE_LAMP_ID, primaryKey: .autoincrement)
                table.column(LOGIN_TABLE_LAMP_NAME)
                table.column(LOGIN_TABLE_LAMP_PASSWORD)
                table.column(LOGIN_TABLE_LAMP_LOGINTYPE)
            })
            print("创建表 TABLE_LAMP 成功")
        } catch {
            print("创建表 TABLE_LAMP 失败：\(error)")
        }
    }

    // 插入用户
    public func loginTableLampInsertItem(name: String, password: String, loginType: Bool) -> Void {
        let selectArray = self.loginTableLampSelectItem(name: name)
        if selectArray.count > 0 {
            //已存有
            self.loginTableLampUpdatePassword(name: name, password: password)
            self.loginTableLampUpdateLoginType(name: name, loginType: loginType)
        } else {
            let insert = LOGIN_TABLE_LAMP.insert(LOGIN_TABLE_LAMP_NAME <- name, LOGIN_TABLE_LAMP_PASSWORD <- password, LOGIN_TABLE_LAMP_LOGINTYPE <- loginType)
            do {
                try db.transaction {
                    let rowid = try db.run(insert)
                    print("插入数据成功 id: \(rowid)")
                }
            } catch {
                print("插入数据失败tasksList: \(error)")
            }
        }
    }
    
    // 更新用户密码
    public func loginTableLampUpdatePassword(name: String, password: String) -> Void {
        let item = LOGIN_TABLE_LAMP.filter(LOGIN_TABLE_LAMP_NAME == name)
        do {
            if try db.run(item.update(LOGIN_TABLE_LAMP_PASSWORD <- password)) > 0 {
                print("\(name) 更新成功")
            } else {
                print("没有发现\(name)")
            }
        } catch {
            print("\(name) 更新失败：\(error)")
        }
    }
    
    // 更新用户登录状态
    public func loginTableLampUpdateLoginType(name: String, loginType: Bool) -> Void {
        let item = LOGIN_TABLE_LAMP.filter(LOGIN_TABLE_LAMP_NAME == name)
        do {
            if try db.run(item.update(LOGIN_TABLE_LAMP_LOGINTYPE <- loginType)) > 0 {
                print("\(name) 更新成功")
            } else {
                print("没有发现\(name)")
            }
        } catch {
            print("\(name) 更新失败：\(error)")
        }
    }
    
    //插入前排查是否数据库存有
    public func loginTableLampSelectItem(name: String) -> NSArray {
        let queryArray: NSMutableArray = NSMutableArray()
        for item in try! db.prepare(LOGIN_TABLE_LAMP.filter(LOGIN_TABLE_LAMP_NAME == name)) {
            let dic = ["phone": item[LOGIN_TABLE_LAMP_NAME],
                       "password": item[LOGIN_TABLE_LAMP_PASSWORD],
                "loginType": item[LOGIN_TABLE_LAMP_LOGINTYPE]] as NSDictionary
    
            queryArray.add(dic);
            
        }
        return queryArray
    }
    
    // 删除
    public func loginTableLampDeleteItem(name: String) -> Void {
        let item = LOGIN_TABLE_LAMP.filter(LOGIN_TABLE_LAMP_NAME == name)
        do {
            if try db.run(item.delete()) > 0 {
                print("\(name) 删除成功")
            } else {
                print("没有发现\(name)")
            }
        } catch {
            print("\(name) 删除失败：\(error)")
        }
    }
    
    //所有用户
    public func loginQueryTableLamp() -> [JSON] {
        var queryArray = [JSON]()
        for item in try! db.prepare(LOGIN_TABLE_LAMP.limit(100, offset: 0)) {
            let dic = ["id": item[LOGIN_TABLE_LAMP_ID], "phone": item[LOGIN_TABLE_LAMP_NAME], "password": item[LOGIN_TABLE_LAMP_PASSWORD], "loginType": item[LOGIN_TABLE_LAMP_LOGINTYPE]] as [String : Any]
            let dataJson = JSON(dic)
            queryArray.append(dataJson)
            print("所有用户 ———— id: \(item[LOGIN_TABLE_LAMP_ID]), name: \(item[LOGIN_TABLE_LAMP_NAME]), password: \(item[LOGIN_TABLE_LAMP_PASSWORD])")
        }
        return queryArray
    }
    
    // MARK: 登陆者组织下的项目列表
    public func projectsListTableLampCreate() -> Void {
        do {
            try db.run(PROJECT_LIST_TABLE.create { table in
                table.column(PROJECT_LIST_TABLE_ID, primaryKey: .autoincrement)
                table.column(PROJECT_LIST_PROJECTID)
                table.column(PROJECT_LIST_PROJECTNAME)
                table.column(PROJECT_LIST_PROJECTIDENTIFICATION)
                table.column(PROJECT_LIST_ORGID)
                table.column(PROJECT_LIST_ORGNAME)
            })
            
        } catch {
            print("创建表 TABLE_LAMP 失败：\(error)")
        }
     
//        self.addColumn(table: TASKS_LIST_TABLE, coluName: "time", column: TASKS_LIST_TABLE_TIME, defaultValue: "")
    }
   
    // 插入
    public func projectsListTableLampInsertItem(projectId: Int64, projectName: String, projectIdentification: String, orgId: Int64, orgName: String) -> Void {

        let selectArray = self.projectsListTableLampSelectItem(projectId: projectId, orgId: orgId);
        if selectArray.count > 0 {
            //已存有
            return;
        }

        let insert = PROJECT_LIST_TABLE.insert(PROJECT_LIST_PROJECTID <- projectId, PROJECT_LIST_PROJECTNAME <- projectName, PROJECT_LIST_PROJECTIDENTIFICATION <- projectIdentification, PROJECT_LIST_ORGID <- orgId, PROJECT_LIST_ORGNAME <- orgName)
        do {
            try db.transaction {
                let rowid = try db.run(insert)
                print("插入数据成功 id: \(rowid)")
            }
        } catch {
            print("插入数据失败tasksList: \(error)")
        }
    }
    
    //插入前排查是否数据库存有
    public func projectsListTableLampSelectItem(projectId: Int64, orgId: Int64) -> NSArray {
        
        let queryArray:NSMutableArray = NSMutableArray()
        
        for item in try! db.prepare(PROJECT_LIST_TABLE.filter(PROJECT_LIST_PROJECTID == projectId && PROJECT_LIST_ORGID == orgId)) {
            let dic = [
                       "projectId": item[PROJECT_LIST_PROJECTID],
                       "projectName": item[PROJECT_LIST_PROJECTNAME],
                       "projectIdentification": item[PROJECT_LIST_PROJECTIDENTIFICATION],
                       "orgId": item[PROJECT_LIST_ORGID],
                       "orgName": item[PROJECT_LIST_ORGNAME]] as NSDictionary
    
            queryArray.add(dic);
            
        }
        return queryArray
    }
    
    //查询所有本地任务
    public func projectsListTableLampSelectAllItem(searchText: String) -> NSArray {
        let queryArray:NSMutableArray = NSMutableArray()
        
        if searchText == "" {
            for item in try! db.prepare(PROJECT_LIST_TABLE) {
                let dic = [
                    "projectId": item[PROJECT_LIST_PROJECTID],
                    "projectName": item[PROJECT_LIST_PROJECTNAME],
                    "projectIdentification": item[PROJECT_LIST_PROJECTIDENTIFICATION],
                    "orgId": item[PROJECT_LIST_ORGID],
                    "orgName": item[PROJECT_LIST_ORGNAME]] as NSDictionary
        
                queryArray.add(dic);
            }
        } else {
            
        }
        return queryArray
    }
    
    // MARK: 项目列表下的专业
    public func professionalsListTableLampCreate() -> Void {
        do {
            try db.run(PROFESSIONAL_LIST_TABLE.create { table in
                table.column(PROFESSIONAL_LIST_TABLE_ID, primaryKey: .autoincrement)
                table.column(PROFESSIONAL_LIST_DID)
                table.column(PROFESSIONAL_LIST_NAME)
                table.column(PROFESSIONAL_LIST_CHARACTER)
                table.column(PROFESSIONAL_LIST_ORDER)
                table.column(PROFESSIONAL_LIST_STATUS)
                table.column(PROFESSIONAL_LIST_CREATETIME)
                table.column(PROFESSIONAL_LIST_UPDATETIME)
            })
            
        } catch {
            print("创建表 TABLE_LAMP 失败：\(error)")
        }
     
//        self.addColumn(table: TASKS_LIST_TABLE, coluName: "time", column: TASKS_LIST_TABLE_TIME, defaultValue: "")
    }
   
    // 插入
    public func professionalsListTableLampInsertItem(did: Int64, name: String, character: String, order: Int64, status: Int64, createTime: Int64, updateTime: Int64) -> Void {

        let selectArray = self.professionalsListTableLampSelectItem(did: did);
        if selectArray.count > 0 {
            //已存有
            return;
        }

        let insert = PROFESSIONAL_LIST_TABLE.insert(PROFESSIONAL_LIST_DID <- did, PROFESSIONAL_LIST_NAME <- name, PROFESSIONAL_LIST_CHARACTER <- character, PROFESSIONAL_LIST_ORDER <- order, PROFESSIONAL_LIST_STATUS <- status, PROFESSIONAL_LIST_CREATETIME <- createTime, PROFESSIONAL_LIST_UPDATETIME <- updateTime)
        do {
            try db.transaction {
                let rowid = try db.run(insert)
                print("插入数据成功 id: \(rowid)")
            }
        } catch {
            print("插入数据失败tasksList: \(error)")
        }
    }
    
    //插入前排查是否数据库存有
    public func professionalsListTableLampSelectItem(did: Int64) -> NSArray {
        
        let queryArray:NSMutableArray = NSMutableArray()
        
        for item in try! db.prepare(PROFESSIONAL_LIST_TABLE.filter(PROFESSIONAL_LIST_DID == did)) {
            let dic = [
                       "id": item[PROFESSIONAL_LIST_DID],
                       "name": item[PROFESSIONAL_LIST_NAME],
                       "character": item[PROFESSIONAL_LIST_CHARACTER],
                       "order": item[PROFESSIONAL_LIST_ORDER],
                       "status": item[PROFESSIONAL_LIST_STATUS],
                       "createTime": item[PROFESSIONAL_LIST_CREATETIME],
                       "updateTime": item[PROFESSIONAL_LIST_UPDATETIME]] as NSDictionary
    
            queryArray.add(dic);
            
        }
        return queryArray
    }
    
    //查询所有
    public func professionalsListTableLampSelectAllItem() -> NSArray {
        let queryArray:NSMutableArray = NSMutableArray()
        
        for item in try! db.prepare(PROFESSIONAL_LIST_TABLE) {
            let dic = [
                "id": item[PROFESSIONAL_LIST_DID],
                "name": item[PROFESSIONAL_LIST_NAME],
                "character": item[PROFESSIONAL_LIST_CHARACTER],
                "order": item[PROFESSIONAL_LIST_ORDER],
                "status": item[PROFESSIONAL_LIST_STATUS],
                "createTime": item[PROFESSIONAL_LIST_CREATETIME],
                "updateTime": item[PROFESSIONAL_LIST_UPDATETIME]] as NSDictionary
    
            queryArray.add(dic);
        }
        return queryArray
    }
    
    // MARK: 专业下的设备或部位
    public func devicesListTableLampCreate() -> Void {
        do {
            try db.run(DEVICES_LIST_TABLE.create { table in
                table.column(DEVICES_LIST_TABLE_ID, primaryKey: .autoincrement)
                table.column(DEVICES_LIST_DID)
                table.column(DEVICES_LIST_NAME)
                table.column(DEVICES_LIST_ORDER)
                table.column(DEVICES_LIST_SPECIALTYID)
                table.column(DEVICES_LIST_SPECIALTYNAME)
                table.column(DEVICES_LIST_STATUS)
                table.column(DEVICES_LIST_ISEDIT)
                table.column(DEVICES_LIST_CREATETIME)
                table.column(DEVICES_LIST_UPDATETIME)
            })
            
        } catch {
            print("创建表 TABLE_LAMP 失败：\(error)")
        }
     
//        self.addColumn(table: TASKS_LIST_TABLE, coluName: "time", column: TASKS_LIST_TABLE_TIME, defaultValue: "")
    }
       
    // 插入
    public func devicesListTableLampInsertItem(did: Int64, name: String, order: Int64, specialtyId: Int64, specialtyName: String, status: Int64, isEdit: Int64, createTime: Int64, updateTime: Int64) -> Void {

        let selectArray = self.devicesListTableLampSelectItem(did: did, specialtyId: specialtyId);
        if selectArray.count > 0 {
            //已存有
            return;
        }

        let insert = DEVICES_LIST_TABLE.insert(DEVICES_LIST_DID <- did, DEVICES_LIST_NAME <- name, DEVICES_LIST_ORDER <- order, DEVICES_LIST_SPECIALTYID <- specialtyId, DEVICES_LIST_SPECIALTYNAME <- specialtyName, DEVICES_LIST_STATUS <- status, DEVICES_LIST_ISEDIT <- isEdit, DEVICES_LIST_CREATETIME <- createTime, DEVICES_LIST_UPDATETIME <- updateTime)
        do {
            try db.transaction {
                let rowid = try db.run(insert)
                print("插入数据成功 id: \(rowid)")
            }
        } catch {
            print("插入数据失败tasksList: \(error)")
        }
    }
        
    //插入前排查是否数据库存有
    public func devicesListTableLampSelectItem(did: Int64, specialtyId: Int64) -> NSArray {
        
        let queryArray:NSMutableArray = NSMutableArray()
        
        for item in try! db.prepare(DEVICES_LIST_TABLE.filter(DEVICES_LIST_DID == did && DEVICES_LIST_SPECIALTYID == specialtyId)) {
            let dic = [
                       "id": item[DEVICES_LIST_DID],
                       "name": item[DEVICES_LIST_NAME],
                       "order": item[DEVICES_LIST_ORDER],
                       "specialtyId": item[DEVICES_LIST_SPECIALTYID],
                       "specialtyName": item[DEVICES_LIST_SPECIALTYNAME],
                       "status": item[DEVICES_LIST_STATUS],
                       "isEdit": item[DEVICES_LIST_ISEDIT],
                       "createTime": item[DEVICES_LIST_CREATETIME],
                       "updateTime": item[DEVICES_LIST_UPDATETIME]] as NSDictionary
    
            queryArray.add(dic);
            
        }
        return queryArray
    }
        
    //查询所有
    public func devicesListTableLampSelectAllItem(specialtyId: Int64) -> NSArray {
        let queryArray:NSMutableArray = NSMutableArray()
        
        for item in try! db.prepare(DEVICES_LIST_TABLE.filter(DEVICES_LIST_SPECIALTYID == specialtyId)) {
            let dic = [
                "id": item[DEVICES_LIST_DID],
                "name": item[DEVICES_LIST_NAME],
                "order": item[DEVICES_LIST_ORDER],
                "specialtyId": item[DEVICES_LIST_SPECIALTYID],
                "specialtyName": item[DEVICES_LIST_SPECIALTYNAME],
                "status": item[DEVICES_LIST_STATUS],
                "isEdit": item[DEVICES_LIST_ISEDIT],
                "createTime": item[DEVICES_LIST_CREATETIME],
                "updateTime": item[DEVICES_LIST_UPDATETIME]] as NSDictionary
    
            queryArray.add(dic);
        }
        return queryArray
    }
    
      
    // MARK: 设备或部位下的配置字典
    public func equipmentPositionListTableLampCreate() -> Void {
        do {
            try db.run(EQUIPMENTPOSITION_LIST_TABLE.create { table in
                table.column(EQUIPMENTPOSITION_LIST_TABLE_ID, primaryKey: .autoincrement)
                table.column(EQUIPMENTPOSITION_LIST_DID)
                table.column(EQUIPMENTPOSITION_LIST_PROPOSE)
                table.column(EQUIPMENTPOSITION_LIST_ORDER)
                table.column(EQUIPMENTPOSITION_LIST_DICTYPE)
                table.column(EQUIPMENTPOSITION_LIST_EXAMINETYPE)
                table.column(EQUIPMENTPOSITION_LIST_EQUIPMENTPOSITIONID)
                table.column(EQUIPMENTPOSITION_LIST_STATUS)
                table.column(EQUIPMENTPOSITION_LIST_CREATETIME)
                table.column(EQUIPMENTPOSITION_LIST_UPDATETIME)
            })
            
        } catch {
            print("创建表 TABLE_LAMP 失败：\(error)")
        }
     
//        self.addColumn(table: TASKS_LIST_TABLE, coluName: "time", column: TASKS_LIST_TABLE_TIME, defaultValue: "")
    }
           
    // 插入
    public func equipmentPositionListTableLampInsertItem(did: Int64, propose: String, order: Int64, dicType: Int64, examineType: Int64, equipmentPositionId: Int64, status: Int64, createTime: Int64, updateTime: Int64) -> Void {

        let selectArray = self.equipmentPositionListTableLampSelectItem(did: did, dicType: dicType, equipmentPositionId: equipmentPositionId);
        if selectArray.count > 0 {
            //已存有
            return;
        }

        let insert = EQUIPMENTPOSITION_LIST_TABLE.insert(EQUIPMENTPOSITION_LIST_DID <- did, EQUIPMENTPOSITION_LIST_PROPOSE <- propose, EQUIPMENTPOSITION_LIST_ORDER <- order, EQUIPMENTPOSITION_LIST_DICTYPE <- dicType, EQUIPMENTPOSITION_LIST_EXAMINETYPE <- examineType, EQUIPMENTPOSITION_LIST_EQUIPMENTPOSITIONID <- equipmentPositionId, EQUIPMENTPOSITION_LIST_STATUS <- status, EQUIPMENTPOSITION_LIST_CREATETIME <- createTime, EQUIPMENTPOSITION_LIST_UPDATETIME <- updateTime)
        do {
            try db.transaction {
                let rowid = try db.run(insert)
                print("插入数据成功 id: \(rowid)")
            }
        } catch {
            print("插入数据失败tasksList: \(error)")
        }
    }
            
    //插入前排查是否数据库存有
    public func equipmentPositionListTableLampSelectItem(did: Int64, dicType: Int64, equipmentPositionId: Int64) -> NSArray {
        
        let queryArray:NSMutableArray = NSMutableArray()
        
        for item in try! db.prepare(EQUIPMENTPOSITION_LIST_TABLE.filter(EQUIPMENTPOSITION_LIST_DID == did && EQUIPMENTPOSITION_LIST_DICTYPE == dicType && EQUIPMENTPOSITION_LIST_EQUIPMENTPOSITIONID == equipmentPositionId)) {
            let dic = [
                       "id": item[EQUIPMENTPOSITION_LIST_DID],
                       "propose": item[EQUIPMENTPOSITION_LIST_PROPOSE],
                       "order": item[EQUIPMENTPOSITION_LIST_ORDER],
                       "dicType": item[EQUIPMENTPOSITION_LIST_DICTYPE],
                       "examineType": item[EQUIPMENTPOSITION_LIST_EXAMINETYPE],
                       "equipmentPositionId": item[EQUIPMENTPOSITION_LIST_EQUIPMENTPOSITIONID],
                       "status": item[EQUIPMENTPOSITION_LIST_STATUS],
                       "createTime": item[EQUIPMENTPOSITION_LIST_CREATETIME],
                       "updateTime": item[EQUIPMENTPOSITION_LIST_UPDATETIME]] as NSDictionary
    
            queryArray.add(dic);
            
        }
        return queryArray
    }
            
    //查询所有
    public func equipmentPositionListTableLampSelectAllItem(dicType: Int64, equipmentPositionId: Int64, examineType: Int64) -> NSArray {
        let queryArray:NSMutableArray = NSMutableArray()
        
        if examineType == -1 {
            //所有
            for item in try! db.prepare(EQUIPMENTPOSITION_LIST_TABLE.filter(EQUIPMENTPOSITION_LIST_DICTYPE == 1 && EQUIPMENTPOSITION_LIST_EQUIPMENTPOSITIONID == equipmentPositionId)) {
                    let dic = [
                            "id": item[EQUIPMENTPOSITION_LIST_DID],
                            "propose": item[EQUIPMENTPOSITION_LIST_PROPOSE],
                            "order": item[EQUIPMENTPOSITION_LIST_ORDER],
                            "dicType": item[EQUIPMENTPOSITION_LIST_DICTYPE],
                            "examineType": item[EQUIPMENTPOSITION_LIST_EXAMINETYPE],
                            "equipmentPositionId": item[EQUIPMENTPOSITION_LIST_EQUIPMENTPOSITIONID],
                            "status": item[EQUIPMENTPOSITION_LIST_STATUS],
                            "createTime": item[EQUIPMENTPOSITION_LIST_CREATETIME],
                            "updateTime": item[EQUIPMENTPOSITION_LIST_UPDATETIME]] as NSDictionary
            
                    queryArray.add(dic);
                }
        } else {
            for item in try! db.prepare(EQUIPMENTPOSITION_LIST_TABLE.filter(EQUIPMENTPOSITION_LIST_DICTYPE == dicType && EQUIPMENTPOSITION_LIST_EQUIPMENTPOSITIONID == equipmentPositionId && EQUIPMENTPOSITION_LIST_EXAMINETYPE == examineType)) {
                    let dic = [
                            "id": item[EQUIPMENTPOSITION_LIST_DID],
                            "propose": item[EQUIPMENTPOSITION_LIST_PROPOSE],
                            "order": item[EQUIPMENTPOSITION_LIST_ORDER],
                            "dicType": item[EQUIPMENTPOSITION_LIST_DICTYPE],
                            "examineType": item[EQUIPMENTPOSITION_LIST_EXAMINETYPE],
                            "equipmentPositionId": item[EQUIPMENTPOSITION_LIST_EQUIPMENTPOSITIONID],
                            "status": item[EQUIPMENTPOSITION_LIST_STATUS],
                            "createTime": item[EQUIPMENTPOSITION_LIST_CREATETIME],
                            "updateTime": item[EQUIPMENTPOSITION_LIST_UPDATETIME]] as NSDictionary
            
                    queryArray.add(dic);
                }
        }
        
        return queryArray
    }
    
    //MARK: 数据字典
    public func dataDictionarysListTableLampCreate() -> Void {
        do {
            try db.run(DATADICTIONARYS_LIST_TABLE.create { table in
                table.column(DATADICTIONARYS_LIST_TABLE_ID, primaryKey: .autoincrement)
                table.column(DATADICTIONARYS_LIST_DID)
                table.column(DATADICTIONARYS_LIST_CODE)
                table.column(DATADICTIONARYS_LIST_NAME)
                table.column(DATADICTIONARYS_LIST_ORDER)
                table.column(DATADICTIONARYS_LIST_LEVEL)
                table.column(DATADICTIONARYS_LIST_PID)
                table.column(DATADICTIONARYS_LIST_PIDNAME)
                table.column(DATADICTIONARYS_LIST_STATUS)
                table.column(DATADICTIONARYS_LIST_CREATETIME)
                table.column(DATADICTIONARYS_LIST_UPDATETIME)
            })
            
        } catch {
            print("创建表 TABLE_LAMP 失败：\(error)")
        }
     
//        self.addColumn(table: TASKS_LIST_TABLE, coluName: "time", column: TASKS_LIST_TABLE_TIME, defaultValue: "")
    }
       
    // 插入
    public func dataDictionarysListTableLampInsertItem(did: Int64, code: String, name: String, order: Int64, level: Int64, pid: Int64, pidName: String, status: Int64, createTime: Int64, updateTime: Int64) -> Void {

        let selectArray = self.dataDictionarysListTableLampSelectItem(did: did, code: code);
        if selectArray.count > 0 {
            //已存有
            return;
        }

        let insert = DATADICTIONARYS_LIST_TABLE.insert(DATADICTIONARYS_LIST_DID <- did, DATADICTIONARYS_LIST_CODE <- code, DATADICTIONARYS_LIST_NAME <- name, DATADICTIONARYS_LIST_ORDER <- order, DATADICTIONARYS_LIST_LEVEL <- level, DATADICTIONARYS_LIST_PID <- pid, DATADICTIONARYS_LIST_PIDNAME <- pidName, DATADICTIONARYS_LIST_STATUS <- status, DATADICTIONARYS_LIST_CREATETIME <- createTime, DATADICTIONARYS_LIST_UPDATETIME <- updateTime)
        do {
            try db.transaction {
                let rowid = try db.run(insert)
                print("插入数据成功 id: \(rowid)")
            }
        } catch {
            print("插入数据失败tasksList: \(error)")
        }
    }
        
    //插入前排查是否数据库存有
    public func dataDictionarysListTableLampSelectItem(did: Int64, code: String) -> NSArray {
        
        let queryArray:NSMutableArray = NSMutableArray()
        
        for item in try! db.prepare(DATADICTIONARYS_LIST_TABLE.filter(DATADICTIONARYS_LIST_DID == did && DATADICTIONARYS_LIST_CODE == code)) {
            let dic = [
                       "id": item[DATADICTIONARYS_LIST_DID],
                       "code": item[DATADICTIONARYS_LIST_CODE],
                       "name": item[DATADICTIONARYS_LIST_NAME],
                       "order": item[DATADICTIONARYS_LIST_ORDER],
                       "level": item[DATADICTIONARYS_LIST_LEVEL],
                       "pid": item[DATADICTIONARYS_LIST_PID],
                       "pidName": item[DATADICTIONARYS_LIST_PIDNAME],
                       "status": item[DATADICTIONARYS_LIST_STATUS],
                       "createTime": item[DATADICTIONARYS_LIST_CREATETIME],
                       "updateTime": item[DATADICTIONARYS_LIST_UPDATETIME]] as NSDictionary
    
            queryArray.add(dic);
            
        }
        return queryArray
    }
        
    //查询所有
    public func dataDictionarysListTableLampSelectAllItem(code: String) -> NSArray {
        let queryArray:NSMutableArray = NSMutableArray()
        
        for item in try! db.prepare(DATADICTIONARYS_LIST_TABLE.filter(DATADICTIONARYS_LIST_CODE == code)) {
            let dic = [
                "id": item[DATADICTIONARYS_LIST_DID],
                "code": item[DATADICTIONARYS_LIST_CODE],
                "name": item[DATADICTIONARYS_LIST_NAME],
                "order": item[DATADICTIONARYS_LIST_ORDER],
                "level": item[DATADICTIONARYS_LIST_LEVEL],
                "pid": item[DATADICTIONARYS_LIST_PID],
                "pidName": item[DATADICTIONARYS_LIST_PIDNAME],
                "status": item[DATADICTIONARYS_LIST_STATUS],
                "createTime": item[DATADICTIONARYS_LIST_CREATETIME],
                "updateTime": item[DATADICTIONARYS_LIST_UPDATETIME]] as NSDictionary
    
            queryArray.add(dic);
        }
        return queryArray
    }
    
      
    //MARK: 空间
    public func spaceTreesListTableLampCreate() -> Void {
        do {
            try db.run(SPACETREES_LIST_TABLE.create { table in
                table.column(SPACETREES_LIST_TABLE_ID, primaryKey: .autoincrement)
                table.column(SPACETREES_LIST_DID)
                table.column(SPACETREES_LIST_NAME)
                table.column(SPACETREES_LIST_PID)
                table.column(SPACETREES_LIST_PNAME)
                table.column(SPACETREES_LIST_PROJECTID)
                table.column(SPACETREES_LIST_PROJECTNAME)
                table.column(SPACETREES_LIST_ORGID)
                table.column(SPACETREES_LIST_CREATETIME)
                table.column(SPACETREES_LIST_UPDATETIME)
                table.column(SPACETREES_LIST_ISLOAD)
            })
            
        } catch {
            print("创建表 TABLE_LAMP 失败：\(error)")
        }
     
//        self.addColumn(table: TASKS_LIST_TABLE, coluName: "time", column: TASKS_LIST_TABLE_TIME, defaultValue: "")
    }
           
    // 插入
    public func spaceTreesListTableLampInsertItem(did: Int64, name: String, pid: Int64, pname: String, projectId: Int64, projectName: String, orgId: Int64, createTime: Int64, updateTime: Int64, isLoad: String) -> Void {

        let selectArray = self.spaceTreesListTableLampSelectItem(did: did/*, orgId: orgId*/, projectId: projectId);
        if selectArray.count > 0 {
            //已存有
            return;
        }

        let insert = SPACETREES_LIST_TABLE.insert(SPACETREES_LIST_DID <- did, SPACETREES_LIST_NAME <- name, SPACETREES_LIST_PID <- pid, SPACETREES_LIST_PNAME <- pname, SPACETREES_LIST_PROJECTID <- projectId, SPACETREES_LIST_PROJECTNAME <- projectName, SPACETREES_LIST_ORGID <- orgId, SPACETREES_LIST_CREATETIME <- createTime, SPACETREES_LIST_UPDATETIME <- updateTime, SPACETREES_LIST_ISLOAD <- isLoad)
        do {
            try db.transaction {
                let rowid = try db.run(insert)
                print("插入数据成功 id: \(rowid)")
            }
        } catch {
            print("插入数据失败tasksList: \(error)")
        }
    }
            
    //插入前排查是否数据库存有
    public func spaceTreesListTableLampSelectItem(did: Int64/*, orgId: Int64*/, projectId: Int64) -> NSArray {
        
        let queryArray:NSMutableArray = NSMutableArray()
        
        for item in try! db.prepare(SPACETREES_LIST_TABLE.filter(SPACETREES_LIST_DID == did /*&& SPACETREES_LIST_ORGID == orgId*/ && SPACETREES_LIST_PROJECTID == projectId)) {
            let dic = [
                       "id": item[SPACETREES_LIST_DID],
                       "name": item[SPACETREES_LIST_NAME],
                       "pid": item[SPACETREES_LIST_PID],
                       "pname": item[SPACETREES_LIST_PNAME],
                       "projectId": item[SPACETREES_LIST_PROJECTID],
                       "projectName": item[SPACETREES_LIST_PROJECTNAME],
                       "orgId": item[SPACETREES_LIST_ORGID],
                       "createTime": item[SPACETREES_LIST_CREATETIME],
                       "updateTime": item[SPACETREES_LIST_UPDATETIME],
                       "isLoad": item[SPACETREES_LIST_ISLOAD]] as NSDictionary
    
            queryArray.add(dic);
            
        }
        return queryArray
    }
            
    //查询所有
    public func spaceTreesListTableLampSelectAllItem(projectId: Int64) -> NSArray {
        let queryArray:NSMutableArray = NSMutableArray()
        
        if projectId != -1 {
            //根据项目搜索
            for item in try! db.prepare(SPACETREES_LIST_TABLE.filter(SPACETREES_LIST_PROJECTID == projectId)) {
                let dic = [
                            "id": item[SPACETREES_LIST_DID],
                            "iid": item[SPACETREES_LIST_TABLE_ID],
                            "name": item[SPACETREES_LIST_NAME],
                            "pid": item[SPACETREES_LIST_PID],
                            "pname": item[SPACETREES_LIST_PNAME],
                            "projectId": item[SPACETREES_LIST_PROJECTID],
                            "projectName": item[SPACETREES_LIST_PROJECTNAME],
                            "orgId": item[SPACETREES_LIST_ORGID],
                            "createTime": item[SPACETREES_LIST_CREATETIME],
                            "updateTime": item[SPACETREES_LIST_UPDATETIME],
                            "isLoad": item[SPACETREES_LIST_ISLOAD]] as NSDictionary
        
                queryArray.add(dic);
            }
        } else {
            //搜索所有
            for item in try! db.prepare(SPACETREES_LIST_TABLE) {
                let dic = [
                            "id": item[SPACETREES_LIST_DID],
                            "iid": item[SPACETREES_LIST_TABLE_ID],
                            "name": item[SPACETREES_LIST_NAME],
                            "pid": item[SPACETREES_LIST_PID],
                            "pname": item[SPACETREES_LIST_PNAME],
                            "projectId": item[SPACETREES_LIST_PROJECTID],
                            "projectName": item[SPACETREES_LIST_PROJECTNAME],
                            "orgId": item[SPACETREES_LIST_ORGID],
                            "createTime": item[SPACETREES_LIST_CREATETIME],
                            "updateTime": item[SPACETREES_LIST_UPDATETIME],
                            "isLoad": item[SPACETREES_LIST_ISLOAD]] as NSDictionary
        
                queryArray.add(dic);
            }
        }
        
        return queryArray
    }
    
    public func spaceTreesTableLampUpdateItem(_ id: Int64, _ projectId: Int64, _ did: Int64) -> Void {
        let item = SPACETREES_LIST_TABLE.filter(SPACETREES_LIST_TABLE_ID == id && SPACETREES_LIST_PROJECTID == projectId);
        do {
            if try db.run(item.update(SPACETREES_LIST_ISLOAD <- "1",SPACETREES_LIST_DID <- did)) > 0 {
                
            }
        } catch {
            print("问题更新失败")
        }
    }
    
    public func spaceTreesTableLampUpdatePidItem(_ pid: Int64, _ projectId: Int64, _ did: Int64) -> Void {
        let item = SPACETREES_LIST_TABLE.filter(SPACETREES_LIST_PID == pid && SPACETREES_LIST_PROJECTID == projectId);
        do {
            if try db.run(item.update(SPACETREES_LIST_PID <- did)) > 0 {
                
            }
        } catch {
            print("问题更新失败")
        }
    }
          
    //MARK: 未上传的问题
    public func questionsListTableLampCreate() -> Void {
        do {
            try db.run(QUESTIONS_LIST_TABLE.create { table in
                table.column(QUESTIONS_LIST_TABLE_ID, primaryKey: .autoincrement)
                table.column(QUESTIONS_LIST_PROJECTID)
                table.column(QUESTIONS_LIST_PROJECTNAME)
                table.column(QUESTIONS_LIST_PROJECTNUMBER)
                table.column(QUESTIONS_LIST_SPACEADDRESS)
                table.column(QUESTIONS_LIST_SPACEADDRESSNAME)
                table.column(QUESTIONS_LIST_MAJOR)
                table.column(QUESTIONS_LIST_MAJORNAME)
                table.column(QUESTIONS_LIST_MAJORCODE)
                table.column(QUESTIONS_LIST_EQUIPMENTID)
                table.column(QUESTIONS_LIST_EQUIPMENTORPART)
                table.column(QUESTIONS_LIST_CHECKTYPE)
                table.column(QUESTIONS_LIST_QUESTIONDESCRIBE)
                table.column(QUESTIONS_LIST_HARM)
                table.column(QUESTIONS_LIST_MEASURES)
                table.column(QUESTIONS_LIST_QUESTIONCATEGORYID)
                table.column(QUESTIONS_LIST_QUESTIONCATEGORY)
                table.column(QUESTIONS_LIST_QUESTIONPROPERTYID)
                table.column(QUESTIONS_LIST_QUESTIONPROPERTY)
                table.column(QUESTIONS_LIST_EMERGENCYID)
                table.column(QUESTIONS_LIST_EMERGENCY)
                table.column(QUESTIONS_LIST_QUESTIONREASONID)
                table.column(QUESTIONS_LIST_QUESTIONREASON)
                table.column(QUESTIONS_LIST_ESTIMATEDDIFFICULTYID)
                table.column(QUESTIONS_LIST_ESTIMATEDDIFFICULTY)
                table.column(QUESTIONS_LIST_SUGGESTRECTIFICATIONPARTYID)
                table.column(QUESTIONS_LIST_SUGGESTRECTIFICATIONPARTY)
                table.column(QUESTIONS_LIST_ESTIMATEDAMOUNT)
                table.column(QUESTIONS_LIST_IMAGE)
                table.column(QUESTIONS_LIST_UPDATETIME)
                table.column(QUESTIONS_LIST_ISLOAD)
            })
            
        } catch {
            print("创建表 TABLE_LAMP 失败：\(error)")
        }
     
//        self.addColumn(table: TASKS_LIST_TABLE, coluName: "time", column: TASKS_LIST_TABLE_TIME, defaultValue: "")
    }
               
    // 插入
    public func questionsListTableLampInsertItem(projectId: Int64, projectName: String, projectNumber: String, spaceAddress: Int64, spaceAddressName: String, major: Int64, majorName: String, majorCode: String, equipmentId: Int64, equipmentOrPart: String, checkType: Int64, questionDescribe: String, harm: String, measures: String, questionCategoryId: Int64, questionCategory: String, questionPropertyId: Int64, questionProperty: String, emergencyId: Int64, emergency: String, questionReasonId: Int64, questionReason: String, estimatedDifficultyId: Int64, estimatedDifficulty: String, suggestRectificationPartyId: Int64, suggestRectificationParty: String, estimatedAmount: String, image: String, updateTime: String, isLoad: String) -> Void {

        let insert = QUESTIONS_LIST_TABLE.insert(QUESTIONS_LIST_PROJECTID <- projectId, QUESTIONS_LIST_PROJECTNAME <- projectName, QUESTIONS_LIST_PROJECTNUMBER <- projectNumber, QUESTIONS_LIST_SPACEADDRESS <- spaceAddress, QUESTIONS_LIST_SPACEADDRESSNAME <- spaceAddressName, QUESTIONS_LIST_MAJOR <- major, QUESTIONS_LIST_MAJORNAME <- majorName, QUESTIONS_LIST_MAJORCODE <- majorCode, QUESTIONS_LIST_EQUIPMENTID <- equipmentId, QUESTIONS_LIST_EQUIPMENTORPART <- equipmentOrPart, QUESTIONS_LIST_CHECKTYPE <- checkType, QUESTIONS_LIST_QUESTIONDESCRIBE <- questionDescribe, QUESTIONS_LIST_HARM <- harm, QUESTIONS_LIST_MEASURES <- measures, QUESTIONS_LIST_QUESTIONCATEGORYID <- questionCategoryId, QUESTIONS_LIST_QUESTIONCATEGORY <- questionCategory, QUESTIONS_LIST_QUESTIONPROPERTYID <- questionPropertyId, QUESTIONS_LIST_QUESTIONPROPERTY <- questionProperty, QUESTIONS_LIST_EMERGENCYID <- emergencyId, QUESTIONS_LIST_EMERGENCY <- emergency, QUESTIONS_LIST_QUESTIONREASONID <- questionReasonId, QUESTIONS_LIST_QUESTIONREASON <- questionReason, QUESTIONS_LIST_ESTIMATEDDIFFICULTYID <- estimatedDifficultyId,QUESTIONS_LIST_ESTIMATEDDIFFICULTY <- estimatedDifficulty, QUESTIONS_LIST_SUGGESTRECTIFICATIONPARTYID <- suggestRectificationPartyId,QUESTIONS_LIST_SUGGESTRECTIFICATIONPARTY <- suggestRectificationParty, QUESTIONS_LIST_ESTIMATEDAMOUNT <- estimatedAmount, QUESTIONS_LIST_IMAGE <- image, QUESTIONS_LIST_UPDATETIME <- updateTime, QUESTIONS_LIST_ISLOAD <- isLoad)
        do {
            try db.transaction {
                let rowid = try db.run(insert)
                print("插入数据成功 id: \(rowid)")
            }
        } catch {
            print("插入数据失败tasksList: \(error)")
        }
    }
                
                
    //查询所有
    public func questionsListTableLampSelectAllItem() -> NSArray {
        let queryArray:NSMutableArray = NSMutableArray()
        
        for item in try! db.prepare(QUESTIONS_LIST_TABLE) {
            let dic = [
                        "id": item[QUESTIONS_LIST_TABLE_ID],
                        "projectId": item[QUESTIONS_LIST_PROJECTID],
                        "projectName": item[QUESTIONS_LIST_PROJECTNAME],
                        "projectNumber": item[QUESTIONS_LIST_PROJECTNUMBER],
                        "spaceAddress": item[QUESTIONS_LIST_SPACEADDRESS],
                        "spaceAddressName": item[QUESTIONS_LIST_SPACEADDRESSNAME],
                        "major": item[QUESTIONS_LIST_MAJOR],
                        "majorName": item[QUESTIONS_LIST_MAJORNAME],
                        "majorCode": item[QUESTIONS_LIST_MAJORCODE],
                        "equipmentId": item[QUESTIONS_LIST_EQUIPMENTID],
                        "equipmentOrPart": item[QUESTIONS_LIST_EQUIPMENTORPART],
                        "checkType": item[QUESTIONS_LIST_CHECKTYPE],
                        "questionDescribe": item[QUESTIONS_LIST_QUESTIONDESCRIBE],
                        "harm": item[QUESTIONS_LIST_HARM],
                        "measures": item[QUESTIONS_LIST_MEASURES],
                        "questionCategoryId": item[QUESTIONS_LIST_QUESTIONCATEGORYID],
                        "questionCategory": item[QUESTIONS_LIST_QUESTIONCATEGORY],
                        "questionPropertyId": item[QUESTIONS_LIST_QUESTIONPROPERTYID],
                        "questionProperty": item[QUESTIONS_LIST_QUESTIONPROPERTY],
                        "emergencyId": item[QUESTIONS_LIST_EMERGENCYID],
                        "emergency": item[QUESTIONS_LIST_EMERGENCY],
                        "questionReasonId": item[QUESTIONS_LIST_QUESTIONREASONID],
                        "questionReason": item[QUESTIONS_LIST_QUESTIONREASON],
                        "estimatedDifficultyId": item[QUESTIONS_LIST_ESTIMATEDDIFFICULTYID],
                        "estimatedDifficulty": item[QUESTIONS_LIST_ESTIMATEDDIFFICULTY],
                        "suggestRectificationPartyId": item[QUESTIONS_LIST_SUGGESTRECTIFICATIONPARTYID],
                        "suggestRectificationParty": item[QUESTIONS_LIST_SUGGESTRECTIFICATIONPARTY],
                        "estimatedAmount": item[QUESTIONS_LIST_ESTIMATEDAMOUNT],
                        "image": item[QUESTIONS_LIST_IMAGE],
                        "updateTime": item[QUESTIONS_LIST_UPDATETIME],
                        "isLoad": item[QUESTIONS_LIST_ISLOAD]] as NSDictionary
    
            queryArray.add(dic);
        }
        return queryArray
    }
    
    // 更新
    public func questionsTableLampUpdateItem(_ id: Int64, _ isLoad : String) -> Void {
        let item = QUESTIONS_LIST_TABLE.filter(QUESTIONS_LIST_TABLE_ID == id)
        do {
            if try db.run(item.update(QUESTIONS_LIST_ISLOAD <- isLoad)) > 0 {
                
            }
        } catch {
            print("问题更新失败")
        }
    }
    
    public func questionsTableLampUpdateSpaceTree(_ projectId: Int64, _ spaceAddressOld: Int64, _ spaceAddressNew: Int64) -> Void {
        let item = QUESTIONS_LIST_TABLE.filter(QUESTIONS_LIST_PROJECTID == projectId && QUESTIONS_LIST_SPACEADDRESS == spaceAddressOld)
        do {
            if try db.run(item.update(QUESTIONS_LIST_SPACEADDRESS <- spaceAddressNew)) > 0 {
                
            }
        } catch {
            print("问题更新失败")
        }
    }
    
    // 删除
    public func questionsTableLampDeleteItem(_ id: Int64,_ projectId: Int64) -> Void {
        let item = QUESTIONS_LIST_TABLE.filter(QUESTIONS_LIST_TABLE_ID == id && QUESTIONS_LIST_PROJECTID == projectId)
        do {
            if try db.run(item.delete()) > 0 {
                
            } else {
                print("没有发现")
            }
        } catch {
            print("删除失败")
        }
    }

    
    //MARK: - 设备台账
    //MARK:设备
    public func deviceDetailTableLampCreate() -> Void {
        do {
            try db.run(DEVICE_DETAIL_TABLE.create { table in
                table.column(DEVICE_DETAIL_TABLE_ID, primaryKey: .autoincrement)
                table.column(DEVICE_DETAIL_DEVICEID)
                table.column(DEVICE_DETAIL_CREATETIME)
                table.column(DEVICE_DETAIL_DEVICECODE)
                table.column(DEVICE_DETAIL_DEVICENAME)
                table.column(DEVICE_DETAIL_DEVICESTATUS)
                table.column(DEVICE_DETAIL_DEVICETYPE)
                table.column(DEVICE_DETAIL_DEVICETYPESTR)
                table.column(DEVICE_DETAIL_EQUIPMENTBRAND)
                table.column(DEVICE_DETAIL_EQUIPMENTLABEL)
                table.column(DEVICE_DETAIL_EQUIPMENTNAMEPLATE)
                table.column(DEVICE_DETAIL_EQUIPMENTPICTURE)
                table.column(DEVICE_DETAIL_EQUIPMENTTHUMBNAIL)
                table.column(DEVICE_DETAIL_EQUIPMENTTYPECOUNT)
                table.column(DEVICE_DETAIL_FIXEDASSETSCODE)
                table.column(DEVICE_DETAIL_IMPORTANTINFORMATION)
                table.column(DEVICE_DETAIL_INSTALLATIONDATE)
                table.column(DEVICE_DETAIL_LAUNCHDATE)
                table.column(DEVICE_DETAIL_MAINTENANCE)
                table.column(DEVICE_DETAIL_MANUFACTURER)
                table.column(DEVICE_DETAIL_MANUFACTURINGNO)
                table.column(DEVICE_DETAIL_METERREADING)
                table.column(DEVICE_DETAIL_PID)
                table.column(DEVICE_DETAIL_PNAME)
                table.column(DEVICE_DETAIL_PRODUCTIONDATE)
                table.column(DEVICE_DETAIL_PROJECTID)
                table.column(DEVICE_DETAIL_PROJECTNAME)
                table.column(DEVICE_DETAIL_REMARK)
                table.column(DEVICE_DETAIL_RESPONSIBLEPERSON)
                table.column(DEVICE_DETAIL_ROUTINGINSPECTION)
                table.column(DEVICE_DETAIL_SERVICEREGION)
                table.column(DEVICE_DETAIL_SPACENAME)
                table.column(DEVICE_DETAIL_SPECIALITY)
                table.column(DEVICE_DETAIL_SPECIALITYNAME)
                table.column(DEVICE_DETAIL_SPECIFICATIONSMODEL)
                table.column(DEVICE_DETAIL_STATUS)
                table.column(DEVICE_DETAIL_UBIETYADDRESS)
                table.column(DEVICE_DETAIL_UBIETYADDRESSSTR)
                table.column(DEVICE_DETAIL_UBIETYBUILDING)
                table.column(DEVICE_DETAIL_UBIETYTYPE)
                table.column(DEVICE_DETAIL_UPDATETIME)
                table.column(DEVICE_DETAIL_USESTATUS)
                table.column(DEVICE_DETAIL_USERID)
                table.column(DEVICE_DETAIL_USERNAME)
                table.column(DEVICE_DETAIL_BIGUPDATEDATE)
                table.column(DEVICE_DETAIL_BIGUPDATETEXT)
                table.column(DEVICE_DETAIL_UPDATERECORD)
                table.column(DEVICE_DETAIL_MAINTAINUNIT)
                table.column(DEVICE_DETAIL_ISUPLOAD)
            })
            
        } catch {
            print("创建表 TABLE_LAMP 失败：\(error)")
        }
    }
    
    // 插入
    public func deviceDetailTableLampInsertItem(deviceId: Int64, deviceCode: String, createTime: Int64, deviceName: String, projectId: Int64, projectName: String, deviceStatus: Int64, deviceType: Int64, pid: Int64, pname: String, deviceTypeStr: String, equipmentBrand: String, equipmentLabel: String, equipmentNameplate: String, equipmentPicture: String, equipmentThumbnail: String, equipmentTypeCount: Int64, fixedAssetsCode: String, importantInformation: String, installationDate: Int64, launchDate: Int64, maintenance: Int64, manufacturer: String, manufacturingNo: String, meterReading: Int64, productionDate: Int64, remark: String, responsiblePerson: String, routingInspection: Int64, serviceRegion: String, spaceName: String, speciality: Int64, specialityName: String, specificationsModel: String, status: Int64, ubietyAddress: Int64, ubietyAddressStr: String, ubietyBuilding: String, unitType: Int64, updateTime: Int64, useStatus: Int64, userId: Int64, userName: String, bigUpdateDate: Int64, bigUpdateText: String, updateRecord: String, maintainUnit: String, isUpload: Int64) -> Void {

        let insert = DEVICE_DETAIL_TABLE.insert(
            DEVICE_DETAIL_DEVICEID <- deviceId,
            DEVICE_DETAIL_CREATETIME <- createTime,
            DEVICE_DETAIL_DEVICECODE <- deviceCode,
            DEVICE_DETAIL_DEVICENAME <- deviceName,
            DEVICE_DETAIL_DEVICESTATUS <- deviceStatus,
            DEVICE_DETAIL_DEVICETYPE <- deviceType,
            DEVICE_DETAIL_DEVICETYPESTR <- deviceTypeStr,
            DEVICE_DETAIL_EQUIPMENTBRAND <- equipmentBrand,
            DEVICE_DETAIL_EQUIPMENTLABEL <- equipmentLabel,
            DEVICE_DETAIL_EQUIPMENTNAMEPLATE <- equipmentNameplate,
            DEVICE_DETAIL_EQUIPMENTPICTURE <- equipmentPicture,
            DEVICE_DETAIL_EQUIPMENTTHUMBNAIL <- equipmentThumbnail,
            DEVICE_DETAIL_EQUIPMENTTYPECOUNT <- equipmentTypeCount,
            DEVICE_DETAIL_FIXEDASSETSCODE <- fixedAssetsCode,
            DEVICE_DETAIL_IMPORTANTINFORMATION <- importantInformation,
            DEVICE_DETAIL_INSTALLATIONDATE <- installationDate,
            DEVICE_DETAIL_LAUNCHDATE <- launchDate,
            DEVICE_DETAIL_MAINTENANCE <- maintenance,
            DEVICE_DETAIL_MANUFACTURER <- manufacturer,
            DEVICE_DETAIL_MANUFACTURINGNO <- manufacturingNo,
            DEVICE_DETAIL_METERREADING <- meterReading,
            DEVICE_DETAIL_PID <- pid,
            DEVICE_DETAIL_PNAME <- pname,
            DEVICE_DETAIL_PRODUCTIONDATE <- productionDate,
            DEVICE_DETAIL_PROJECTID <- projectId,
            DEVICE_DETAIL_PROJECTNAME <- projectName,
            DEVICE_DETAIL_REMARK <- remark,
            DEVICE_DETAIL_RESPONSIBLEPERSON <- responsiblePerson,
            DEVICE_DETAIL_ROUTINGINSPECTION <- routingInspection,
            DEVICE_DETAIL_SERVICEREGION <- serviceRegion,
            DEVICE_DETAIL_SPACENAME <- spaceName,
            DEVICE_DETAIL_SPECIALITY <- speciality,
            DEVICE_DETAIL_SPECIALITYNAME <- specialityName,
            DEVICE_DETAIL_SPECIFICATIONSMODEL <- specificationsModel,
            DEVICE_DETAIL_STATUS <- status,
            DEVICE_DETAIL_UBIETYADDRESS <- ubietyAddress,
            DEVICE_DETAIL_UBIETYADDRESSSTR <- ubietyAddressStr,
            DEVICE_DETAIL_UBIETYBUILDING <- ubietyBuilding,
            DEVICE_DETAIL_UBIETYTYPE <- unitType,
            DEVICE_DETAIL_UPDATETIME <- updateTime,
            DEVICE_DETAIL_USESTATUS <- useStatus,
            DEVICE_DETAIL_USERID <- userId,
            DEVICE_DETAIL_USERNAME <- userName,
            DEVICE_DETAIL_BIGUPDATEDATE <- bigUpdateDate,
            DEVICE_DETAIL_BIGUPDATETEXT <- bigUpdateText,
            DEVICE_DETAIL_UPDATERECORD <- updateRecord,
            DEVICE_DETAIL_MAINTAINUNIT <- maintainUnit,
            DEVICE_DETAIL_ISUPLOAD <- isUpload)
        do {
            try db.transaction {
                let rowid = try db.run(insert)
                print("插入数据成功 id: \(rowid)")
            }
        } catch {
            print("插入数据失败tasksList: \(error)")
        }
    }

    //插入前排查是否数据库存有
    public func deviceDetailListTableLampSelectItem(deviceId: Int64, deviceCode: String, projectId: Int64, deviceType: Int64) -> NSArray {
        let queryArray:NSMutableArray = NSMutableArray()
        for item in try! db.prepare(DEVICE_DETAIL_TABLE.filter(DEVICE_DETAIL_DEVICEID == deviceId && DEVICE_DETAIL_DEVICECODE == deviceCode && DEVICE_DETAIL_PROJECTID == projectId && DEVICE_DETAIL_DEVICETYPE == deviceType)) {
            let dic = ["id": item[DEVICE_DETAIL_DEVICEID],
                       "deviceCode": item[DEVICE_DETAIL_DEVICECODE],
                       "projectId": item[DEVICE_DETAIL_PROJECTID],
                       "deviceType": item[DEVICE_DETAIL_DEVICETYPE]] as NSDictionary
            queryArray.add(dic);
        }
        return queryArray
    }

    //查询所有设备
    public func deviceDetailListTableLampSelectAllItem(projectId: Int64) -> NSArray {
        let queryArray:NSMutableArray = NSMutableArray()
        if projectId != 0 {
            for item in try! db.prepare(DEVICE_DETAIL_TABLE.filter(DEVICE_DETAIL_PROJECTID == projectId)) {
                let dic = [
                    "autoId": item[DEVICE_DETAIL_TABLE_ID],
                    "id": item[DEVICE_DETAIL_DEVICEID],
                    "createTime": item[DEVICE_DETAIL_CREATETIME],
                    "deviceCode": item[DEVICE_DETAIL_DEVICECODE],
                    "deviceName": item[DEVICE_DETAIL_DEVICENAME],
                    "deviceStatus": item[DEVICE_DETAIL_DEVICESTATUS],
                    "deviceType": item[DEVICE_DETAIL_DEVICETYPE],
                    "deviceTypeStr": item[DEVICE_DETAIL_DEVICETYPESTR],
                    "equipmentBrand": item[DEVICE_DETAIL_EQUIPMENTBRAND],
                    "equipmentLabel": item[DEVICE_DETAIL_EQUIPMENTLABEL],
                    "equipmentNameplate": item[DEVICE_DETAIL_EQUIPMENTNAMEPLATE],
                    "equipmentPicture": item[DEVICE_DETAIL_EQUIPMENTPICTURE],
                    "equipmentThumbnail": item[DEVICE_DETAIL_EQUIPMENTTHUMBNAIL],
                    "equipmentTypeCount": item[DEVICE_DETAIL_EQUIPMENTTYPECOUNT],
                    "fixedAssetsCode": item[DEVICE_DETAIL_FIXEDASSETSCODE],
                    "importantInformation": item[DEVICE_DETAIL_IMPORTANTINFORMATION],
                    "installationDate": item[DEVICE_DETAIL_INSTALLATIONDATE],
                    "launchDate": item[DEVICE_DETAIL_LAUNCHDATE],
                    "maintenance": item[DEVICE_DETAIL_MAINTENANCE],
                    "manufacturer": item[DEVICE_DETAIL_MANUFACTURER],
                    "manufacturingNo": item[DEVICE_DETAIL_MANUFACTURINGNO],
                    "meterReading": item[DEVICE_DETAIL_METERREADING],
                    "pid": item[DEVICE_DETAIL_PID],
                    "pname": item[DEVICE_DETAIL_PNAME],
                    "productionDate": item[DEVICE_DETAIL_PRODUCTIONDATE],
                    "projectId": item[DEVICE_DETAIL_PROJECTID],
                    "projectName": item[DEVICE_DETAIL_PROJECTNAME],
                    "remark": item[DEVICE_DETAIL_REMARK],
                    "responsiblePerson": item[DEVICE_DETAIL_RESPONSIBLEPERSON],
                    "routingInspection": item[DEVICE_DETAIL_ROUTINGINSPECTION],
                    "serviceRegion": item[DEVICE_DETAIL_SERVICEREGION],
                    "spaceName": item[DEVICE_DETAIL_SPACENAME],
                    "speciality": item[DEVICE_DETAIL_SPECIALITY],
                    "specialityName": item[DEVICE_DETAIL_SPECIALITYNAME],
                    "specificationsModel": item[DEVICE_DETAIL_SPECIFICATIONSMODEL],
                    "status": item[DEVICE_DETAIL_STATUS],
                    "ubietyAddress": item[DEVICE_DETAIL_UBIETYADDRESS],
                    "ubietyAddressStr": item[DEVICE_DETAIL_UBIETYADDRESSSTR],
                    "ubietyBuilding": item[DEVICE_DETAIL_UBIETYBUILDING],
                    "unitType": item[DEVICE_DETAIL_UBIETYTYPE],
                    "updateTime": item[DEVICE_DETAIL_UPDATETIME],
                    "useStatus": item[DEVICE_DETAIL_USESTATUS],
                    "userId": item[DEVICE_DETAIL_USERID],
                    "userName": item[DEVICE_DETAIL_USERNAME],
                    "bigUpdateDate": item[DEVICE_DETAIL_BIGUPDATEDATE],
                    "bigUpdateText": item[DEVICE_DETAIL_BIGUPDATETEXT],
                    "updateRecord": item[DEVICE_DETAIL_UPDATERECORD],
                    "maintainUnit": item[DEVICE_DETAIL_MAINTAINUNIT],
                    "isUpload": item[DEVICE_DETAIL_ISUPLOAD]] as NSDictionary
        
                queryArray.add(dic);
            }
        } else {
            for item in try! db.prepare(DEVICE_DETAIL_TABLE.filter(DEVICE_DETAIL_ISUPLOAD == 0)) {
                let dic = [
                    "autoId": item[DEVICE_DETAIL_TABLE_ID],
                    "deviceId": item[DEVICE_DETAIL_DEVICEID],
                    "createTime": item[DEVICE_DETAIL_CREATETIME],
                    "deviceCode": item[DEVICE_DETAIL_DEVICECODE],
                    "deviceName": item[DEVICE_DETAIL_DEVICENAME],
                    "deviceStatus": item[DEVICE_DETAIL_DEVICESTATUS],
                    "deviceType": item[DEVICE_DETAIL_DEVICETYPE],
                    "deviceTypeStr": item[DEVICE_DETAIL_DEVICETYPESTR],
                    "equipmentBrand": item[DEVICE_DETAIL_EQUIPMENTBRAND],
                    "equipmentLabel": item[DEVICE_DETAIL_EQUIPMENTLABEL],
                    "equipmentNameplate": item[DEVICE_DETAIL_EQUIPMENTNAMEPLATE],
                    "equipmentPicture": item[DEVICE_DETAIL_EQUIPMENTPICTURE],
                    "equipmentThumbnail": item[DEVICE_DETAIL_EQUIPMENTTHUMBNAIL],
                    "equipmentTypeCount": item[DEVICE_DETAIL_EQUIPMENTTYPECOUNT],
                    "fixedAssetsCode": item[DEVICE_DETAIL_FIXEDASSETSCODE],
                    "importantInformation": item[DEVICE_DETAIL_IMPORTANTINFORMATION],
                    "installationDate": item[DEVICE_DETAIL_INSTALLATIONDATE],
                    "launchDate": item[DEVICE_DETAIL_LAUNCHDATE],
                    "maintenance": item[DEVICE_DETAIL_MAINTENANCE],
                    "manufacturer": item[DEVICE_DETAIL_MANUFACTURER],
                    "manufacturingNo": item[DEVICE_DETAIL_MANUFACTURINGNO],
                    "meterReading": item[DEVICE_DETAIL_METERREADING],
                    "pid": item[DEVICE_DETAIL_PID],
                    "pname": item[DEVICE_DETAIL_PNAME],
                    "productionDate": item[DEVICE_DETAIL_PRODUCTIONDATE],
                    "projectId": item[DEVICE_DETAIL_PROJECTID],
                    "projectName": item[DEVICE_DETAIL_PROJECTNAME],
                    "remark": item[DEVICE_DETAIL_REMARK],
                    "responsiblePerson": item[DEVICE_DETAIL_RESPONSIBLEPERSON],
                    "routingInspection": item[DEVICE_DETAIL_ROUTINGINSPECTION],
                    "serviceRegion": item[DEVICE_DETAIL_SERVICEREGION],
                    "spaceName": item[DEVICE_DETAIL_SPACENAME],
                    "speciality": item[DEVICE_DETAIL_SPECIALITY],
                    "specialityName": item[DEVICE_DETAIL_SPECIALITYNAME],
                    "specificationsModel": item[DEVICE_DETAIL_SPECIFICATIONSMODEL],
                    "status": item[DEVICE_DETAIL_STATUS],
                    "ubietyAddress": item[DEVICE_DETAIL_UBIETYADDRESS],
                    "ubietyAddressStr": item[DEVICE_DETAIL_UBIETYADDRESSSTR],
                    "ubietyBuilding": item[DEVICE_DETAIL_UBIETYBUILDING],
                    "unitType": item[DEVICE_DETAIL_UBIETYTYPE],
                    "updateTime": item[DEVICE_DETAIL_UPDATETIME],
                    "useStatus": item[DEVICE_DETAIL_USESTATUS],
                    "userId": item[DEVICE_DETAIL_USERID],
                    "userName": item[DEVICE_DETAIL_USERNAME],
                    "bigUpdateDate": item[DEVICE_DETAIL_BIGUPDATEDATE],
                    "bigUpdateText": item[DEVICE_DETAIL_BIGUPDATETEXT],
                    "updateRecord": item[DEVICE_DETAIL_UPDATERECORD],
                    "maintainUnit": item[DEVICE_DETAIL_MAINTAINUNIT],
                    "isUpload": item[DEVICE_DETAIL_ISUPLOAD]] as NSDictionary
        
                queryArray.add(dic);
            }
        }
        
        return queryArray
    }
    
    // 更新上传状态
    public func deviceDetailListTableLampUpdate(autoId: Int64, deviceId: Int64, deviceCode: String, isUpload: Int64, projectId: Int64, deviceType: Int64) -> Void {
        let item = DEVICE_DETAIL_TABLE.filter(DEVICE_DETAIL_TABLE_ID == autoId && DEVICE_DETAIL_DEVICEID == deviceId && DEVICE_DETAIL_DEVICECODE == deviceCode && DEVICE_DETAIL_PROJECTID == projectId && DEVICE_DETAIL_DEVICETYPE == deviceType)
        do {
            if try db.run(item.update(DEVICE_DETAIL_ISUPLOAD <- isUpload)) > 0 {
                print("\(deviceCode) 更新成功")
            } else {
                print("没有发现\(deviceCode)")
            }
        } catch {
            print("\(deviceCode) 更新失败：\(error)")
        }
    }
}
