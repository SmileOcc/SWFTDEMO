//
//  OSSVThemeItemsGoodsRanksCCellModel.m
// XStarlinkProject
//
//  Created by odd on 2021/4/1.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVThemeItemsGoodsRanksCCellModel.h"

@implementation OSSVThemeItemsGoodsRanksCCellModel

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
    return @"STLThemeGoodsRankCCellID";
}

+(NSString *)reuseIdentifier
{
    return @"STLThemeGoodsRankCCellID";
}


@end
