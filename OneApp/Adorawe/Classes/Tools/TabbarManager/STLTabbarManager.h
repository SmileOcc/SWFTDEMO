//
//  STLTabbarManager.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLTabbarViewModel.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, STLDeviceImageType) {
    STLDeviceImageType2X,
    STLDeviceImageType3X,
    STLDeviceImageTypeIphoneX,
    STLDeviceImageType_Simulator
};

@interface STLTabbarManager : NSObject

@property (nonatomic, assign) STLDeviceImageType type;
@property (nonatomic, strong) STLTabbarModel *model;

@property (nonatomic, copy) NSString *tempGifImagePath;

+ (instancetype)sharedInstance;
- (void)setUp;
- (STLDeviceImageType)getDeviceType;
@end
