//
//  CommendModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVGoodsListModel.h"

@interface CommendModel : STLGoodsBaseModel<BCORMEntityProtocol>
@property (nonatomic,copy) NSString *rowid;//数据库ID
//@property (nonatomic,copy) NSString *goodsId;//商品ID
@property (nonatomic,copy) NSString *goodsSn;//商品SKU
@property (nonatomic,copy) NSString *goodsGroupId;//商品组ID
@property (nonatomic,copy) NSString *goodsTitle;//商品名称
@property (nonatomic,copy) NSString *goodsPrice;//商品价格
@property (nonatomic,copy) NSString *goodsAttr;//商品属性
@property (nonatomic,copy) NSString *goodsThumb;//商品缩略图
@property (nonatomic,copy) NSString *coverImgUrl;//封面缩略图
@property (nonatomic,copy) NSString *goodsBigImg;//商品原图
@property (nonatomic,copy) NSString *modify;//修改时间
@property (nonatomic,copy) NSString *warehouseCode;//仓库
@property (nonatomic,copy) NSString *wid;//仓库
@property (nonatomic,assign) BOOL isSelected;
//@property (nonatomic,copy) NSString *catName;//分类名称

- (NSString *)showImageUrl;

-(instancetype)initWith:(OSSVGoodsListModel *)goodListModel;
@end
