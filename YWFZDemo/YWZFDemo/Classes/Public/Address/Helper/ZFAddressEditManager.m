//
//  ZFAddressEditManager.m
//  ZZZZZ
//
//  Created by YW on 2019/6/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressEditManager.h"


@implementation ZFAddressEditManager

+ (void)firstNameBecomeFirstResponderTable:(UITableView *)tableview source:(NSArray *)sourceArray {
    if (![tableview isKindOfClass:[UITableView class]] || !ZFJudgeNSArray(sourceArray)) {
        return;
    }
    //简单点
    NSIndexPath *firstIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    ZFAddressEditTypeModel *model = [ZFAddressEditManager editTypeModelSource:sourceArray indexPath:firstIndex];
    
    if (model) {
        if (model.editType == ZFAddressEditTypeFirstName) {
            ZFAddressEditNameTableViewCell *cell = [tableview cellForRowAtIndexPath:firstIndex];
            if ([cell respondsToSelector:@selector(becomeFirstResponder)]) {
                [cell becomeFirstResponder];
            }
        }
    }
}

+ (BOOL)isEditAddressSource:(NSDictionary *)sourceDic editModel:(NSDictionary *)editDic {
    if (!ZFJudgeNSDictionary(sourceDic) || !ZFJudgeNSDictionary(editDic)) {
        return NO;
    }
    __block BOOL isChange = NO;
    [editDic.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id sourceValue = sourceDic[obj];
        id editValue = editDic[obj];
        if (sourceValue && editValue) {
            if ([sourceValue isKindOfClass:[NSString class]] && [editValue isKindOfClass:[NSString class]]) {
                //去掉首尾空字符
                if (![[NSStringUtils trimmingStartEndWhitespace:sourceValue] isEqualToString:[NSStringUtils trimmingStartEndWhitespace:editValue]]) {
                    isChange = YES;
                    *stop = YES;
                }
            }
        } else if([editValue isKindOfClass:[NSString class]]) {
            if (![NSStringUtils isEmptyString:editValue]) {
                isChange = YES;
                *stop = YES;
            }
        }
    }];
    return isChange;
}

