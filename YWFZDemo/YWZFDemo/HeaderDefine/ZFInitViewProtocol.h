//
//  ZFInitViewProtocol.h
//  ZZZZZ
//
//  Created by YW on 2017/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//
#import <Foundation/Foundation.h>

/*!
 *  @brief 用于布局
 */
@protocol ZFInitViewProtocol <NSObject>

@required
/*!
 *  @brief 添加试图
 */
- (void)zfInitView;

/*!
 *  @brief 布局
 */
- (void)zfAutoLayoutView;

@end
