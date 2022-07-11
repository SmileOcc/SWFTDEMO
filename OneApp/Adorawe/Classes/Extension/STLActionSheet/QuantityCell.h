//
//  QuantityCell.h
// XStarlinkProject
//
//  Created by 10010 on 2017/9/19.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,QuantityCellEvent) {
    /** 增加*/
    QuantityCellEventIncrease,
    /** 减少*/
    QuantityCellEventReduce
};


typedef void (^QuantityCellOperateBlock)(UIButton *sender, QuantityCellEvent event);


@interface QuantityCell : UICollectionViewCell

+ (QuantityCell *)quantityCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy) void(^goodsNumBlock)(NSString *goodsNum);
@property (nonatomic, copy) void(^operateBlock)(QuantityCellEvent event);

@property (nonatomic, assign) GoodsDetailEnumType                 type;

@property (nonatomic, assign) NSInteger                           currentCount;
@property (nonatomic, assign) OSSVDetailsBaseInfoModel     *baseInfoModel;

//@property (nonatomic, strong) UILabel                        *resultLabel;
@property (nonatomic, strong) UIView                         *separateLineView;
@property (nonatomic, strong) UILabel                        *quantityLabel;
/** 仅剩库存X件*/
@property (nonatomic, strong) UILabel                        *storgeLabel;

/** 操作View*/
@property (nonatomic, strong) UIView                         *operationView;
/** 商品数量*/
@property (nonatomic, strong) UILabel                        *countLabel;
/** 减少按钮*/
@property (nonatomic, strong) UIButton                       *decreaseBtn;
/** 增加按钮*/
@property (nonatomic, strong) UIButton                       *increaseBtn;


//- (void)updatequantityCell:(NSString *)attribute;
//
//+ (CGFloat)heightquantityCell:(NSString *)attribute;

//处理商品数量显示
- (void)handleGoodsNumber:(OSSVDetailsBaseInfoModel *)baseInfoModel currnetCount:(NSInteger)count;
@end
