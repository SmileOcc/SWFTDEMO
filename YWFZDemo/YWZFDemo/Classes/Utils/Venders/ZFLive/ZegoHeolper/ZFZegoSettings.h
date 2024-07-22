//
//  ZFZegoSettings.h
//  ZZZZZ
//
//  Created by YW on 2019/8/6.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFZegoHelper.h"
#import "ZFZegoRoomInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFZegoSettings : NSObject {
    ZegoAVConfig *_currentConfig;
}

+ (instancetype)sharedInstance;

@property (nonatomic, copy) NSString *userID;
/// 重新设置名字，会释放 ZFZegoHelper
@property (nonatomic, copy) NSString *userName;

@property (nonatomic, readonly) NSArray *appTypeList;

@property (readonly) NSArray *presetVideoQualityList;
@property (nonatomic, strong) ZegoAVConfig *currentConfig;
@property (readonly) NSInteger presetIndex;
@property (nonatomic, assign) int beautifyFeature;
@property (readonly) CGSize currentResolution;

- (BOOL)selectPresetQuality:(NSInteger)presetIndex;
- (ZegoUser *)getZegoUser;
- (UIImage *)getBackgroundImage:(CGSize)viewSize withText:(NSString *)text;
- (NSUserDefaults *)myUserDefaults;

- (UIViewController *)getViewControllerFromRoomInfo:(ZFZegoRoomInfo *)roomInfo;
@end

NS_ASSUME_NONNULL_END
