//
//  OSSVCheckOutCodMsgAlertView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/22.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCheckOutCodMsgAlertView.h"
#import "UIButton+STLCategory.h"

@implementation OSSVCheckOutCodMsgAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        self.detailHeight = [CodDetailView fetchDetailTitleHeight];

        self.datasArray = @[@{@"idx":@"1",@"value":STLLocalizedString_(@"Information_entered_incorrectly", nil)},
                            @{@"idx":@"2",@"value":STLLocalizedString_(@"Estimated_delivery_time_is_long", nil)},
                            @{@"idx":@"3",@"value":STLLocalizedString_(@"Shipping_fee_is_expensive", nil)},
                            @{@"idx":@"4",@"value":STLLocalizedString_(@"Did_not_receive_the_verification_code", nil)},
                            @{@"idx":@"5",@"value":STLLocalizedString_(@"Changed_their_mind_no_longer_want_it", nil)},
                            @{@"idx":@"6",@"value":STLLocalizedString_(@"Other_reason", nil)}];

        [self addSubview:self.contentView];
        [self.contentView addSubview:self.headerView];
//        [self.contentView addSubview:self.subTitleView];
        [self.contentView addSubview:self.tableView];
        [self.contentView addSubview:self.confirmButton];
        
        
        [self.headerView addSubview:self.titleLabel];
        [self.headerView addSubview:self.closeButton];
        [self.headerView addSubview:self.lineView];
        
//        [self.subTitleView addSubview:self.subTitleLabel];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
        
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.contentView.mas_top);
            make.height.mas_equalTo(49);
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.headerView.mas_centerY);
            make.trailing.mas_equalTo(self.headerView.mas_trailing).mas_offset(-12);
            make.width.height.mas_equalTo(18);
        }];
        
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.headerView.mas_centerY);
            make.leading.mas_equalTo(self.headerView.mas_leading).mas_offset(40);
            make.trailing.mas_equalTo(self.headerView.mas_trailing).mas_offset(-40);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_equalTo(self.headerView);
            make.height.mas_equalTo(0.5);
        }];
        
//        [self.subTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.trailing.mas_equalTo(self.contentView);
//            make.top.mas_equalTo(self.headerView.mas_bottom);
//        }];
//
//        [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.mas_equalTo(self.subTitleView.mas_leading).mas_offset(12);
//            make.trailing.mas_equalTo(self.subTitleView.mas_trailing).mas_offset(-12);
//            make.top.mas_equalTo(self.subTitleView.mas_top).mas_offset(12);
//            make.bottom.mas_equalTo(self.subTitleView.mas_bottom).mas_offset(-12);
//        }];


        [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
            make.height.mas_equalTo(44);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(kIS_IPHONEX ? -34 : -12);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.headerView.mas_bottom);
            make.bottom.mas_equalTo(self.confirmButton.mas_top).offset(-12);
            make.height.mas_equalTo(49 * self.datasArray.count + self.detailHeight);
        }];
    }
    return self;
}

- (void)setOrder_flow_switch:(NSString *)order_flow_switch {
    _order_flow_switch = order_flow_switch;
    if ([STLToString(_order_flow_switch) integerValue]) {
        self.datasArray = @[@{@"idx":@"1",@"value":STLLocalizedString_(@"Information_entered_incorrectly", nil)},
                            @{@"idx":@"2",@"value":STLLocalizedString_(@"Estimated_delivery_time_is_long", nil)},
                            @{@"idx":@"3",@"value":STLLocalizedString_(@"Shipping_fee_is_expensive", nil)},
                            //@{@"idx":@"4",@"value":STLLocalizedString_(@"Did_not_receive_the_verification_code", nil)},
                            @{@"idx":@"5",@"value":STLLocalizedString_(@"Changed_their_mind_no_longer_want_it", nil)},
                            @{@"idx":@"6",@"value":STLLocalizedString_(@"Other_reason", nil)}];
    } else {
        self.datasArray = @[@{@"idx":@"1",@"value":STLLocalizedString_(@"Information_entered_incorrectly", nil)},
                            @{@"idx":@"2",@"value":STLLocalizedString_(@"Estimated_delivery_time_is_long", nil)},
                            @{@"idx":@"3",@"value":STLLocalizedString_(@"Shipping_fee_is_expensive", nil)},
                            @{@"idx":@"4",@"value":STLLocalizedString_(@"Did_not_receive_the_verification_code", nil)},
                            @{@"idx":@"5",@"value":STLLocalizedString_(@"Changed_their_mind_no_longer_want_it", nil)},
                            @{@"idx":@"6",@"value":STLLocalizedString_(@"Other_reason", nil)}];
    }
    [self.tableView reloadData];
}