+ (BOOL)isCheckEnterInfoSuccess:(NSArray *)datas addressInfoModel:(ZFAddressInfoModel *)editModel village:(BOOL)hasVillage{
    
    if (!ZFJudgeNSArray(datas) || !editModel) {
        return NO;
    }
    __block BOOL isOk = YES;
    //检查一遍Edit Model， 如果存在问题，直接打开icContinueCheck开关 刷新数据源提示用户输入。
    [datas enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(ZFAddressEditTypeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            switch (obj.editType) {
                case ZFAddressEditTypeTopMessage:
                    break;
                case ZFAddressEditTypeFirstName: {
                    
                    NSInteger strLength = [NSStringUtils mixChineseEnglishLength:editModel.firstname];
                    if(strLength == 0 || strLength < 2 || [editModel isContainSpecialMarkName:editModel.firstname]){
                        isOk = NO;
                        obj.rowHeight = kZFAddressCellTipsErrorHeight;
                        obj.isShowTips = YES;
                    }
                }
                    break;
                case ZFAddressEditTypeLastName: {
                    NSInteger strLength = [NSStringUtils mixChineseEnglishLength:editModel.lastname];
                    if(strLength <= 0 || strLength < 2 || [editModel isContainSpecialMarkName:editModel.lastname]){
                        isOk = NO;
                        obj.rowHeight = kZFAddressCellTipsErrorHeight;
                        obj.isShowTips = YES;
                    }
                }
                    break;
                case ZFAddressEditTypeEmail: {
                    
                    BOOL isPhoneRegisterCheck = NO;
                    if ([AccountManager sharedManager].account.is_emerging_country == 1) {//手机注册用户
                        if (editModel.email.length <= 0) {//电话注册用户，邮箱是非必填
                            isPhoneRegisterCheck = YES;
                        }
                    }
                    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
                    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
                    
                    if (isPhoneRegisterCheck) {
                        isOk = YES;
                        obj.rowHeight = kZFAddressCellNormalHeight;
                        
                    } else if (editModel.email.length <= 0 || editModel.email.length < 6 || editModel.email.length >= 60) {
                        isOk = NO;
                        obj.rowHeight = 75;
                    } else if (![emailTest evaluateWithObject:editModel.email]) {
                        isOk = NO;
                        obj.rowHeight = kZFAddressCellTipsErrorHeight;
                        obj.isShowTips = YES;
                    }
                }
                    break;
                case ZFAddressEditTypeAddressFirst: {
                    if (editModel.addressline1.length <= 0 || editModel.addressline1.length < 5 || [editModel isContainSpecialMarkFirstAddressLine] || [editModel isContainSpecialEmailMarkFirstAddressLine] || [editModel isAllNumberFirstAddressLine]){
                        isOk = NO;
                        obj.rowHeight = kZFAddressCellTipsErrorHeight;
                        obj.isShowTips = YES;
                    }
                }
                    break;
                case ZFAddressEditTypeAddressSecond: {
                    
                }
                    break;
                case ZFAddressEditTypeCountry: {
                    if(editModel.country_str.length <= 0 || editModel.country_str.length < 2){
                        isOk = NO;
                        obj.rowHeight = kZFAddressCellTipsErrorHeight;
                        obj.isShowTips = YES;
                    }
                }
                    break;
                case ZFAddressEditTypeState: {
                    if(editModel.province.length <= 0 || editModel.province.length < 2){
                        isOk = NO;
                        obj.rowHeight = kZFAddressCellTipsErrorHeight;
                        obj.isShowTips = YES;
                    }
                }
                    break;
                case ZFAddressEditTypeCity: {
                    if(editModel.city.length <= 0 || editModel.city.length < 3
                       || [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^\\d{3,}$"] evaluateWithObject:editModel.city]){
                        isOk = NO;
                        obj.rowHeight = kZFAddressCellTipsErrorHeight;
                        obj.isShowTips = YES;
                    }
                    
                }
                    break;
                case ZFAddressEditTypeVillage: {
                    if (editModel.showFourLevel || hasVillage) {
                        if(editModel.barangay.length <= 0){
                            isOk = NO;
                            obj.rowHeight = kZFAddressCellTipsErrorHeight;
                            obj.isShowTips = YES;
                        }
                    }
                }
                    break;
                case ZFAddressEditTypeZipCode: {
                    
                    // 优先判断地址zip四位错误 //菲律宾国家地址需要验证邮编 不需要清空 保持四位
                    if (editModel.isZipFourTip) {
                        isOk = NO;
                        obj.rowHeight = 75;
                        obj.isShowTips = YES;
                        
                    } if ([editModel isMustZip]) {
                        if ([editModel isPhilippinesCountry]) {
                            if (editModel.zipcode.length != 4) {
                                isOk = NO;
                                obj.rowHeight = 75;
                                obj.isShowTips = YES;
                            }
                            
                        } else if ([editModel isIndiaCountry]) {
                            NSString *pwdRegex = @"^\\d{6}$";  // (6个连续数字,以数字开头,以数字结尾)
                            NSPredicate *pwdTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pwdRegex];
                            BOOL isMatch= [pwdTest evaluateWithObject:editModel.zipcode];
                            if (!isMatch) {
                                isOk = NO;
                                obj.rowHeight = 75;
                                obj.isShowTips = YES;
                            }
                        } else if ([editModel isCanadaCountry]) {
                            NSString *pwdRegex =  @"[a-zA-Z\\d\\-\\s]{6,9}";
                            NSPredicate *pwdTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pwdRegex];
                            BOOL isMatch= [pwdTest evaluateWithObject:editModel.zipcode];
                            if (!isMatch) {
                                isOk = NO;
                                obj.rowHeight = 75;
                                obj.isShowTips = YES;
                            }
                        }
                        else if ([editModel.country_id isEqualToString:@"41"] && editModel.zipcode.length < 5) {
                            //非美国地区 2 ～ 10， 美国地区 5 ～ 10 根据countryId 判断
                            isOk = NO;
                            obj.rowHeight = 75;
                            obj.isShowTips = YES;
                        } else if(editModel.zipcode.length <= 0 || editModel.zipcode.length < 2) {
                            isOk = NO;
                            obj.rowHeight = kZFAddressCellTipsErrorHeight;
                            obj.isShowTips = YES;
                        }
                    }
                }
                    break;
                case ZFAddressEditTypeLandmark: {
                    
                }
                    break;
                case ZFAddressEditTypePhoneNumber: {
                    if (editModel.supplier_number_list.count > 0 && editModel.supplier_number.length <= 0) {
                        isOk = NO;
                        obj.rowHeight = kZFAddressCellTipsErrorHeight;
                        obj.isShowTips = YES;
                    }
                    
                    NSArray *scutNumberArr = editModel.scut_number_list;
                    NSString *telLengthStr = [NSString stringWithFormat:@"%zd",editModel.tel.length];
                    
                    if(editModel.tel.length <= 0){
                        isOk = NO;
                        obj.rowHeight = kZFAddressCellTipsErrorHeight;
                        obj.isShowTips = YES;
                    }
                    else if (editModel.configured_number == 1 && (scutNumberArr.count > 0 &&  ![scutNumberArr containsObject:telLengthStr]) ) {  // 有限制号码长度     只要当前输入长度不等于number就提示
                        isOk = NO;
                        obj.rowHeight = kZFAddressCellTipsErrorHeight;
                        obj.isShowTips = YES;
                        
                    } else if (editModel.configured_number == 0 && (editModel.tel.length > [editModel.maxPhoneLength integerValue] || editModel.tel.length < [editModel.minPhoneLength integerValue])) {       // 没有限制号码长度   电话号码长度最大/最小不能超过20/6位
                        isOk = NO;
                        obj.rowHeight = kZFAddressCellTipsErrorHeight;
                        obj.isShowTips = YES;
                        
                    }
                }
                    break;
                case ZFAddressEditTypeAlternatePhoneNumber: {
                    if ([editModel.tel isEqualToString:editModel.telspare] &&
                        [editModel.supplier_number isEqualToString:editModel.supplier_number_spare]) {
                        //两个电话相同，提示用户
                    }
                }
                    break;
                case ZFAddressEditTypeNationalId: {
                    if ([FilterManager requireCardNumWithAddressId:editModel.country_id] && editModel.id_card.length != 10) {
                        isOk = NO;
                        obj.rowHeight = kZFAddressCellTipsErrorHeight;
                        obj.isShowTips = YES;
                    }
                }
                    break;
                case ZFAddressEditTypeWhatsApp: {
                    
                }
                    break;
                case ZFAddressEditTypeSetDefault: {
                    
                }
                    break;
            }
        }];
    }];
    return isOk;
}

