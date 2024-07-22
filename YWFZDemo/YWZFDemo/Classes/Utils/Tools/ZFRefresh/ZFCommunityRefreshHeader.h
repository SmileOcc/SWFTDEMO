//
//  ZFCommunityRefreshHeader.h
//  ZZZZZ
//
//  Created by YW on 2018/7/16.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityRefreshHeader.h"
#import <MJRefresh/MJRefresh.h>

typedef void (^PullingShowBannerBlock)(NSString *image);

@interface ZFCommunityRefreshHeader : MJRefreshHeader

@property (nonatomic, copy) PullingShowBannerBlock pullingShowBannerBlock;

- (void)setHeaderTipMessage:(NSString *)message;
@end
