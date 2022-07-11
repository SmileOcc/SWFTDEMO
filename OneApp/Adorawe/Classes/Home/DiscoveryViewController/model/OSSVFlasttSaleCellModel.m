//
//  OSSVFlasttSaleCellModel.m
// XStarlinkProject
//
//  Created by Kevin--Xue on 2020/11/1.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVFlasttSaleCellModel.h"

@implementation OSSVFlasttSaleCellModel
@synthesize dataSource = _dataSource;
@synthesize channelId  = _channelId;
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
    return @"FastSaleCCellID";
}

+(NSString *)reuseIdentifier
{
    return @"FastSaleCCellID";
}

@end
