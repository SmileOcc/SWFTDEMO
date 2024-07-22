//
//  ZFAccountProductCell.h
//  ZZZZZ
//
//  Created by YW on 2019/1/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  个人中心，商品显示cell

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZFAccountProductCellDelegate <NSObject>

- (void)ZFAccountProductCellDidSelectProduct:(ZFGoodsModel *)goodsModel;

@end

@interface ZFAccountProductCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier abFlag:(NSInteger)flag;

//通过ABTest flag 获取每行显示的商品数量
+ (CGSize)productCellSize:(NSInteger)recommendFlag;

+ (NSInteger)numberRowsWithFlag:(NSInteger)recommendFlag;

@property (nonatomic, strong) NSArray<ZFGoodsModel *>* goodsList;
@property (nonatomic, weak) id<ZFAccountProductCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
