//
//  ZFAnalyticsOperation.h
//  ZZZZZ
//
//  Created by YW on 2019/6/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZFAnalyticsDoneBlock)(void);

@interface ZFAnalyticsOperation : NSBlockOperation

///保存上传数据的容器
@property (nonatomic, strong) NSMutableArray *analyticsList;

@property (nonatomic, copy) ZFAnalyticsDoneBlock doneBlock;

- (instancetype)initAnalyticsOperation;

@end

NS_ASSUME_NONNULL_END
