//
//  GoodsDetialColorModel.h
//  Dezzal
//
//  Created by ZJ1620 on 16/8/1.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"

@interface GoodsDetialColorModel : NSObject<YYModel>

@property (nonatomic, copy) NSString   *  goods_id;         //商品ID
@property (nonatomic, copy) NSString   *  attr_value;      //属性值
@property (nonatomic, copy) NSString   *  color_code;      //颜色数值
@property (nonatomic, copy) NSString   *  color_img;       //无颜色时的图片
@property (nonatomic, assign) NSInteger    is_click;//商品是否售罄，0否，1是没有库存，2是下架

@end
