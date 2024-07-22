//
//  ZFCartBtsModel.h
//  ZZZZZ
//
//  Created by YW on 2018/10/29.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  大数据 BTS AB 测试模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCartBtsModel : NSObject

@property (nonatomic, copy) NSString *bucketid;
@property (nonatomic, copy) NSString *plancode;
@property (nonatomic, copy) NSString *planid;
///流程：0（默认，原始流程，没有游客购）、A（游客购买流程），plancode为youke2，
@property (nonatomic, copy) NSString *policy;
@property (nonatomic, copy) NSString *versionid;
@end

NS_ASSUME_NONNULL_END