- (void)show{
    

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    for (UIView *windowSubView in window.subviews) {
        if ([windowSubView isKindOfClass:[OSSVCheckOutCodMsgAlertView class]]) {
            [windowSubView removeFromSuperview];
            break;
        }
    }
    
    if (!self.superview) {
        [WINDOW addSubview:self];
    }
    self.hidden = NO;
    self.alpha = 0.0;
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    CGFloat h = CGRectGetHeight(self.contentView.frame);
    
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(h);
    }];
    
    [UIView animateWithDuration:0.15f animations:^{
        self.alpha = 1.0;
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(0);
        }];
    }];
}

- (void)dismiss {
    
    [UIView animateWithDuration:0.1f animations:^{
        self.alpha = 0.0;
        CGFloat h = CGRectGetHeight(self.contentView.frame);
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(h);
        }];
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
        if (self.superview) {
            [self removeFromSuperview];
        }
    }];
}

- (void)dismissAction {
    if (self.closeBlock) {
        self.closeBlock();
    }
    [self dismiss];
}

- (void)confirm {
    

    if (!self.selectIndexPath) {
        return;
    }
    if (self.codAlertBlock) {
        if (self.datasArray.count > self.selectIndexPath.row) {
            NSDictionary *dic = self.datasArray[self.selectIndexPath.row];
            self.codAlertBlock(dic[@"idx"],dic[@"value"]);
        }
    }
    [self dismiss];
}

#pragma mark -

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _contentView.layer.cornerRadius = 5;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectZero];
        _headerView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _headerView;
}

//- (UIView *)subTitleView {
//    if (!_subTitleView) {
//        _subTitleView = [[UIView alloc] initWithFrame:CGRectZero];
//        _subTitleView.backgroundColor = [OSSVThemesColors stlWhiteColor];
//    }
//    return _subTitleView;
//}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = STLLocalizedString_(@"Sorry", nil);
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
    }
    return _titleLabel;
}

//- (UILabel *)subTitleLabel {
//    if (!_subTitleLabel) {
//        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//
//        _subTitleLabel.textAlignment = NSTextAlignmentLeft;
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            _subTitleLabel.textAlignment = NSTextAlignmentRight;
//        }
//        _subTitleLabel.text = STLLocalizedString_(@"COD_Please_help_improve_service_why.", nil);
//        _subTitleLabel.textColor = [OSSVThemesColors col_6C6C6C];
//        _subTitleLabel.font = [UIFont systemFontOfSize:14];
//        _subTitleLabel.numberOfLines = 0;
//    }
//    return _subTitleLabel;
//}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
        CodDetailView *detailTitleView = [[CodDetailView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.detailHeight)];
        _tableView.tableHeaderView = detailTitleView;
    }
    return _tableView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:[UIImage imageNamed:@"close_18"] forState:UIControlStateNormal];
        [_closeButton setEnlargeEdge:8];
    }
    return _closeButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView;
}


- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton setTitle:[STLLocalizedString_(@"submit",nil) uppercaseString]  forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        [_confirmButton setBackgroundColor:[OSSVThemesColors col_CCCCCC]];
        _confirmButton.enabled = NO;
    }
    return _confirmButton;
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CodMsgAlertCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CodMsgAlertCell"];
        cell.backgroundColor = [OSSVThemesColors stlWhiteColor];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *titLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titLabel.textColor = [OSSVThemesColors col_0D0D0D];
        titLabel.numberOfLines = 2;
        titLabel.font = [UIFont systemFontOfSize:14];
        titLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            titLabel.textAlignment = NSTextAlignmentRight;
        }
        titLabel.tag = 6000;
        [cell addSubview:titLabel];
        
        UIImageView *selectImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        selectImageView.image = [UIImage imageNamed:@"check_box18"];
        selectImageView.tag = 6001;
        //PayMentUnSelected
        [cell addSubview:selectImageView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
        lineView.tag = 6002;
        [cell addSubview:lineView];
        
        [selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(cell.mas_centerY);
            make.trailing.mas_equalTo(cell.mas_trailing).mas_offset(-12);
            make.size.mas_equalTo(CGSizeMake(18, 18));
        }];
        
        [titLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(cell.mas_leading).mas_offset(12);
            make.trailing.mas_equalTo(selectImageView.mas_leading).mas_offset(-10);
            make.top.bottom.mas_equalTo(cell);
        }];
        
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(cell.mas_leading).mas_offset(12);
            make.trailing.mas_equalTo(cell.mas_trailing).mas_offset(-12);
            make.bottom.mas_equalTo(cell.mas_bottom);
            make.height.mas_equalTo(0.5);
        }];
    }
    if (self.datasArray.count > indexPath.row) {
        UILabel *descLab = [cell viewWithTag:6000];
        NSDictionary *dic = self.datasArray[indexPath.row];
        descLab.text = dic[@"value"];
        
        UIImageView *imgView = [cell viewWithTag:6001];
        imgView.image = [UIImage imageNamed:@"check_box18"];
        if (self.selectIndexPath && self.selectIndexPath.row == indexPath.row) {
            imgView.image = [UIImage imageNamed:@"checked_box18"];
        }
        
        UIView *lineView = [cell viewWithTag:6002];
        if (indexPath.row == self.datasArray.count - 1) {
            lineView.hidden = YES;
        } else {
            lineView.hidden = NO;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectIndexPath = indexPath;
    self.confirmButton.enabled = YES;
    [self.confirmButton setBackgroundColor:[OSSVThemesColors col_262626]];
    [self.tableView reloadData];

}
@end

@implementation CodDetailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bgScroView];
        [self.bgScroView addSubview:self.subTitleLabel];
        
        [self.bgScroView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing);
            make.top.bottom.mas_equalTo(self);
        }];
        
        [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH - 24);
            make.leading.mas_equalTo(self.bgScroView.mas_leading).offset(12);
            make.top.mas_equalTo(self.bgScroView.mas_top).mas_offset(12);
            make.bottom.mas_equalTo(self.bgScroView.mas_bottom).mas_offset(-12);
            
        }];
    }
    return self;
}

+ (CGFloat)fetchDetailTitleHeight;
{
    CodDetailView *tempView = [[CodDetailView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [tempView layoutIfNeeded];
    CGFloat calculateHeight = tempView.bgScroView.contentSize.height;
    
    if (calculateHeight <=0) {
        return 0;
    }
    return calculateHeight;
}

- (UIScrollView *)bgScroView {
    if (!_bgScroView) {
        _bgScroView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _bgScroView.scrollEnabled = NO;
    }
    return _bgScroView;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        _subTitleLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _subTitleLabel.textAlignment = NSTextAlignmentRight;
        }
        _subTitleLabel.text = STLLocalizedString_(@"COD_Please_help_improve_service_why.", nil);
        _subTitleLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _subTitleLabel.font = [UIFont systemFontOfSize:14];
        _subTitleLabel.numberOfLines = 0;
    }
    return _subTitleLabel;
}
@end
