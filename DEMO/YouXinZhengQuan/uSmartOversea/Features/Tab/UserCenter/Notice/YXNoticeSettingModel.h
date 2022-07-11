//
//  YXNoticeSettingModel.h
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2020/9/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXNoticeSettingModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, assign) BOOL isOn;

@property (nonatomic, assign) BOOL isArrow;
@property (nonatomic, assign) BOOL isSwitch;

@property (nonatomic, assign) NSInteger newsType;
@property (nonatomic, assign) BOOL isShowSelect;
@property (nonatomic, strong) NSString * minTitle; //小标题
@property (nonatomic, assign) BOOL isSubCell; //是cell的子栏
@property (nonatomic, assign) BOOL isShowLine; //是否显示line

@property (nonatomic, strong) NSString *settingId;

@property (nonatomic, strong) NSString * httpDataKey ; //对应返回的key
@property (nonatomic, assign) BOOL showBold; //显示加粗 操作
@property (nonatomic, assign) BOOL isOpened; //是否已开启功能
@property (nonatomic, strong) NSString * rightButonTitle; //右侧按钮标题

@property (nonatomic, assign) NSInteger  smType ; //盯盘精灵用
@property (nonatomic, strong) NSString * identifier; //盯盘精灵用

@end

@interface YXNoticeGroupSettingModel : NSObject

@property (nonatomic, strong) NSArray <YXNoticeSettingModel *>*settings;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *bottomTitle;

@property (nonatomic, strong) NSString *gruopId;

@end



NS_ASSUME_NONNULL_END
