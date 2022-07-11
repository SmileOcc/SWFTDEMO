//
//  OSSVAsinglADCellModel.m
// XStarlinkProject
//
//  Created by odd on 2020/9/16.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVAsinglADCellModel.h"

@implementation OSSVAsinglADCellModel

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
    return CGSizeMake(SCREEN_WIDTH, floor(SCREEN_WIDTH * 200.0 / 375.0));
}

-(CGFloat)leftSpace {
    return 0;
}

-(NSString *)reuseIdentifier
{
    return @"AsingleAdvCellID";
}

+(NSString *)reuseIdentifier
{
    return @"AsingleAdvCellID";
}

@end
