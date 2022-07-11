//
//  OSSVSortsBarView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSortsBarView.h"

@implementation OSSVSortsBarView

#pragma mark - public methods

- (void)cancelSelectState {
    [self.sortItem showMark:false];
    //延迟0.5秒可点
    self.sortItem.userInteractionEnabled = false;
    [self performSelector:@selector(itemUserEnable) withObject:nil afterDelay:0.5];
}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self addSubview:self.sortItem];
        [self addSubview:self.filterItem];
        [self addSubview:self.verLineView];
        [self addSubview:self.bottomLineView];
        
        //暂时只有一个，
        [self.sortItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self);
            make.top.bottom.mas_equalTo(self);
            make.trailing.mas_equalTo(self.filterItem.mas_leading);
            make.width.mas_equalTo(self.filterItem.mas_width);
        }];
        
        [self.filterItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self);
            make.top.bottom.mas_equalTo(self);
        }];
        
        [self.verLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(1, 20));
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom);
            make.height.mas_equalTo(0.5);
            make.leading.trailing.mas_equalTo(self);
        }];
    }
    return self;
}

#pragma mark - user action

- (void)sortTouch:(OSSVSortItemsView *)itemView {
    
    [itemView showMark:true];
    if (self.sortItemBlock) {
        self.sortItemBlock(2,itemView.selectState);
    }

    itemView.userInteractionEnabled = false;
    NSString *pageName = [UIViewController currentTopViewControllerPageName];
    [OSSVAnalyticsTool analyticsGAEventWithName:@"product_filter" parameters:@{
        @"screen_group" : [NSString stringWithFormat:@"ProductList_%@",STLToString(pageName)],
        @"filter" : @"SORT"
    }];
    [self performSelector:@selector(itemUserEnable) withObject:nil afterDelay:0.5];
}

- (void)filterTouch:(OSSVSortItemsView *)itemView {
    if (self.filterItemBlock) {
        [self.sortItem showMark:false];
        self.filterItemBlock();
        NSString *pageName = [UIViewController currentTopViewControllerPageName];
        [OSSVAnalyticsTool analyticsGAEventWithName:@"product_filter" parameters:@{
            @"screen_group" : [NSString stringWithFormat:@"ProductList_%@",STLToString(pageName)],
            @"filter" : @"FILTER"
        }];

    }
}

#pragma mark - private methods

- (void)itemUserEnable {
    self.sortItem.userInteractionEnabled = true;
}


#pragma mark - setters and getters

- (OSSVSortItemsView *)sortItem {
    if (!_sortItem) {
        _sortItem = [[OSSVSortItemsView alloc] initWithFrame:CGRectZero];
        [_sortItem addTarget:self action:@selector(sortTouch:) forControlEvents:UIControlEventTouchUpInside];
        _sortItem.titleLabel.text = [STLLocalizedString_(@"Sort", nil) uppercaseString];
    }
    return _sortItem;
}

- (UIButton *)filterItem {
    if (!_filterItem) {
        _filterItem = [[UIButton alloc] initWithFrame:CGRectZero];
        _filterItem.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [_filterItem addTarget:self action:@selector(filterTouch:) forControlEvents:UIControlEventTouchUpInside];
        [_filterItem setTitle:[STLLocalizedString_(@"category_filter", nil) uppercaseString] forState:UIControlStateNormal];
        [_filterItem setTitleColor:[OSSVThemesColors col_0D0D0D] forState:UIControlStateNormal];
        [_filterItem setTitleColor:[OSSVThemesColors col_0D0D0D] forState:UIControlStateHighlighted];
        [_filterItem setTitleColor:[OSSVThemesColors col_0D0D0D] forState:UIControlStateSelected];
        [_filterItem setImage:[UIImage imageNamed:@"category_filter"] forState:UIControlStateNormal];
        [_filterItem setImage:[UIImage imageNamed:@"category_filter"] forState:UIControlStateHighlighted];
        [_filterItem setImage:[UIImage imageNamed:@"category_filter"] forState:UIControlStateSelected];
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_filterItem setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 3.0, 0.0, -20.0)];
            [_filterItem setImageEdgeInsets:UIEdgeInsetsMake(0.0, -75.0, 0.0, 33.0)];
        } else {
            [_filterItem setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -50.0, 0.0, 10.0)];
            [_filterItem setImageEdgeInsets:UIEdgeInsetsMake(0.0, 75.0, 0.0, 0.0)];
        }
    }
    return _filterItem;
}


- (UIView *)verLineView {
    if (!_verLineView) {
        _verLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _verLineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _verLineView;
}


- (UIView *)bottomLineView  {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _bottomLineView;
}
@end



