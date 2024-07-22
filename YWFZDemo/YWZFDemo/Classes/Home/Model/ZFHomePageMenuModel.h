//
//  ZFHomePageMenuModel.h
//  ZZZZZ
//
//  Created by YW on 2018/11/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFHomePageMenuModel : NSObject

/**
 * 标题
 */
@property (nonatomic, copy)   NSString  *tabTitle;
/**
 * 频道 id  之前 -1 代表是首页
 */
@property (nonatomic, copy)   NSString  *channel_id;

/**
 * 跳转类型 之前大于 0 代表加载虚拟分类商品
 */
@property (nonatomic, copy)   NSString  *jump_type;

@end
