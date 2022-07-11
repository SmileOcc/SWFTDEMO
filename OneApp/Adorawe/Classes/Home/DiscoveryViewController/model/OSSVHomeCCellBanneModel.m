//
//  OSSVHomeCCellBanneModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeCCellBanneModel.h"

@implementation OSSVHomeCCellBanneModel
@synthesize dataSource = _dataSource;
@synthesize channelId = _channelId;
@synthesize channelName = _channelName;

-(void)setDataSource:(NSObject *)dataSource
{
    _dataSource = dataSource;
}

- (void)setChannelId:(NSString *)channelId {
    _channelId = channelId;
}

- (void)setChannelName:(NSString *)channelName {
    _channelName = channelName;
}


-(CGSize)customerSize{
    return CGSizeMake(SCREEN_WIDTH, floor(SCREEN_WIDTH * 212.0 / 375.0));
}

-(CGFloat)leftSpace {
    return 0;
}

-(NSString *)reuseIdentifier{
    return @"BannerCellID";
}

+(NSString *)reuseIdentifier{
    return @"BannerCellID";
}
@end
