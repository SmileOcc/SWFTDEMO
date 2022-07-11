//
//  OSSVDetailRecommendHeaderCell.m
// XStarlinkProject
//
//  Created by odd on 2021/4/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailRecommendHeaderCell.h"
#import "WMMenuView.h"

@interface OSSVDetailRecommendHeaderCell ()
@property (nonatomic, strong) UIView *lineView;

@end

@implementation OSSVDetailRecommendHeaderCell

+ (CGFloat)heightGoodsRecommendView:(BOOL)hasData {
    return hasData ? 44 : 0;
}

#pragma mark
#pragma mark - Initialize subView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    
        self.backgroundColor = [UIColor clearColor];
        self.bgView.hidden = YES;
        [self setUpSubviews];
    }
    return self;
}

-(void)setUpSubviews{
    self.lineView = [UIView new];
    self.lineView.backgroundColor = OSSVThemesColors.col_E1E1E1;
    
    
    OSSVBuyAndBuyTabView *tab = [[OSSVBuyAndBuyTabView alloc] initWithFrame:CGRectZero];
    tab.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:tab];
    [tab mas_makeConstraints:^(MASConstraintMaker *make) {
        if (APP_TYPE == 3) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(0);
        } else {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(10);
        }
        make.trailing.leading.mas_equalTo(self.contentView);
    }];
    _tabView = tab;
    
    if (APP_TYPE == 3) {
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-1);
            make.height.equalTo(0.5);
        }];
    }
    
    @weakify(self)
    [[NSNotificationCenter defaultCenter] addObserverForName:STLBuyAndBuySwitchNotifiName object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self)
        OSSVBuyAndBuyTabView *srcTabView = note.object;
        if (srcTabView != self.tabView) {
            NSInteger index = [note.userInfo[@"index"] integerValue];
            self.tabView.currentIndex = index;
        }
    }];
}

@end
