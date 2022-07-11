//
//  OSSVScrollAdvCCellModel.m
// XStarlinkProject
//
//  Created by odd on 2020/10/22.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVScrollAdvCCellModel.h"

@implementation OSSVScrollAdvCCellModel
@synthesize dataSource = _dataSource;
@synthesize channelId = _channelId;
@synthesize channelName = _channelName;

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.size = CGSizeZero;
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
    return self.size;
}

-(CGFloat)leftSpace {
    return 0;
}

-(NSString *)reuseIdentifier
{
    return @"ScrollerBannerCCellID";
}

+(NSString *)reuseIdentifier
{
    return @"ScrollerBannerCCellID";
}

@end
