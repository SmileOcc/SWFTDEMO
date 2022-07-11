//
//  OSSVThemeZeroActivyTwoCCellModel.m
// OSSVThemeZeroActivyTwoCCellModel
//
//  Created by Starlinke on 2021/7/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVThemeZeroActivyTwoCCellModel.h"
#import "OSSVZeroActivyDoulesLineCCell.h"

@implementation OSSVThemeZeroActivyTwoCCellModel


@synthesize dataSource = _dataSource;
@synthesize bg_color = _bg_color;
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

-(void)setDataSource:(NSArray <OSSVThemeZeroPrGoodsModel*> *)dataSource {
    _dataSource = dataSource;
}

- (void)setBg_color:(NSString *)bg_color {
    _bg_color = bg_color;
}

- (void)setChannelId:(NSString *)channelId {
    _channelId = channelId;
}
- (void)setChannelName:(NSString *)channelName {
    _channelName = channelName;
}
-(CGSize)customerSize {
//    return self.size;
    if ([self.dataSource isKindOfClass:[NSArray class]]) {
        NSArray *datas = (NSArray *)self.dataSource;
        return [OSSVZeroActivyDoulesLineCCell itemSize:datas.count];
    }
    return [OSSVZeroActivyDoulesLineCCell itemSize:0];
}

-(NSString *)reuseIdentifier {
    return @"STLZeroActivityDouleLinesCCellIdentifier";
}

+(NSString *)reuseIdentifier
{
    return @"STLZeroActivityDouleLinesCCellIdentifier";
}
@end
