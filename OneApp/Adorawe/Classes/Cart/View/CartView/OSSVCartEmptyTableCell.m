//
//  OSSVCartEmptyTableCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartEmptyTableCell.h"

@implementation OSSVCartEmptyTableCell

+ (OSSVCartEmptyTableCell *)cellCartEmptyTableWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    //注册cell
    [tableView registerClass:[OSSVCartEmptyTableCell class] forCellReuseIdentifier:@"OSSVCartEmptyTableCell"];
    return [tableView dequeueReusableCellWithIdentifier:@"OSSVCartEmptyTableCell" forIndexPath:indexPath];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = OSSVThemesColors.col_F7F7F7;//[UIColor whiteColor];
        
        [self.contentView addSubview:self.imgView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.button];
        
        // 310 212
        CGFloat imgW = SCREEN_HEIGHT > 667.0f ? 120 : 100;
        CGFloat space = SCREEN_HEIGHT > 667.0f ? 30 : 20;
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.top.mas_equalTo(self.contentView.mas_top).offset(kIS_IPHONEX ? 44 : 20);
            make.size.mas_equalTo(CGSizeMake(imgW, imgW * 212 / 310.0));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.top.mas_equalTo(self.imgView.mas_bottom).offset(space);
        }];
        
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.height.mas_equalTo(@40);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(space);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(kIS_IPHONEX ? -44 : -20);
        }];
    }
    
    return self;
}

#pragma mark - LazyLoad

- (YYAnimatedImageView *)imgView {
    if (!_imgView) {
        _imgView = [YYAnimatedImageView new];
        _imgView.image = [UIImage imageNamed:@"cart_bank"];
    }
    return _imgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = OSSVThemesColors.col_333333;
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.text = STLLocalizedString_(@"cart_blank", nil);
    }
    return _titleLabel;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button addTarget:self action:@selector(emptyJumpOperationTouch) forControlEvents:UIControlEventTouchUpInside];
        _button.backgroundColor = OSSVThemesColors.col_FF9522;
        _button.titleLabel.font = [UIFont systemFontOfSize:14];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button setTitle:STLLocalizedString_(@"cart_blank_button_title", nil) forState:UIControlStateNormal];
        _button.layer.cornerRadius = 3;
        [_button setContentEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    return _button;
}

- (void)emptyJumpOperationTouch {
    if (self.noDataBlock) {
        self.noDataBlock();
    }
}
@end
