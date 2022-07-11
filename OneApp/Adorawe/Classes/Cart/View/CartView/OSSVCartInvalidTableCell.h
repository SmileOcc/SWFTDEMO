//
//  CartTableInvalidCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/10.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartBaseGoodsCell.h"
#import "CartModel.h"
#import "OSSVCartGoodImageMarkView.h"

@interface OSSVCartInvalidTableCell : OSSVCartBaseGoodsCell

+ (OSSVCartInvalidTableCell *)cellTableInvalidWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;


/** 商品图片*/
@property (nonatomic, strong) YYAnimatedImageView            *iconView;
/** 商品名称*/
@property (nonatomic, strong) UILabel                        *titleLabel;
/** 商品属性*/
@property (nonatomic, strong) UILabel                        *propertyLabel;
/** 区级*/
@property (nonatomic, strong) UIButton                       *rateBtn;
/** 商品价格*/
@property (nonatomic, strong) UILabel                        *priceLabel;

/** 市场价格*/
@property (nonatomic, strong) UILabel                        *markePriceLabel;

/** 商品状态*/
@property (nonatomic, strong) UILabel                        *stateLabel;

@property (nonatomic, strong) UIView                         *lineView;

@property (nonatomic, strong) OSSVCartGoodImageMarkView       *imageMarkView;

////折扣标 闪购
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView   *activityStateView;

/** 删除*/
@property (nonatomic, strong) UIButton                       *deleteButton;
@property (nonatomic, strong) UIButton                       *collectionButton;
@property (nonatomic, strong) UIImageView                    *flashImageView; //闪购商品价格后的图标
@property (nonatomic, strong) UIImageView                    *unCheckImgView; //左边不能选择的图标
@end