///是否编辑了国家、州、省、城镇、邮编
+ (BOOL)isEditCountryStateCityBarangayZip:(ZFAddressEditTypeModel *)model addressInfoModel:(ZFAddressInfoModel *)editModel content:(NSString *)content {
    
    if (!model || !editModel) {
        return NO;
    }
    
    BOOL flag = [ZFAddressEditManager isEditCountryStateCityBarangay:model  addressInfoModel:editModel content:content];
    if (model.editType == ZFAddressEditTypeZipCode) {
        if (![editModel.zipcode isEqualToString:content]) {
            flag = YES;
        }
    }
    return flag;
}

///是否编辑了国家、州、省、城镇
+ (BOOL)isEditCountryStateCityBarangay:(ZFAddressEditTypeModel *)model  addressInfoModel:(ZFAddressInfoModel *)editModel content:(NSString *)content {
    
    if (!model || !editModel) {
        return NO;
    }
    
    BOOL flag = NO;
    if (model.editType == ZFAddressEditTypeCountry) {
        if (![editModel.country_str isEqualToString:content]) {
            flag = YES;
        }
    }
    
    if (model.editType == ZFAddressEditTypeState) {
        if (![editModel.province isEqualToString:content]) {
            flag = YES;
        }
    }
    
    if (model.editType == ZFAddressEditTypeCity) {
        if (![editModel.city isEqualToString:content]) {
            flag = YES;
        }
    }
    
    if (model.editType == ZFAddressEditTypeVillage) {
        if (![editModel.barangay isEqualToString:content]) {
            flag = YES;
        }
    }
    
    return flag;
}

///更新对应cell数据源
+ (void)updateAddressInfoModel:(ZFAddressInfoModel *)editModel editTypeModel:(ZFAddressEditTypeModel *)model content:(NSString *)content {
    
    if (!editModel) {
        return;
    }
    if (model.editType == ZFAddressEditTypeFirstName) {
        editModel.firstname = content;
        
    } else if(model.editType == ZFAddressEditTypeLastName) {
        editModel.lastname = content;
        
    } else if(model.editType == ZFAddressEditTypeEmail) {
        editModel.email = content;
        
    } else if(model.editType == ZFAddressEditTypeAddressFirst) {
        editModel.addressline1 = content;
        
    } else if(model.editType == ZFAddressEditTypeAddressSecond) {
        editModel.addressline2 = content;
        
    } else if(model.editType == ZFAddressEditTypeLandmark) {
        editModel.landmark = content;
        
    } else if(model.editType == ZFAddressEditTypeState) {
        editModel.province = content;
        
    } else if(model.editType == ZFAddressEditTypeCity) {
        editModel.city = content;
        
    } else if(model.editType == ZFAddressEditTypeVillage) {
        editModel.barangay = content;
        
    } else if(model.editType == ZFAddressEditTypeZipCode) {
        editModel.zipcode = content;
        
    } else if(model.editType == ZFAddressEditTypeWhatsApp) {
        [ZFAddressEditManager editAddressInfoModel:editModel whatApp:content];
        model.rowHeight = kZFAddressCellWhatsAppNormalHeight;
        
    } else if(model.editType == ZFAddressEditTypeNationalId) {
        editModel.id_card = content;
        
    } else if(model.editType == ZFAddressEditTypePhoneNumber) {//必备电话
        editModel.tel = content;
        
    } else if(model.editType == ZFAddressEditTypeAlternatePhoneNumber) {//选填电话
        editModel.telspare = content;
    }
}

