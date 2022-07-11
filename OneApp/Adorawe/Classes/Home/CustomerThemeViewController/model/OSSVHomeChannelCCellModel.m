//
//  OSSVHomeChannelCCellModel.m
// OSSVHomeChannelCCellModel
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeChannelCCellModel.h"

@implementation OSSVHomeChannelCCellModel
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
-(CGSize)customerSize
{
    return CGSizeMake(SCREEN_WIDTH, 44);
}

-(NSString *)reuseIdentifier
{
    return @"ChannelCellID";
}

+(NSString *)reuseIdentifier
{
    return @"ChannelCellID";
}
@end
