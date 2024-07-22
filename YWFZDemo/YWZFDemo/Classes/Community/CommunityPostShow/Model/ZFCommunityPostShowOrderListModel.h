//
//  ZFCommunityPostShowOrderListModel.h
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFCommunityPostShowOrderListModel : NSObject
@property (nonatomic,copy) NSString *goods_id;
@property (nonatomic,copy) NSString *goods_sn;
@property (nonatomic,copy) NSString *goods_thumb;
@property (nonatomic,copy) NSString *goods_title;
@property (nonatomic,copy) NSString *shop_price;
@property (nonatomic,assign) BOOL isSelected;
@end