/// cod状态下，才有whatsapp
+ (void)editAddressInfoModel:(ZFAddressInfoModel *)editModel whatApp:(NSString *)whatsApp {
    if (editModel) {
        editModel.whatsapp = editModel.is_cod ? ZFToString(whatsApp) : @"";
    }
}

//获取选择数据模型
+ (ZFAddressEditTypeModel *)editTypeModelSource:(NSArray *)sourceArray indexPath:(NSIndexPath *)indexPath {
    if (!ZFJudgeNSArray(sourceArray)) {
        return nil;
    }
    if (sourceArray.count > indexPath.section && indexPath) {
        NSArray *groupsArr = sourceArray[indexPath.section];
        if (groupsArr.count > indexPath.row) {
            ZFAddressEditTypeModel *model = groupsArr[indexPath.row];
            return model;
        }
    }
    return nil;
}

//获取类型取数据模型
+ (ZFAddressEditTypeModel *)editTypeModelSource:(NSArray *)sourceArray editType:(ZFAddressEditType )editType {
    if (!ZFJudgeNSArray(sourceArray)) {
        return nil;
    }
    
    for (NSArray *groupsArr in sourceArray) {
        for (ZFAddressEditTypeModel *model in groupsArr) {
            if (model.editType == editType) {
                return model;
            }
        }
    }
    
    return nil;
}

//获取类型取数据模型
+ (NSIndexPath *)indexPathModelSource:(NSArray *)sourceArray editTypeModel:(ZFAddressEditTypeModel *)model {
    if (!ZFJudgeNSArray(sourceArray) && model) {
        return nil;
    }
    
    for(int i=0;  i<sourceArray.count; i++) {
        NSArray *groupsArr = sourceArray[i];
        for(int j=0; j<groupsArr.count; j++) {
            ZFAddressEditTypeModel *editModel = groupsArr[j];
            if (editModel.editType == model.editType) {
                return [NSIndexPath indexPathForRow:j inSection:i];
            }
        }
    }
    
    return nil;
}

+ (void)autofillTable:(UITableView *)tableView sourceData:(NSArray *)sourceArray editModel:(ZFAddressInfoModel *)editModel locationInfo:(ZFAddressLocationInfoModel *)infoModel {
    
    if (![tableView isKindOfClass:[UITableView class]] || !ZFJudgeNSArray(sourceArray) || !editModel || !infoModel) {
        return;
    }
    
    NSInteger sections = tableView.numberOfSections;
    for (int section = 0; section < sections; section++) {
        NSInteger rows =  [tableView numberOfRowsInSection:section];
        for (int row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            ZFBaseEditAddressCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if ([cell isKindOfClass:[ZFAddressEditCountryTableViewCell class]]) {
                ZFAddressEditTypeModel *model = [ZFAddressEditManager editTypeModelSource:sourceArray indexPath:indexPath];
                if (model.editType == ZFAddressEditTypeCountry) {
                    editModel.country_str = ZFToString(infoModel.address_components.country);
                    [cell updateContentText:editModel.country_str];
                }
            }
            
            if ([cell isKindOfClass:[ZFAddressEditStateTableViewCell class]]) {
                ZFAddressEditTypeModel *model = [ZFAddressEditManager editTypeModelSource:sourceArray indexPath:indexPath];
                if (model.editType == ZFAddressEditTypeState) {
                    editModel.province = ZFToString(infoModel.address_components.state);
                    [cell updateContentText:editModel.province];
                }
            }
            
            if ([cell isKindOfClass:[ZFAddressEditCityTableViewCell class]]) {
                ZFAddressEditTypeModel *model = [ZFAddressEditManager editTypeModelSource:sourceArray indexPath:indexPath];
                if (model.editType == ZFAddressEditTypeCity) {
                    editModel.city = ZFToString(infoModel.address_components.city);
                    [cell updateContentText:editModel.city];
                }
            }
            
            if ([cell isKindOfClass:[ZFAddressEditVillageCell class]]) {
                ZFAddressEditTypeModel *model = [ZFAddressEditManager editTypeModelSource:sourceArray indexPath:indexPath];
                if (model.editType == ZFAddressEditTypeVillage) {
                    editModel.barangay = @"";
                    [cell updateContentText:editModel.barangay];
                }
            }
            
            if ([cell isKindOfClass:[ZFAddressEditZipCodeTableViewCell class]]) {
                ZFAddressEditTypeModel *model = [ZFAddressEditManager editTypeModelSource:sourceArray indexPath:indexPath];
                if (model.editType == ZFAddressEditTypeZipCode) {
                    editModel.zipcode = ZFToString(infoModel.address_components.postcode);
                    ZFAddressEditZipCodeTableViewCell *zipCell = (ZFAddressEditZipCodeTableViewCell *)cell;
                    [zipCell fillInZip:editModel.zipcode];
                }
            }
        }
    }
}


