//
//  GoodsDetialSizeModel.h
//  Dezzal
//
//  Created by ZJ1620 on 16/8/1.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZFSizeTipsTextModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *value;

@property (nonatomic, assign) CGFloat titleWith;
@end


@interface ZFSizeTipsArrModel : NSObject
@property (nonatomic, strong) NSArray<ZFSizeTipsTextModel *> *tipsTextModelArray;
@property (nonatomic, copy) NSString *str_unit;

- (NSArray *)configuTipsTitleWidth;

@end


@interface GoodsDetialSizeModel : NSObject

@property (nonatomic, copy) NSString   *  goods_id;         //商品ID
@property (nonatomic, copy) NSString   *  attr_value;      //属性值
@property (nonatomic, assign) NSInteger    is_click;//商品是否售罄，0否，1是没有库存，2是下架
@property (nonatomic, copy) NSString   *data_tips;
@property (nonatomic, strong) ZFSizeTipsArrModel *sizeTipsArrModel;  //v4.9.0 增加尺码列表(bts)
@end
