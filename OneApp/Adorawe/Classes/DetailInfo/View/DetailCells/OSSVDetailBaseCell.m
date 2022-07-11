//
//  STLGoodsDetailBaseCell.m
// XStarlinkProject
//
//  Created by odd on 2020/10/28.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVDetailBaseCell.h"

@implementation OSSVDetailBaseCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.bgView];

        if (APP_TYPE == 3) {
            [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(self.contentView);
                make.leading.mas_equalTo(self.contentView.mas_leading);
                make.trailing.mas_equalTo(self.contentView.mas_trailing);
            }];
        } else {
            
            [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(self.contentView);
                make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
                make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
            }];
        }
    }
    return self;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        if (APP_TYPE == 3) {
            
        } else {        
            _bgView.layer.cornerRadius = 6;
            _bgView.layer.masksToBounds = YES;
        }
    }
    return _bgView;
}

-(UILabel *)isNewLbl{
    if (!_isNewLbl) {
        _isNewLbl = [UILabel new];
        if (APP_TYPE == 3) {
            _isNewLbl.font = [UIFont systemFontOfSize:10];
            _isNewLbl.backgroundColor = OSSVThemesColors.stlWhiteColor;
            _isNewLbl.textColor = OSSVThemesColors.col_26652C;
        } else {
            _isNewLbl.font = [UIFont boldSystemFontOfSize:12];
            _isNewLbl.backgroundColor = OSSVThemesColors.col_60CD8E;
            _isNewLbl.textColor = UIColor.whiteColor;
        }
        _isNewLbl.text = STLLocalizedString_(@"new_goods_mark", nil).uppercaseString;
        _isNewLbl.textAlignment = NSTextAlignmentCenter;
        _isNewLbl.hidden = YES;
    }
    return _isNewLbl;
}

@end
