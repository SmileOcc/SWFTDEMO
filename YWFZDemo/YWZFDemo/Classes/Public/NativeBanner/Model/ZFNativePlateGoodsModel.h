//
//  ZFNativePlateGoodsModel.h
//  ZZZZZ
//
//  Created by YW on 27/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZFGoodsModel;

@interface ZFNativePlateGoodsModel : NSObject

@property (nonatomic, copy)   NSString                                     *plate_title;

@property (nonatomic, strong) NSArray<ZFGoodsModel *>                      *goodsArray;

@end
