//
//  OSSVMultProGoodsCCellModel.m
// XStarlinkProject
//
//  Created by odd on 2021/1/11.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVMultProGoodsCCellModel.h"

@interface OSSVMultProGoodsCCellModel ()

@property (nonatomic, assign) CGSize size;

@end

@implementation OSSVMultProGoodsCCellModel
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
    
    ///首页底部商品 v1.2.0 首页没有
//    if ([_dataSource isKindOfClass:[HomeGoodListModel class]]) {
//        CGFloat width = (SCREEN_WIDTH - 4 * kPadding) / 3.0;
//        CGFloat height = width * 145.0 / 109.0 + 34;
//        self.size = CGSizeMake(width, height);
//    }
    
    
    ////原生专题瀑布流
    if ([_dataSource isKindOfClass:[STLHomeCGoodsModel class]]) {
        
        CGFloat width = (SCREEN_WIDTH - 4 * kPadding) / 3.0;
        CGFloat height = width * 145.0 / 109.0 + 34;
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
    return @"MultipleProductCCellID";
}

+(NSString *)reuseIdentifier
{
    return @"MultipleProductCCellID";
}

@end
