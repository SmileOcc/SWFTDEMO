//
//  OSSVTopicCCellModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVTopicCCellModel.h"

@interface OSSVTopicCCellModel ()

@end

@implementation OSSVTopicCCellModel
@synthesize dataSource = _dataSource;
@synthesize channelId = _channelId;
@synthesize channelName = _channelName;

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    return self;
}

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
    //热门商品
    CGFloat height = ((SCREEN_WIDTH == 320.0) ? 92.0f : 84.0f) * DSCREEN_WIDTH_SCALE;
    return CGSizeMake(0, floor(height));
}

-(CGFloat)leftSpace {
    return 0;
}

-(NSString *)reuseIdentifier
{
    return @"TopicID";
}

+(NSString *)reuseIdentifier
{
    return @"TopicID";
}
@end