+ (void)showOrderAddressContactCustomerMsg:(NSString *)msg completion:(void (^)(NSInteger buttonIndex))completion {
    
    ShowVerticalAlertView(nil, ZFToString(msg), @[ZFLocalizedString(@"Address_contact_customer", nil),ZFLocalizedString(@"Cancel", nil)], ^(NSInteger buttonIndex, id buttonTitle) {
        if (completion) {
            completion(buttonIndex);
        }
    }, nil, nil);
    
}
+ (void)showOrderAddressChangedSuccess:(void (^)(NSInteger buttonIndex))completion {
    ShowAlertView(ZFLocalizedString(@"Address_order_changed", nil), ZFLocalizedString(@"Address_order_changed_success", nil), @[ZFLocalizedString(@"Confirm", nil)], ^(NSInteger buttonIndex, id buttonTitle) {
        if (completion) {
            completion(buttonIndex);
        }
    }, nil, nil);
}
+ (void)showOrderAddressChangedError:(NSString *)msg completion:(void (^)(NSInteger buttonIndex))completion {
    
    ShowAlertView(nil, ZFLocalizedString(@"Address_order_net_error", nil), @[ZFLocalizedString(@"Cancel", nil),ZFLocalizedString(@"Address_Try_again", nil)], ^(NSInteger buttonIndex, id buttonTitle) {
        if (completion) {
            completion(buttonIndex);
        }
    }, nil, nil);
}



#pragma mark - 配置显示

