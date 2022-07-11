//
//  OSSVAPPNewThemeMultiCCellModel.m
// OSSVAPPNewThemeMultiCCellModel
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAPPNewThemeMultiCCellModel.h"

@interface OSSVAPPNewThemeMultiCCellModel ()

@property (nonatomic, assign) CGSize size;

@end

@implementation OSSVAPPNewThemeMultiCCellModel
@synthesize dataSource = _dataSource;
@synthesize channelId = _channelId;
@synthesize channelName = _channelName;

-(void)setDataSource:(NSObject *)dataSource
{
    _dataSource = dataSource;
    
    if ([_dataSource isKindOfClass:[STLAdvEventSpecialModel class]]) {
        STLAdvEventSpecialModel *model = (STLAdvEventSpecialModel *)_dataSource;
        self.size = CGSizeMake(model.imagesWidth.floatValue, model.imagesHeight.floatValue);
    }
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

-(NSString *)reuseIdentifier
{
    return @"MultipleCellID";
}

+(NSString *)reuseIdentifier
{
    return @"MultipleCellID";
}

@end
