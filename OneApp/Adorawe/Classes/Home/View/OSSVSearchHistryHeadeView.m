//
//  SearchHistoryHeaderView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/19.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSearchHistryHeadeView.h"

@implementation OSSVSearchHistryHeadeView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
       
        [self addSubview:self.searchLab];
        [self addSubview:self.line];
        [self addSubview:self.deleteBtn];
        
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.offset(DSYSTEM_VERSION >= 11 ? 16 : 10);
            make.trailing.offset(0);
            make.bottom.offset(-MIN_PIXEL * 2);
            make.height.equalTo(0.5);
        }];
        
        [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@24);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
            make.centerY.mas_equalTo(self.searchLab.mas_centerY);
        }];
        
        [self.searchLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.offset(DSYSTEM_VERSION >= 11 ? 16 : 10);
            make.centerY.offset(0);
            make.trailing.mas_equalTo(self.deleteBtn.mas_leading).offset(-10);
            make.height.equalTo(self);
        }];
        
        self.line.hidden = YES;
        
    }
    return self;
}

- (void)delegateBtnClick {
    
    @weakify(self)
        
    // 添加行间距
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc]init];
    paragraph.lineSpacing = 5.0;

    // 字体: 大小 颜色 行间距
    NSAttributedString *attributedStr = [[NSAttributedString alloc]initWithString:STLLocalizedString_(@"Are_want_remove_history", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[OSSVThemesColors col_999999],NSParagraphStyleAttributeName:paragraph}];
    
    NSArray *upperTitle = @[STLLocalizedString_(@"yes", nil).uppercaseString, STLLocalizedString_(@"no",nil).uppercaseString];
    NSArray *lowserTitle = @[STLLocalizedString_(@"yes", nil),STLLocalizedString_(@"no",nil)];

    [STLAlertSelectMessageView showMessage:attributedStr btnTitles:APP_TYPE == 3 ? lowserTitle : upperTitle alertCallBlock:^(NSInteger buttonIndex, NSString * _Nonnull title) {
        if (buttonIndex == 0) {
            @strongify(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(deleteSearchHistory)]) {
                [self.delegate deleteSearchHistory];
            }
        }
    }];
}

#pragma mark - LazyLoad

- (UILabel *)searchLab {
    if (!_searchLab) {
        _searchLab = [[UILabel alloc] init];
        _searchLab.font = [UIFont boldSystemFontOfSize:14];
        _searchLab.textColor = [OSSVThemesColors col_262626];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _searchLab.textAlignment = NSTextAlignmentRight;
        } else {
            _searchLab.textAlignment = NSTextAlignmentLeft;
        }
        _searchLab.text = STLLocalizedString_(@"searchHistory", nil);
    }
    return _searchLab;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = OSSVThemesColors.col_F1F1F1;
    }
    return _line;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (APP_TYPE == 3) {
            [_deleteBtn setImage:[UIImage imageNamed:@"delete_new"] forState:UIControlStateNormal];
        }else{
            [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_new"] forState:UIControlStateNormal];
        }
        [_deleteBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(delegateBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

@end
