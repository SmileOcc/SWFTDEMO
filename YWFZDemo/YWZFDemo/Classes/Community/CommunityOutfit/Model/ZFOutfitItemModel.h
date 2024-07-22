//
//  ZFOutfitItemModel.h
//  ZZZZZ
//
//  Created by YW on 2018/5/24.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"
/**
 每个ZFOutfitItemView对象都对应有这样一个参数
 */
@interface ZFOutfitItemModel : NSObject

@property (nonatomic, copy) NSString    *cateID;    // 所属分类
@property (nonatomic, copy) NSString    *imageURL;  // 图的URL
//@property (nonatomic, copy) NSString    *goodsID;   // 商品ID
//@property (nonatomic, assign) NSInteger index;      // 所属分类列表的对象索引

@property (nonatomic, strong) ZFGoodsModel *goodModel;
//自定义图片
@property (nonatomic, strong) UIImage   *photoImage;

@end
