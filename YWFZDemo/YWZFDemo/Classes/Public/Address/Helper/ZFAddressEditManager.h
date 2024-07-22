//
//  ZFAddressEditManager.h
//  ZZZZZ
//
//  Created by YW on 2019/6/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ZFAddressEditNameTableViewCell.h"
#import "ZFAddressEditEmailTableViewCell.h"
#import "ZFAddressEditAddressTableViewCell.h"
#import "ZFAddressEditCountryTableViewCell.h"
#import "ZFAddressEditStateTableViewCell.h"
#import "ZFAddressEditCityTableViewCell.h"
#import "ZFAddressEditZipCodeTableViewCell.h"
#import "ZFAddressEditNationalIDTableViewCell.h"
#import "ZFAddressEditSetDefaultTableViewCell.h"
#import "ZFAddressEditPhoneNumberTableViewCell.h"
#import "ZFAddressEditWhatsAppTableViewCell.h"
#import "ZFAddressEditAlternatePhoneNumberCell.h"
#import "ZFAddressEditLandMarksTableViewCell.h"
#import "ZFAddressTopMessageTableViewCell.h"
#import "ZFAddressEditVillageCell.h"

#import "ZFColorDefiner.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "YSAlertView.h"
#import "FilterManager.h"
#import "YWCFunctionTool.h"
#import "NSDictionary+SafeAccess.h"
#import "AccountManager.h"
#import "ZFAddressEditTypeModel.h"
#import "ZFAddressInfoModel.h"
#import "ZFLocationInfoModel.h"

static CGFloat kZFAddressCellTipsErrorHeight = 70;
static CGFloat kZFAddressCellNormalHeight = 50;
static CGFloat kZFAddressCellWhatsAppNormalHeight = 80;



static NSString *const kZFAddressEditNameTableViewCellIdentifier = @"kZFAddressEditNameTableViewCellIdentifier";
static NSString *const kZFAddressEditEmailTableViewCellIdentifier = @"kZFAddressEditEmailTableViewCellIdentifier";
static NSString *const kZFAddressEditAddressTableViewCellIdentifier = @"kZFAddressEditAddressTableViewCellIdentifier";
static NSString *const kZFAddressEditCountryTableViewCellIdentifier = @"kZFAddressEditCountryTableViewCellIdentifier";
static NSString *const kZFAddressEditStateTableViewCellIdentifier = @"kZFAddressEditStateTableViewCellIdentifier";
static NSString *const kZFAddressEditCityTableViewCellIdentifier = @"kZFAddressEditCityTableViewCellIdentifier";
static NSString *const kZFAddressEditZipCodeTableViewCellIdentifier = @"kZFAddressEditZipCodeTableViewCellIdentifier";
static NSString *const kZFAddressEditNationalIDTableViewCellIdentifier = @"kZFAddressEditNationalIDTableViewCellIdentifier";
static NSString *const kZFAddressEditSetDefaultTableViewCellIdentifier = @"kZFAddressEditSetDefaultTableViewCellIdentifier";
static NSString *const kZFAddressEditPhoneNumberTableViewCellIdentifier = @"kZFAddressEditPhoneNumberTableViewCellIdentifier";
static NSString *const kZFAddressEditWhatsAppTableViewCellIdentifier = @"kZFAddressEditWhatsAppTableViewCellIdentifier";
static NSString *const kZFAddressEditAlternatePhoneNumberCellIdentifier = @"kZFAddressEditAlternatePhoneNumberCellIdentifier";
static NSString *const kZFAddressEditLandMarksTableViewCellIdentifier = @"kZFAddressEditLandMarksTableViewCellIdentifier";
static NSString *const kZFAddressTopMessageTableViewCellIdentifier = @"kZFAddressTopMessageTableViewCellIdentifier";
static NSString *const kZFAddressEditVillageCellIdentifier = @"kZFAddressEditVillageCellIdentifier";

@interface ZFAddressEditManager : NSObject

///设置第一个处于编辑状态
+ (void)firstNameBecomeFirstResponderTable:(UITableView *)tableview source:(NSArray *)sourceArray;

///判断内容是否编辑
+ (BOOL)isEditAddressSource:(NSDictionary *)sourceDic editModel:(NSDictionary *)editDic;
///保存判断输入完成
+ (BOOL)isCheckEnterInfoSuccess:(NSArray *)datas addressInfoModel:(ZFAddressInfoModel *)editModel village:(BOOL)hasVillage;

///是否编辑了国家、州、省、城镇、邮编
+ (BOOL)isEditCountryStateCityBarangayZip:(ZFAddressEditTypeModel *)model addressInfoModel:(ZFAddressInfoModel *)editModel content:(NSString *)content;
///是否编辑了国家、州、省、城镇
+ (BOOL)isEditCountryStateCityBarangay:(ZFAddressEditTypeModel *)model  addressInfoModel:(ZFAddressInfoModel *)editModel content:(NSString *)content;

///更新对应cell数据源
+ (void)updateAddressInfoModel:(ZFAddressInfoModel *)editModel editTypeModel:(ZFAddressEditTypeModel *)model content:(NSString *)content;

///cod状态下，才有whatsapp
+ (void)editAddressInfoModel:(ZFAddressInfoModel *)editModel whatApp:(NSString *)whatsApp;

//获取选择数据模型
+ (ZFAddressEditTypeModel *)editTypeModelSource:(NSArray *)sourceArray indexPath:(NSIndexPath *)indexPath;

//获取类型取数据模型
+ (ZFAddressEditTypeModel *)editTypeModelSource:(NSArray *)sourceArray editType:(ZFAddressEditType )editType;

//获取类型取数据模型
+ (NSIndexPath *)indexPathModelSource:(NSArray *)sourceArray editTypeModel:(ZFAddressEditTypeModel *)model;

///自动填充定位信息
+ (void)autofillTable:(UITableView *)tableView sourceData:(NSArray *)sourceArray editModel:(ZFAddressInfoModel *)editModel locationInfo:(ZFAddressLocationInfoModel *)infoModel;

///订单地址修改提示
+ (void)showOrderAddressContactCustomerMsg:(NSString *)msg completion:(void (^)(NSInteger buttonIndex))completion;
+ (void)showOrderAddressChangedSuccess:(void (^)(NSInteger buttonIndex))completion;

/*
 * msg:nil时，返回网络问题
 *
 */
+ (void)showOrderAddressChangedError:(NSString *)msg completion:(void (^)(NSInteger buttonIndex))completion;


///表配置
+ (void)configBaseTable:(UITableView *)tableView;
+ (NSString *)currentCellIdentifier:(ZFAddressEditType)cellType;

///配置界面显示数据源
+ (void)configAddressEditBookInfo:(NSMutableArray *)dataArray infoModel:(ZFAddressInfoModel *)editModel village:(BOOL)hasVillage isOrderUpdate:(BOOL)isOrderUpdate;

///新增地址时需要获取当前国家地址信息, 自动填充到地址栏
+ (void)configCurrentEdit:(ZFAddressInfoModel *)editModel countryData:(NSDictionary *)countryInfoDic;

@end

