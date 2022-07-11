//
//  OSSVThemesZeroActivyCellModel.m
// OSSVThemesZeroActivyCellModel
//
//  Created by odd on 2020/9/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVThemesZeroActivyCellModel.h"
#import "OSSVThemeZeorsActivyCCell.h"

@implementation OSSVThemesZeroActivyCellModel
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
        return [OSSVThemeZeorsActivyCCell itemSize:datas.count];
    }
    return [OSSVThemeZeorsActivyCCell itemSize:0];
}

-(NSString *)reuseIdentifier {
    return @"ThemeZeroActivityCellIdentifier";
}

+(NSString *)reuseIdentifier
{
    return @"ThemeZeroActivityCellIdentifier";
}
@end
