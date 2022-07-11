//
//  OSSVDetailActivityCell.m
// XStarlinkProject
//
//  Created by odd on 2021/6/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailActivityCell.h"

@implementation OSSVDetailActivityCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:self.activityView];

        [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).mas_offset(0);
            make.leading.mas_equalTo(self.bgView.mas_leading);
            make.trailing.mas_equalTo(self.bgView.mas_trailing);
            make.height.mas_offset(48);
        }];
        
    }
    return self;
}

- (void)updateHeaderGoodsSelect:(OSSVDetailsBaseInfoModel *)goodsInforModel {
    
    self.infoModel = goodsInforModel;
    //满减活动
    //////闪购标
    BOOL hasActivity = NO;
    if (!STLIsEmptyString(goodsInforModel.specialId) || (goodsInforModel.flash_sale && [goodsInforModel.flash_sale isFlashActiving])) {
        [self.activityView setHtmlTitle:nil specialUrl:@"" contentWidth:0];
    } else {
        
        if ([goodsInforModel.bundleActivity isKindOfClass:[NSArray class]]) {
            hasActivity = goodsInforModel.bundleActivity.count > 0 ? YES : NO;
            [self.activityView setHtmlTitle:goodsInforModel.bundleActivity specialUrl:@"" contentWidth:goodsInforModel.maxBundleActivityWidth];
        }
    }
    
    //防止出现活动后，选择其他后不是活动
    self.activityView.hidden = !hasActivity;
}


- (OSSVDetaillHtmlArrView *)activityView {
    if (!_activityView) {
        _activityView = [[OSSVDetaillHtmlArrView alloc] init];

        @weakify(self)
        _activityView.activityBlock = ^(NSInteger index) {
            @strongify(self)
            if (self.stlDelegate && [self.stlDelegate respondsToSelector:@selector(OSSVDetialCell:activityBuyFree:)]) {
                OSSVBundleActivityModel *activityModel;
                if (self.infoModel.bundleActivity.count > index) {
                    activityModel = self.infoModel.bundleActivity[index];
                }
                [self.stlDelegate OSSVDetialCell:self activityBuyFree:activityModel];
            }
        };

    }
    return _activityView;
}
@end
