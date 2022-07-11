//
//  YXModuleResponseModel.h
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2021/4/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXModel.h"
#import "YXResponseModel.h"
#import <IGListDiffKit/IGListDiff.h>

NS_ASSUME_NONNULL_BEGIN

@class YXModuleModel;
@interface YXModuleResponseModel : YXResponseModel<IGListDiffable>
@property (nonatomic, strong) NSArray<YXModuleModel*>* appModuleVOS;
@end

@interface YXModuleModel : NSObject
@property (nonatomic, strong) NSString * blackIcon; //模块图标(深夜模式)
@property (nonatomic, strong) NSString * moduleName; //模块名称
@property (nonatomic, strong) NSString * icon;    //模块图标
@property (nonatomic, assign) NSInteger jumpMethod; //跳转方式（1：H5 2：原生）
@property (nonatomic, strong) NSString * jumpAddress; //跳转链接
@property (nonatomic, strong) NSString * moduleNameHk; //模块名称(繁体)
@property (nonatomic, strong) NSString * moduleNameUs; //模块名称(英文)
@property (nonatomic, assign) NSTimeInterval redPointTimestamp; //小红点时间戳
@property (nonatomic, strong, nullable) id context;
@end
NS_ASSUME_NONNULL_END


