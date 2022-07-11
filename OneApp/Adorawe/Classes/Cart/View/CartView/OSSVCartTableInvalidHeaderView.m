//
//  OSSVCartTableInvalidHeaderView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartTableInvalidHeaderView.h"
@interface OSSVCartTableInvalidHeaderView ()
@property (nonatomic, strong) UILabel          *titleLabel;
@property (nonatomic, strong) UIButton         *clearBtn;
@property (nonatomic, strong) UIView           *lineView;
//虚线
@property (nonatomic, strong) UIImageView      *lineImageView;

@end

@implementation OSSVCartTableInvalidHeaderView

+ (OSSVCartTableInvalidHeaderView *)cartHeaderViewWithTableView:(UITableView *)tableView {
    [tableView registerClass:[OSSVCartTableInvalidHeaderView class] forHeaderFooterViewReuseIdentifier:@"OSSVCartTableInvalidHeaderView"];
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"OSSVCartTableInvalidHeaderView"];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.clearBtn];
        [self addSubview:self.lineView];
        [self addSubview:self.lineImageView];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).mas_offset(12);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(30);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.height.mas_equalTo(@(0.5));
        }];
        
        if (APP_TYPE == 3) {
            [self.lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.leading.mas_equalTo(self.clearBtn);
                make.top.mas_equalTo(self.clearBtn.mas_bottom).offset(-5);
                make.height.mas_equalTo(1);
            }];
        }

    }
    return self;
}


#pragma mark -

- (void)actionClear:(UIButton *)sender {
    if (self.operateBlock) {
        self.operateBlock();
    }
}


#pragma mark - LazyLoad

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        if (APP_TYPE == 3) {
            _titleLabel.font = [UIFont vivaiaRegularFont:16];

        } else {
            _titleLabel.font = [UIFont boldSystemFontOfSize:13];
        }
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.text = STLLocalizedString_(@"Invalid_items", nil);
    }
    return _titleLabel;
}

- (UIButton *)clearBtn {
    if (!_clearBtn) {
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearBtn setTitle:STLLocalizedString_(@"ClearAll", nil) forState:UIControlStateNormal];
        _clearBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_clearBtn setTitleColor:[OSSVThemesColors col_0D0D0D] forState:UIControlStateNormal];
        [_clearBtn addTarget:self action:@selector(actionClear:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearBtn;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
        _lineView.hidden = APP_TYPE == 3 ? YES : NO;
    }
    return _lineView;
}

- (UIImageView *)lineImageView {
    if (!_lineImageView) {
        _lineImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        UIImage *backImg = STLImageWithName(@"spic_dash_line_black");
        UIColor*bcColor =[UIColor colorWithPatternImage:backImg];
        _lineImageView.hidden = APP_TYPE == 3 ? NO : YES;
        _lineImageView.backgroundColor = bcColor;
    }
    return _lineImageView;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (APP_TYPE == 3) {
        [self.contentView stlAddCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(0, 0)];
    } else {
        [self.contentView stlAddCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
    }
}
@end
