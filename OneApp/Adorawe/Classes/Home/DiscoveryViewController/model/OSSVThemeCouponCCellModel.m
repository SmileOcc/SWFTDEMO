//
//  OSSVThemeCouponCCellModel.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVThemeCouponCCellModel.h"

@implementation OSSVThemeCouponCCellModel
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
    return @"STLThemeCouponsCellModelID";
}

+(NSString *)reuseIdentifier
{
    return @"STLThemeCouponsCellModelID";
}
@end
