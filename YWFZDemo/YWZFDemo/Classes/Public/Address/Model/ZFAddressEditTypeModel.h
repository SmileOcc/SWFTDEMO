//
//  ZFAddressEditTypeModel.h
//  ZZZZZ
//
//  Created by YW on 2017/9/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZFAddressEditType) {
    /** 第一个地址*/
    ZFAddressEditTypeAddressFirst = 0,
    /** 第二个地址*/
    ZFAddressEditTypeAddressSecond,
    /** 国家*/
    ZFAddressEditTypeCountry,
    /** 州、省*/
    ZFAddressEditTypeState,
    /** 城市*/
    ZFAddressEditTypeCity,
    /** 城镇、村级*/
    ZFAddressEditTypeVillage,
    /** 姓*/
    ZFAddressEditTypeFirstName,
    /** 名*/
    ZFAddressEditTypeLastName,
    /** 邮箱*/
    ZFAddressEditTypeEmail,
    /** 国家标志*/
    ZFAddressEditTypeLandmark,
    /** nationID*/
    ZFAddressEditTypeNationalId,
    /** 邮编*/
    ZFAddressEditTypeZipCode,
    /** 电话号码*/
    ZFAddressEditTypePhoneNumber,
    /** 选填电话号码*/
    ZFAddressEditTypeAlternatePhoneNumber,
    /** whatsAPp*/
    ZFAddressEditTypeWhatsApp,
    /** 设置默认地址*/
    ZFAddressEditTypeSetDefault,
    /** 顶部提示*/
    ZFAddressEditTypeTopMessage
};

@interface ZFAddressEditTypeModel : NSObject
@property (nonatomic, assign) ZFAddressEditType     editType;
@property (nonatomic, assign) CGFloat               rowHeight;
@property (nonatomic, assign) BOOL                  isCheckEnter;
/**是否显示错误提示*/
@property (nonatomic, assign) BOOL                  isShowTips;
/**是否超过最大值*/
@property (nonatomic, assign) BOOL                  isOverMax;
/**是否编辑中*/
@property (nonatomic, assign) BOOL                  isEditing;
/**电话号码：是否隐藏国家号、区号*/
@property (nonatomic, assign) BOOL                  isHiddenPhoneCode;
/**是否显示自动填充zip提示*/
@property (nonatomic, assign) BOOL                  isShowFillZipTips;

/**是否显示底部提示*/
@property (nonatomic, assign) BOOL                  isShowBottomTip;

@end
