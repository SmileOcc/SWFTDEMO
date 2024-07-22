//
//  ZFCommunityZShowView.h
//  ZZZZZ
//
//  Created by YW on 2018/5/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFInitViewProtocol.h"

/**
 Z-ME 点加号弹窗
 */
/// v4.8.0 废弃 occ
@interface ZFCommunityZShowView : NSObject <ZFInitViewProtocol>

@property (nonatomic, copy) void (^showsCallback)(void);
@property (nonatomic, copy) void (^outfitsCallback)(void);

+ (instancetype)shareInstance;
- (void)show;

@end
