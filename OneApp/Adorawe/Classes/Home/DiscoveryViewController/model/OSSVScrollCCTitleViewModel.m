//
//  OSSVScrollCCTitleViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/9/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVScrollCCTitleViewModel.h"

@interface OSSVScrollCCTitleViewModel ()

@end

@implementation OSSVScrollCCTitleViewModel
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
    return CGSizeMake(0, 30);
}

-(CGFloat)leftSpace {
    return 0;
}

-(NSString *)reuseIdentifier
{
    return @"ScrollerTitleViewID";
}

+(NSString *)reuseIdentifier
{
    return @"ScrollerTitleViewID";
}
@end
