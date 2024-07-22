//
//  ZFAddressCountryCityStateView.m
//  ZZZZZ
//
//  Created by YW on 2019/1/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressCountryCityStateView.h"
#import <Masonry/Masonry.h>
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "SystemConfigUtils.h"
#import "Constants.h"
#import "UIView+ZFViewCategorySet.h"

@interface ZFAddressCountryCityStateView()

@property (nonatomic, strong) UIScrollView     *contentScrollView;

@end

@implementation ZFAddressCountryCityStateView


#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ZFC0xFFFFFF();
        [self addSubview:self.contentScrollView];
        
        [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}


#pragma mark - Private Method

- (void)clickItemView:(ZFAddressCountryCityStateItemView *)itemView {
    if (itemView == self.selectItemView) {
        return;
    }
    
    self.selectItemView.eventButton.selected = NO;
    self.selectItemView = itemView;
    self.selectItemView.eventButton.selected = YES;
    
    NSInteger index = self.selectItemView.tag - 1000;
    if (self.selectIndexBlock) {
        self.selectIndexBlock(index);
    }
    
    CGFloat width = CGRectGetWidth(self.selectItemView.frame);
    //滚动效果
    if (self.titlesArray.count == 4) {
        if (index == 1) {//滚动最前面
            if ([SystemConfigUtils isRightToLeftShow] && self.titlesArray.count == 4) {
                [self.contentScrollView setContentOffset:CGPointMake(1 * width, 0) animated:YES];
            } else {
                [self.contentScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
            
        } else if (index == 2) {//滚到最后
            CGFloat width = CGRectGetWidth(itemView.frame);
            if ([SystemConfigUtils isRightToLeftShow]) {
                [self.contentScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            } else {
                [self.contentScrollView setContentOffset:CGPointMake(1 * width, 0) animated:YES];
            }
        }
    }
    
}
- (void)selectIndex:(NSInteger)index {
    
    if (index >= self.contentScrollView.subviews.count) {
        return;
    }
    ZFAddressCountryCityStateItemView *sender = [self viewWithTag:1000+index];
    if (sender==self.selectItemView || sender==nil) {
        return;
    }
    self.selectItemView.eventButton.selected = NO;
    self.selectItemView = sender;
    self.selectItemView.eventButton.selected = YES;
    
    CGFloat width = CGRectGetWidth(self.selectItemView.frame);

    if (index == 0) {
        if ([SystemConfigUtils isRightToLeftShow] && self.titlesArray.count == 4) {
            [self.contentScrollView setContentOffset:CGPointMake(1 * width, 0) animated:YES];
        } else {
            [self.contentScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
    //滚动效果
    if (self.titlesArray.count == 4) {
        if (index == 1) {//滚动最前面
            if ([SystemConfigUtils isRightToLeftShow]) {
                [self.contentScrollView setContentOffset:CGPointMake(1 * width, 0) animated:YES];
            } else {
                [self.contentScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
        } else if (index == 2) {//滚到最后
            if ([SystemConfigUtils isRightToLeftShow]) {
                [self.contentScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            } else {
                [self.contentScrollView setContentOffset:CGPointMake(1 * width, 0) animated:YES];
            }
        }
    }
}


#pragma mark - Property Method

-(void)setTitlesArray:(NSArray *)titlesArray {
    _titlesArray = titlesArray;
    
    while (self.contentScrollView.subviews.count) {
        [self.contentScrollView.subviews.lastObject removeFromSuperview];
    }
    
    if (_titlesArray.count <= 0) {
        return;
    }
    CGFloat width = KScreenWidth / _titlesArray.count;
    
    if (_titlesArray.count > 3) {
        width = KScreenWidth / 3.0;
        self.contentScrollView.scrollEnabled = YES;
    } else {
        self.contentScrollView.scrollEnabled = NO;
    }
    self.contentScrollView.contentSize = CGSizeMake(width * _titlesArray.count, 0);
    
    if (_titlesArray.count > 3) {
        if ([SystemConfigUtils isRightToLeftShow]) {
            [self.contentScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        } else {
            [self.contentScrollView setContentOffset:CGPointMake(width * (_titlesArray.count - 3), 0) animated:YES];
        }
    }
    
    ZFAddressCountryCityStateItemView *tempView;
    for (int i =0; i<_titlesArray.count; i++) {
        
        ZFAddressCountryCityStateItemView *itemView = [[ZFAddressCountryCityStateItemView alloc] initWithFrame:CGRectZero];
        [itemView.eventButton setTitle:_titlesArray[i] forState:UIControlStateNormal];
        itemView.tag = 1000 + i;
        [self.contentScrollView addSubview:itemView];
        
        if (i == _titlesArray.count - 1) {
            itemView.eventButton.selected = YES;
            itemView.arrowImageView.hidden = YES;
            self.selectItemView = itemView;
        } else {
            itemView.arrowImageView.hidden = NO;
        }
        
        if (!tempView) {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.top.bottom.mas_equalTo(self.contentScrollView);
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(56);
            }];
        } else {
            if (i == _titlesArray.count - 1) {
                [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.mas_equalTo(tempView.mas_trailing);
                    make.width.mas_equalTo(width);
                    make.height.mas_equalTo(tempView);
                    make.centerY.mas_equalTo(tempView.mas_centerY);
                    make.trailing.mas_equalTo(self.contentScrollView.mas_trailing);
                }];
            } else {
                [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.mas_equalTo(tempView.mas_trailing);
                    make.width.mas_equalTo(width);
                    make.height.mas_equalTo(tempView);
                    make.centerY.mas_equalTo(tempView.mas_centerY);
                }];
            }
        }
        tempView = itemView;
        
        
        @weakify(self)
        itemView.clickBlock = ^(UIButton *sender) {
            @strongify(self)
            ZFAddressCountryCityStateItemView *currentItemView = (ZFAddressCountryCityStateItemView *)sender.superview;
            [self clickItemView:currentItemView];
        };
    }
}

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 56)];
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _contentScrollView;
}
@end


@implementation ZFAddressCountryCityStateItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.arrowImageView];
        [self addSubview:self.eventButton];
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.eventButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
    }
    return self;
}

- (void)actionClick:(UIButton *)sender {
    if (self.clickBlock) {
        self.clickBlock(sender);
    }
}

- (UIButton *)eventButton {
    if (!_eventButton) {
        _eventButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _eventButton.contentEdgeInsets = UIEdgeInsetsMake(2, 10, 2, 16);
        [_eventButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        [_eventButton setTitleColor:ZFC0xFE5269() forState:UIControlStateSelected];
        _eventButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _eventButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_eventButton addTarget:self action:@selector(actionClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _eventButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _eventButton.titleLabel.numberOfLines = 3;
    }
    return _eventButton;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.image = [UIImage imageNamed:@"account_arrow_right"];
        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
}
@end
