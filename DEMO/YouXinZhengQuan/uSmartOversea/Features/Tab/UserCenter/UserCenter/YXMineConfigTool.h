//
//  YXMineConfigTool.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/6/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXMineConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXMineConfigTool : NSObject

@property (nonatomic, strong) YXMineConfigModel *configModel;

- (void)loadDataWithSuccess:(void (^) (BOOL isModified, YXMineConfigModel *configModel))callBack;

+ (NSString *)getTitleWithModel: (YXMineConfigNameModel *)model;

+ (NSString *)getLogUrlWithModel: (YXMineConfigLogModel *)model;

@end

NS_ASSUME_NONNULL_END
