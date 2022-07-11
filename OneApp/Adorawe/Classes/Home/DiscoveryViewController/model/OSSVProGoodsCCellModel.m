//
//  OSSVProGoodsCCellModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVProGoodsCCellModel.h"
#import "OSSVGoodssPricesView.h"

@interface OSSVProGoodsCCellModel ()

@property (nonatomic, assign) CGSize size;

@end

@implementation OSSVProGoodsCCellModel
@synthesize dataSource = _dataSource;
@synthesize channelId = _channelId;
@synthesize channelName = _channelName;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.size = CGSizeZero;
    }
    return self;
}

-(void)setDataSource:(OSSVHomeGoodsListModel *)dataSource
{
    _dataSource = dataSource;
    
    ///首页底部商品
    if ([_dataSource isKindOfClass:[OSSVHomeGoodsListModel class]]) {   
        CGFloat width = kGoodsWidth;
        
        OSSVHomeGoodsListModel *model = (OSSVHomeGoodsListModel *)_dataSource;
        //满减活动

        
        CGFloat fullHeight = model.goodsListPriceHeight;
        if (!(model.flash_sale && [model.flash_sale isOnlyFlashActivity]) && !model.hadHandlePriceHeight) {
            model.hadHandlePriceHeight = YES;
            CGFloat activityHeight = [OSSVGoodssPricesView activithHeight:model.tips_reduction contentWidth:kGoodsWidth];
            fullHeight = [OSSVGoodssPricesView contentHeight:activityHeight];
            model.goodsListPriceHeight = fullHeight;
            model.goodsListFullActitityHeight = activityHeight;
        }
        
        CGFloat height = width * 4.0 / 3.0 + fullHeight;
        if (dataSource.goods_img_w > 0 && dataSource.goods_img_h > 0) {
            CGFloat scale = width / dataSource.goods_img_w;
            height = dataSource.goods_img_h * scale + fullHeight;
        }
        
        if (APP_TYPE == 3) {
            height = width + fullHeight;
        }
        self.size = CGSizeMake(width, height);
    }
    
    
    ////原生专题瀑布流
    if ([_dataSource isKindOfClass:[STLHomeCGoodsModel class]]) {
        
        STLHomeCGoodsModel *model = (STLHomeCGoodsModel *)_dataSource;
        
        //满减活动
        
        CGFloat fullHeight = model.goodsListPriceHeight;
        if (!(model.flash_sale && [model.flash_sale isOnlyFlashActivity]) && !model.hadHandlePriceHeight) {
            model.hadHandlePriceHeight = YES;
            CGFloat activityHeight = [OSSVGoodssPricesView activithHeight:model.tips_reduction contentWidth:kGoodsWidth];
            fullHeight = [OSSVGoodssPricesView contentHeight:activityHeight];
            model.goodsListPriceHeight = fullHeight;
            model.goodsListFullActitityHeight = activityHeight;
        }
        
        CGFloat width = kGoodsWidth;
        CGFloat height = width * 4.0 / 3.0 + fullHeight;
        //头疼
//        if ([model.imgWidth floatValue] > 0) {
//            height = width * [model.imgHeight floatValue] / [model.imgWidth floatValue] + fullHeight;
//        } else if(model.goods_img_w > 0) {
//            height = width * model.goods_img_h / model.goods_img_w + fullHeight;
//        }
        
        if (model.goods_img_w > 0 && dataSource.goods_img_h > 0) {
            height = width * model.goods_img_h / model.goods_img_w + fullHeight;
        }
        
        if (APP_TYPE == 3) {
            height = width + fullHeight;
        }
        
        self.size = CGSizeMake(width, height);
    }
}

- (void)setChannelId:(NSString *)channelId {
    _channelId = channelId;
}

- (void)setChannelName:(NSString *)channelName {
    _channelName = channelName;
}


-(CGSize)customerSize
{
    return self.size;
}

-(CGFloat)leftSpace {
    return 16;
}

-(NSString *)reuseIdentifier
{
    return @"WaterID";
}

+(NSString *)reuseIdentifier
{
    return @"WaterID";
}

@end
