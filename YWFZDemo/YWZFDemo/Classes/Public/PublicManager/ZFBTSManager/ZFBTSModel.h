//
//  ZFBTSModel.h
//  ZZZZZ
//
//  Created by YW on 2019/3/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  BTS模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFBTSModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString *bucketid;
/** 试验名称*/
@property (nonatomic, copy) NSString *plancode;

@property (nonatomic, copy) NSString *planid;

/** 试验结果值*/
@property (nonatomic, copy) NSString *policy;

@property (nonatomic, copy) NSString *versionid;

- (NSDictionary *)getBtsParams;

/** 判断是否为真实的BTS*/
- (BOOL)isReallyBTSModel;
@end

NS_ASSUME_NONNULL_END
