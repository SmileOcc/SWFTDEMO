//
//  OSSVAsingleCCellModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAsingleCCellModel.h"

@interface OSSVAsingleCCellModel ()

@end

@implementation OSSVAsingleCCellModel
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
    return 16;
}

-(NSString *)reuseIdentifier
{
    return @"AsingleID";
}

+(NSString *)reuseIdentifier
{
    return @"AsingleID";
}

@end
