//
//  YXOptionalBannerView.m
//  uSmartOversea
//
//  Created by youxin on 2019/5/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXOptionalBannerView.h"
#import "YXCycleScrollView.h"
#import <SDCycleScrollView/TAPageControl.h>
#import <Masonry/Masonry.h>

@interface YXOptionalBannerView ()<YXCycleScrollViewDelegate>
@property (nonatomic, strong) TAPageControl *pageControl;
@property (nonatomic, strong) UIButton *closeBtn;
//@property (nonatomic, strong) NSArray *imageURLStrings;
@property (nonatomic, strong) YXCycleScrollView *banner;
@end

@implementation YXOptionalBannerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame imageURLStringsGroup:(NSArray *)imageURLStrings{
    if (self = [super init]) {
        self.backgroundColor = QMUITheme.foregroundColor;
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = QMUITheme.separatorLineColor;
        
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.mas_equalTo(1);
        }];
        
        [self updateWithImageURLs:imageURLStrings];
        
        [self addSubview:self.closeBtn];
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-6);
            make.top.equalTo(lineView.mas_bottom).offset(6);
        }];
    }

    return self;
}

- (void)updateWithImageURLs:(NSArray *)imageURLStrings {
    [_banner removeFromSuperview];
    [self.pageControl removeFromSuperview];
    _banner = nil;
    self.pageControl = nil;
    
    _banner = [YXCycleScrollView cycleScrollViewWithFrame:CGRectZero imageURLStringsGroup:imageURLStrings];
    _banner.delegate = self;
    _banner.showPageControl = NO;
    _banner.placeholderImage = [UIImage imageNamed:@"black_33_5"];
    
//    [self addSubview:_banner];
    
    [self insertSubview:_banner belowSubview:self.closeBtn];
    
    [_banner mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(SCREEN_WIDTH*57.0/375);
        make.left.right.top.bottom.equalTo(self);
    }];
    
    if (imageURLStrings.count > 1) {
        [self addSubview:self.pageControl];
        _pageControl.numberOfPages = imageURLStrings.count;
        [self.pageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-6);
            make.centerX.equalTo(self);
        }];
    }
}

- (UIButton *)closeBtn {
    if (_closeBtn == nil) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"banner_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (TAPageControl *)pageControl {
    if (_pageControl == nil) {
        _pageControl = [[TAPageControl alloc] init];
        _pageControl.backgroundColor = [UIColor redColor];
        
        _pageControl.userInteractionEnabled = NO;
        _pageControl.currentPage = 0;
        _pageControl.spacingBetweenDots = 6;
        CGSize dotSize = CGSizeMake(8, 2);
        _pageControl.currentDotImage = [UIImage qmui_imageWithColor:[QMUITheme textColorLevel1] size:dotSize cornerRadius:0];
        _pageControl.dotImage = [UIImage qmui_imageWithColor:[UIColor colorWithWhite:1 alpha:0.3] size:dotSize cornerRadius:0];
    }
    return _pageControl;
}

- (void)close {
    if (_closeBlcok) {
        _closeBlcok();
    }
}

- (void)adjust {
    [_banner adjustWhenControllerViewWillAppera];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self performSelector:@selector(adjust) withObject:nil afterDelay:0.5];
}
#pragma YXCycleScrollViewDelegate method
/** 点击图片回调 */
- (void)cycleScrollView:(YXCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    if (_clickBannerBlock) {
        _clickBannerBlock(index);
    }
}

- (void)cycleScrollView:(YXCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index {
    self.pageControl.currentPage = index;
}

@end
