//
//  OSSVCategorysTableCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategorysTableCell.h"

@interface OSSVCategorysTableCell ()

@property (nonatomic, strong) UIView *vLineView;
@property (nonatomic, strong) UIView *titleBgView;
@end

@implementation OSSVCategorysTableCell

#pragma  mark - life cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [OSSVThemesColors stlClearColor];
        self.contentView.backgroundColor = [OSSVThemesColors col_F5F5F5];

        [self.contentView addSubview:self.titleBgView];
        [self.titleBgView addSubview:self.titleLabel];
        [self.contentView addSubview:self.vLineView];
        
        [self.vLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.top.mas_equalTo(self.contentView.mas_top).offset(12);
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);

            } else {
                make.top.mas_equalTo(self.contentView.mas_top);
                make.bottom.mas_equalTo(self.contentView.mas_bottom);
            }
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(0);
            make.width.equalTo(2);
        }];
        
        [self.titleBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.centerY.mas_equalTo(self.contentView.mas_centerY);
                make.height.mas_equalTo(58);

            } else {
                make.top.mas_equalTo(self.contentView.mas_top);
                make.height.mas_equalTo(48);
            }
            make.leading.mas_equalTo(self.vLineView.mas_trailing);
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
        }];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleBgView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.titleBgView.mas_trailing).offset(-12);
            make.top.bottom.mas_equalTo(self.titleBgView);
        }];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    
    if (APP_TYPE == 3) {
        
    } else {
        
        BOOL isAR = [OSSVSystemsConfigsUtils isRightToLeftShow];
        
        NSInteger sourceIndex = self.categoryModel.cornersIndex;
        //阿语左边上下两个角，英语右边上下两个角
        if (isAR) {
            if (sourceIndex == 2) {
                sourceIndex = 1;
            } else if(sourceIndex == 4) {
                sourceIndex = 3;
            }
        }
        
        if (sourceIndex == 2 || sourceIndex == 1) {
            [self.titleBgView stlAddCorners:isAR ? UIRectCornerTopLeft : UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)];
        } else if(sourceIndex == 4 || sourceIndex == 3) {
            [self.titleBgView stlAddCorners:isAR ? UIRectCornerBottomLeft :  UIRectCornerBottomRight cornerRadii:CGSizeMake(6, 6)];
        } else {
            [self.titleBgView stlAddCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(0, 0)];
            
        }
    }

}
- (UIView *)titleBgView {
    if (!_titleBgView) {
        _titleBgView = [UIView new];
        _titleBgView.backgroundColor = [UIColor whiteColor];

    }
    return _titleBgView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.numberOfLines = 2;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLabel.textAlignment = NSTextAlignmentRight;
        } else {
            _titleLabel.textAlignment = NSTextAlignmentLeft;
        }
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLabel;
}

- (UIView *)vLineView {
    if (!_vLineView) {
        _vLineView = [UIView new];
        _vLineView.backgroundColor = OSSVThemesColors.col_0D0D0D;
    }
    return _vLineView;
}

#pragma mark - LazyLoad setters and getters

- (void)setCategoryModel:(OSSVCategorysModel *)categoryModel {
    _categoryModel = categoryModel;
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@",STLToString(categoryModel.title).uppercaseString];
    
    
    if (APP_TYPE == 3) {
        if (categoryModel.isSelected) {
            self.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            self.titleBgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
            self.vLineView.backgroundColor = OSSVThemesColors.col_0D0D0D;
        } else {
            self.titleLabel.font = [UIFont systemFontOfSize:12];
            self.titleBgView.backgroundColor = [OSSVThemesColors col_F5F5F5];
            self.vLineView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        }
    } else {
        if (categoryModel.isSelected) {
            self.titleLabel.font = [UIFont systemFontOfSize:12];
            self.titleBgView.backgroundColor = [OSSVThemesColors col_F5F5F5];
            self.vLineView.backgroundColor = [OSSVThemesColors col_0D0D0D];
        } else {
            self.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            self.titleBgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
            self.vLineView.backgroundColor = OSSVThemesColors.stlWhiteColor;
        }
    }
    [self setNeedsDisplay];

}

@end
