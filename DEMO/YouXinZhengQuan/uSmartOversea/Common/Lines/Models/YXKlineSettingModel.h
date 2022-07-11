//
//  YXKlineSettingModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2019/12/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface YXKlineSubConfigModel : NSObject

@property (nonatomic, assign) BOOL isHidden;
// ma和mavol的类型是1 ,默认是0
@property (nonatomic, assign) NSInteger type;
// 周期
@property (nonatomic, assign) NSInteger cycle;
// 标题
@property (nonatomic, strong) NSString *title;
// 占位符
@property (nonatomic, strong) NSString *placeholder;

@end




@interface YXKlineSettingModel : NSObject

// 指标说明
@property (nonatomic, strong) NSString *explain;
// 第一组
@property (nonatomic, strong) NSArray <YXKlineSubConfigModel *>*firstArr;
// 第二组
@property (nonatomic, strong) NSArray <YXKlineSubConfigModel *>*secondArr;
// 指标类型
@property (nonatomic, assign) NSInteger indexType;

@end

NS_ASSUME_NONNULL_END
