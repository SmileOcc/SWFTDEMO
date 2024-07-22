//
//  ZFBTSDataSets.h
//  ZZZZZ
//
//  Created by YW on 2019/6/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  获取的BTS数据集合

#import <Foundation/Foundation.h>
#import "ZFBTSModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFBTSDataSets : NSObject

+ (instancetype)sharedInstance;

///所有的BTS的数据，都需要加入这个队列里面
- (void)addObject:(ZFBTSModel *)btsModel;

- (void)addObjectFromeArray:(NSArray <ZFBTSModel *> *)btsModelList;

///获取存储的bts数据
- (NSArray <NSDictionary *> *)gainBtsSets;

///清除bts数据
- (void)clearBtsSets;

///接口拦截名单
- (NSDictionary <NSString *, Class>*)interceptProtocol;

///网络请求拦截 session 的配置
+ (NSURLSessionConfiguration *)ZFURLProtocolSessionConfiguration;

///URL拦截的数据key
- (NSArray *)BTSinjectAllkeys;

@end

NS_ASSUME_NONNULL_END