+ (void)configBaseTable:(UITableView *)tableView {
    if (![tableView isKindOfClass:[UITableView class]]) {
        return;
    }
    
    UITableView *_tableView = tableView;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
    [_tableView registerClass:[ZFAddressEditNameTableViewCell class] forCellReuseIdentifier:kZFAddressEditNameTableViewCellIdentifier];
    [_tableView registerClass:[ZFAddressEditEmailTableViewCell class] forCellReuseIdentifier:kZFAddressEditEmailTableViewCellIdentifier];
    [_tableView registerClass:[ZFAddressEditAddressTableViewCell class] forCellReuseIdentifier:kZFAddressEditAddressTableViewCellIdentifier];
    [_tableView registerClass:[ZFAddressEditCountryTableViewCell class] forCellReuseIdentifier:kZFAddressEditCountryTableViewCellIdentifier];
    [_tableView registerClass:[ZFAddressEditStateTableViewCell class] forCellReuseIdentifier:kZFAddressEditStateTableViewCellIdentifier];
    [_tableView registerClass:[ZFAddressEditCityTableViewCell class] forCellReuseIdentifier:kZFAddressEditCityTableViewCellIdentifier];
    [_tableView registerClass:[ZFAddressEditZipCodeTableViewCell class] forCellReuseIdentifier:kZFAddressEditZipCodeTableViewCellIdentifier];
    [_tableView registerClass:[ZFAddressEditNationalIDTableViewCell class] forCellReuseIdentifier:kZFAddressEditNationalIDTableViewCellIdentifier];
    [_tableView registerClass:[ZFAddressEditSetDefaultTableViewCell class] forCellReuseIdentifier:kZFAddressEditSetDefaultTableViewCellIdentifier];
    [_tableView registerClass:[ZFAddressEditPhoneNumberTableViewCell class] forCellReuseIdentifier:kZFAddressEditPhoneNumberTableViewCellIdentifier];
    [_tableView registerClass:[ZFAddressEditLandMarksTableViewCell class] forCellReuseIdentifier:kZFAddressEditLandMarksTableViewCellIdentifier];
    [_tableView registerClass:[ZFAddressEditWhatsAppTableViewCell class] forCellReuseIdentifier:kZFAddressEditWhatsAppTableViewCellIdentifier];
    [_tableView registerClass:[ZFAddressEditAlternatePhoneNumberCell class] forCellReuseIdentifier:kZFAddressEditAlternatePhoneNumberCellIdentifier];
    [_tableView registerClass:[ZFAddressTopMessageTableViewCell class] forCellReuseIdentifier:kZFAddressTopMessageTableViewCellIdentifier];
    [_tableView registerClass:[ZFAddressEditVillageCell class] forCellReuseIdentifier:kZFAddressEditVillageCellIdentifier];
    
    // 防止异常
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

+ (NSString *)currentCellIdentifier:(ZFAddressEditType)cellType {
    switch (cellType) {
        case ZFAddressEditTypeTopMessage: {
            return kZFAddressTopMessageTableViewCellIdentifier;
        }
            break;
        case ZFAddressEditTypeFirstName :
        case ZFAddressEditTypeLastName :{
            return kZFAddressEditNameTableViewCellIdentifier;
        }
            break;
            
        case ZFAddressEditTypeEmail: {
            return kZFAddressEditEmailTableViewCellIdentifier;
        }
            break;
        case ZFAddressEditTypeAddressFirst:
        case ZFAddressEditTypeAddressSecond: {
            return kZFAddressEditAddressTableViewCellIdentifier;
        }
            break;
            
        case ZFAddressEditTypeLandmark: {
            return kZFAddressEditLandMarksTableViewCellIdentifier;
        }
            break;
        case ZFAddressEditTypeCountry: {
            return kZFAddressEditCountryTableViewCellIdentifier;
        }
            break;
        case ZFAddressEditTypeState: {
            return kZFAddressEditStateTableViewCellIdentifier;
        }
            break;
        case ZFAddressEditTypeCity: {
            return kZFAddressEditCityTableViewCellIdentifier;
        }
            break;
        case ZFAddressEditTypeVillage: {
            return kZFAddressEditVillageCellIdentifier;
        }
            break;
        case ZFAddressEditTypeZipCode: {
            return kZFAddressEditZipCodeTableViewCellIdentifier;
        }
            break;
        case ZFAddressEditTypePhoneNumber: {
            return kZFAddressEditPhoneNumberTableViewCellIdentifier;
        }
            break;
        case ZFAddressEditTypeAlternatePhoneNumber: {
            return kZFAddressEditAlternatePhoneNumberCellIdentifier;
        }
            break;
        case ZFAddressEditTypeNationalId: {
            return kZFAddressEditNationalIDTableViewCellIdentifier;
        }
            break;
            
        case ZFAddressEditTypeWhatsApp: {
            return kZFAddressEditWhatsAppTableViewCellIdentifier;
        }
            break;
        case ZFAddressEditTypeSetDefault: {
            return kZFAddressEditSetDefaultTableViewCellIdentifier;
        }
            break;
    }
    return @"AddressCellID";
}

+ (void)configAddressEditBookInfo:(NSMutableArray *)dataArray infoModel:(ZFAddressInfoModel *)editModel village:(BOOL)hasVillage isOrderUpdate:(BOOL)isOrderUpdate {
    
    if (!ZFJudgeNSArray(dataArray) || !editModel) {
        return;
    }
    
    if (![dataArray isKindOfClass:[NSMutableArray class]]) {
        return;
    }
    
    [dataArray removeAllObjects];
    NSMutableArray *firstArray = [[NSMutableArray alloc] init];
    NSMutableArray *secondArray = [[NSMutableArray alloc] init];
    NSMutableArray *thirdArray = [[NSMutableArray alloc] init];
    // 订单地址修改
    NSMutableArray *orderArray = [[NSMutableArray alloc] init];
    if (isOrderUpdate) {
        [dataArray addObject:orderArray];
    } else {
        [dataArray addObject:firstArray];
        [dataArray addObject:secondArray];
        [dataArray addObject:thirdArray];
    }
    
    
    // ======================== 第一组 ======================== //
    
    ZFAddressEditTypeModel *firstNameModel = [[ZFAddressEditTypeModel alloc] init];
    firstNameModel.editType = ZFAddressEditTypeFirstName;
    firstNameModel.rowHeight = kZFAddressCellNormalHeight;
    [firstArray addObject:firstNameModel];
    
    ZFAddressEditTypeModel *lastNameModel = [[ZFAddressEditTypeModel alloc] init];
    lastNameModel.editType = ZFAddressEditTypeLastName;
    lastNameModel.rowHeight = kZFAddressCellNormalHeight;
    [firstArray addObject:lastNameModel];
    
    ZFAddressEditTypeModel *emailModel = [[ZFAddressEditTypeModel alloc] init];
    emailModel.editType = ZFAddressEditTypeEmail;
    emailModel.rowHeight = kZFAddressCellNormalHeight;
    [firstArray addObject:emailModel];
    
    // ======================== 第二组 ======================== //
    
    ZFAddressEditTypeModel *firstAddressModel = [[ZFAddressEditTypeModel alloc] init];
    firstAddressModel.editType = ZFAddressEditTypeAddressFirst;
    firstAddressModel.rowHeight = kZFAddressCellNormalHeight;
    
    ZFAddressEditTypeModel *secondAddressModel = [[ZFAddressEditTypeModel alloc] init];
    secondAddressModel.editType = ZFAddressEditTypeAddressSecond;
    secondAddressModel.rowHeight = kZFAddressCellNormalHeight;
    
    ZFAddressEditTypeModel *landmarkModel = [[ZFAddressEditTypeModel alloc] init];
    landmarkModel.editType = ZFAddressEditTypeLandmark;
    landmarkModel.rowHeight = kZFAddressCellNormalHeight;
    
    ZFAddressEditTypeModel *countryModel = [[ZFAddressEditTypeModel alloc] init];
    countryModel.editType = ZFAddressEditTypeCountry;
    countryModel.rowHeight = kZFAddressCellNormalHeight;
    
    ZFAddressEditTypeModel *stateModel = [[ZFAddressEditTypeModel alloc] init];
    stateModel.editType = ZFAddressEditTypeState;
    stateModel.rowHeight = kZFAddressCellNormalHeight;
    
    ZFAddressEditTypeModel *cityModel = [[ZFAddressEditTypeModel alloc] init];
    cityModel.editType = ZFAddressEditTypeCity;
    cityModel.rowHeight = kZFAddressCellNormalHeight;
    
    ZFAddressEditTypeModel *villageModel = [[ZFAddressEditTypeModel alloc] init];
    villageModel.editType = ZFAddressEditTypeVillage;
    villageModel.rowHeight = kZFAddressCellNormalHeight;
    
    // 罗马尼亚
    if ([editModel isRomaniaCountry]) {
        [secondArray addObject:countryModel];
        [secondArray addObject:stateModel];
        [secondArray addObject:cityModel];
        // 有四级城镇、村， 或一直显示四级栏
        if (hasVillage || editModel.showFourLevel) {
            [secondArray addObject:villageModel];
        }
        
        [secondArray addObject:firstAddressModel];
        if (editModel.is_cod) {
            [secondArray addObject:landmarkModel];
        }
        
    } else {
        [secondArray addObject:firstAddressModel];
        [secondArray addObject:secondAddressModel];

        if (editModel.is_cod) {
            [secondArray addObject:landmarkModel];
        }
        [secondArray addObject:countryModel];
        [secondArray addObject:stateModel];
        [secondArray addObject:cityModel];
        // 有四级城镇、村， 或一直显示四级栏
        if (hasVillage || editModel.showFourLevel) {
            [secondArray addObject:villageModel];
        }
    }
    
    
    // landMark
    
    if ([FilterManager requireCardNumWithAddressId:editModel.country_id]) {
        ZFAddressEditTypeModel *nationalModel = [[ZFAddressEditTypeModel alloc] init];
        nationalModel.editType = ZFAddressEditTypeNationalId;
        nationalModel.rowHeight = kZFAddressCellNormalHeight;
        [secondArray addObject:nationalModel];
    }
    
    ZFAddressEditTypeModel *zipCodeModel = [[ZFAddressEditTypeModel alloc] init];
    zipCodeModel.editType = ZFAddressEditTypeZipCode;
    zipCodeModel.rowHeight = kZFAddressCellNormalHeight;
    [secondArray addObject:zipCodeModel];
    
    ZFAddressEditTypeModel *phoneNumberModel = [[ZFAddressEditTypeModel alloc] init];
    phoneNumberModel.editType = ZFAddressEditTypePhoneNumber;
    phoneNumberModel.rowHeight = kZFAddressCellNormalHeight;
    [secondArray addObject:phoneNumberModel];
    
    if (editModel.is_cod) {
        ZFAddressEditTypeModel *phoneNumberAlternateModel = [[ZFAddressEditTypeModel alloc] init];
        phoneNumberAlternateModel.editType = ZFAddressEditTypeAlternatePhoneNumber;
        phoneNumberAlternateModel.rowHeight = kZFAddressCellNormalHeight;
        [secondArray addObject:phoneNumberAlternateModel];
        
        ZFAddressEditTypeModel *whatsAppModel = [[ZFAddressEditTypeModel alloc] init];
        whatsAppModel.editType = ZFAddressEditTypeWhatsApp;
        whatsAppModel.rowHeight = kZFAddressCellWhatsAppNormalHeight;
        [secondArray addObject:whatsAppModel];
    }
    
    // ======================== 第三组 ======================== //
    
    ZFAddressEditTypeModel *setDefaultModel = [[ZFAddressEditTypeModel alloc] init];
    setDefaultModel.editType = ZFAddressEditTypeSetDefault;
    setDefaultModel.rowHeight = 66;
    [thirdArray addObject:setDefaultModel];
    
    if (isOrderUpdate) {//订单地址修改
        
        // 罗马尼亚
        if ([editModel isRomaniaCountry]) {
            
            [orderArray addObject:countryModel];
            [orderArray addObject:stateModel];
            [orderArray addObject:cityModel];
            if (hasVillage || editModel.showFourLevel) {
                ZFAddressEditTypeModel *villageModel = [[ZFAddressEditTypeModel alloc] init];
                villageModel.editType = ZFAddressEditTypeVillage;
                villageModel.rowHeight = kZFAddressCellNormalHeight;
                [orderArray addObject:villageModel];
            }
            
            [orderArray addObject:firstAddressModel];
            if (editModel.is_cod) {
                ZFAddressEditTypeModel *landmarkModel = [[ZFAddressEditTypeModel alloc] init];
                landmarkModel.editType = ZFAddressEditTypeLandmark;
                landmarkModel.rowHeight = kZFAddressCellNormalHeight;
                [orderArray addObject:landmarkModel];
            }

        } else {
           
            [orderArray addObject:firstAddressModel];
            [orderArray addObject:secondAddressModel];
            if (editModel.is_cod) {
                ZFAddressEditTypeModel *landmarkModel = [[ZFAddressEditTypeModel alloc] init];
                landmarkModel.editType = ZFAddressEditTypeLandmark;
                landmarkModel.rowHeight = kZFAddressCellNormalHeight;
                [orderArray addObject:landmarkModel];
            }
            [orderArray addObject:countryModel];
            [orderArray addObject:stateModel];
            [orderArray addObject:cityModel];
            
            if (hasVillage || editModel.showFourLevel) {
                ZFAddressEditTypeModel *villageModel = [[ZFAddressEditTypeModel alloc] init];
                villageModel.editType = ZFAddressEditTypeVillage;
                villageModel.rowHeight = kZFAddressCellNormalHeight;
                [orderArray addObject:villageModel];
            }
        }
        
        [orderArray addObject:zipCodeModel];
        
        //v4.7.0订单地址修改，不显示国家号、区号
        phoneNumberModel.isHiddenPhoneCode = YES;
        [orderArray addObject:phoneNumberModel];
    }
}

+ (void)configCurrentEdit:(ZFAddressInfoModel *)editModel countryData:(NSDictionary *)countryInfoDic {
    
    if (!editModel) {
        return;
    }
    
    editModel.region_code = [countryInfoDic ds_stringForKey:@"country_code"];
    editModel.is_cod = [countryInfoDic ds_boolForKey:@"is_cod"];
    editModel.ownState = [countryInfoDic ds_boolForKey:@"ownState"];
    editModel.ownCity = [countryInfoDic ds_boolForKey:@"ownCity"];
    editModel.configured_number = [countryInfoDic ds_boolForKey:@"configured_number"];
    
    editModel.showFourLevel = [[countryInfoDic ds_stringForKey:@"showFourLevel"] boolValue];
    editModel.barangay = [countryInfoDic ds_stringForKey:@"barangay"];
    
    editModel.country_id = [countryInfoDic ds_stringForKey:@"country_id"];
    editModel.country_str = [countryInfoDic ds_stringForKey:@"country"];
    editModel.code = [countryInfoDic ds_stringForKey:@"code"];
    
    NSArray *supplier_number_list = [countryInfoDic ds_arrayForKey:@"supplier_number_list"];
    editModel.supplier_number_list = supplier_number_list;
    
    // v5.4.0 一个时，默认填充
    if (ZFJudgeNSArray(supplier_number_list) && supplier_number_list.count == 1) {
        editModel.supplier_number = ZFToString(supplier_number_list.firstObject);
        editModel.supplier_number_spare = ZFToString(supplier_number_list.firstObject);
    }
    
    NSArray *scut_number_list = [countryInfoDic ds_arrayForKey:@"scut_number_list"];
    editModel.scut_number_list = scut_number_list;
    
    editModel.isZipFourTip = NO;
    editModel.isCityTip = NO;
    editModel.isStateTip = NO;
    
    //手机用户登陆
    if ([AccountManager sharedManager].account.is_emerging_country == 1) {//手机注册用户
        editModel.is_emerging_country = 1;
        if (ZFIsEmptyString(editModel.tel)) {
            editModel.tel = [AccountManager sharedManager].account.phone;
        }
        //手机注册用户，新增时不默认用户个人信息上的邮箱
        editModel.email = ZFToString(editModel.email);
    } else {
        editModel.email = editModel.email ?: [AccountManager sharedManager].account.email;
    }
}
@end
