//
//  YXStockDealDeatailCell.h
//  uSmartOversea
//
//  Created by rrd on 2018/8/1.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YXTick;

typedef NS_ENUM(NSInteger, YXTickDirection){
    
    YXTickDirectionDefault = 0, //默认
    YXTickDirectionSell = 2, //卖
    YXTickDirectionBuy = 1 //买
    
};

@interface YXStockDealDeatailCell : UITableViewCell

@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIView *animationView;

@property (nonatomic, assign) NSInteger decimalCount;
@property (nonatomic, assign) BOOL isLastRow;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isBTDeal:(BOOL)isBTDeal;

//cell刷新数据方法
- (void)reloadDataWithModel:(YXTick *)tickDetailModel pclose:(double)pclose priceBase:(double)priceBase isCryptos:(BOOL)isCryptos;

@end
