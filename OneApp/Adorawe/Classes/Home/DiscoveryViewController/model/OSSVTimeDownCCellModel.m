//
//  OSSVTimeDownCCellModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVTimeDownCCellModel.h"

@interface OSSVTimeDownCCellModel ()

@property (nonatomic, strong, readwrite) ZJJTimeCountDown *countDown;

@end

@implementation OSSVTimeDownCCellModel

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
    return CGSizeZero;
}
-(CGFloat)leftSpace {
    return 0;
}

-(NSString *)reuseIdentifier
{
    return @"CountDownCellID";
}

+(NSString *)reuseIdentifier
{
    return @"CountDownCellID";
}

#pragma mark - setter and getter

-(ZJJTimeCountDown *)countDown
{
    if (!_countDown) {
        _countDown = [[ZJJTimeCountDown alloc] init];
        _countDown.timeStyle = ZJJcountDownSecondStyle;
        _countDown.labelInContentView = NO;
    }
    return _countDown;
}

@end
