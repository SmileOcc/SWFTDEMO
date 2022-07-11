//
//  OSSVCategoryCollectionHeadView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/29.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategoryCollectionHeadView.h"

@interface OSSVCategoryCollectionHeadView ()

@property (nonatomic, strong) UIView                    *headBackGroundView;
@property (nonatomic, strong) UIView                    *lineView;
@property (nonatomic, strong) UIImageView               *lineImageView;
@property (nonatomic, strong) UILabel                   *headViewTitleLabel;
@property (nonatomic, strong) UIButton                  *headViewMoreBtn;
@property (nonatomic, strong) OSSVSecondsCategorysModel    *selectModel;
/**点击的channelItemID*/
@property (nonatomic, strong) NSString *channelId;

@end

@implementation OSSVCategoryCollectionHeadView

#pragma marks - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        __weak typeof(self)ws = self;

        self.backgroundColor = [OSSVThemesColors col_F5F5F5];
        if (APP_TYPE == 3) {
            self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        }
        [self addSubview:self.headBackGroundView];
        [self.headBackGroundView addSubview:self.headViewTitleLabel];
        [self.headBackGroundView addSubview:self.lineImageView];
        [self.headBackGroundView addSubview:self.headViewMoreBtn];
        [self.headBackGroundView addSubview:self.lineView];
        
        [self.headBackGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.mas_top);
            make.leading.trailing.mas_equalTo(ws);
            make.height.mas_equalTo(40);
        }];
        
        
        [self.headViewMoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.headBackGroundView.mas_top);
            make.height.mas_equalTo(40);
            if (APP_TYPE == 3) {
                make.trailing.mas_equalTo(self.headBackGroundView);
            } else {
                make.leading.trailing.mas_equalTo(self.headBackGroundView);
            }
        }];
        
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.headBackGroundView.mas_bottom).offset(-1);
            make.leading.trailing.mas_equalTo(ws);
            make.height.mas_equalTo(1);
        }];
        
        [self.headViewTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if(APP_TYPE == 3) {
                make.leading.mas_equalTo(self.headBackGroundView.mas_leading);
                make.top.mas_equalTo(self.headBackGroundView.mas_top).offset(15);
            } else {
                make.leading.mas_equalTo(self.headBackGroundView.mas_leading).offset(10);
                make.top.mas_equalTo(self.headBackGroundView.mas_top).offset(17);
            }
            make.trailing.mas_equalTo(self.headBackGroundView.mas_trailing).offset(-1);
            make.height.mas_equalTo(14);
        }];
        
        if (APP_TYPE == 3) {
            [self.lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.headViewMoreBtn.mas_trailing);
                make.leading.mas_equalTo(self.headViewMoreBtn.mas_leading);
                make.bottom.mas_equalTo(self.headViewMoreBtn.mas_bottom).offset(-10);
                make.height.mas_equalTo(1);
            }];
        }
        
    }
    return self;
}


#pragma mark - user actions
//See All 按钮点击
- (void)headViewMoreBtnClick {
    if(self.categoriesSeeAllDelegate)
    {
        [self.categoriesSeeAllDelegate categoriesChannelId:self.selectModel cell:self];
    }
}

#pragma mark - LazyLoad setters and getters

- (void)setModel:(OSSVSecondsCategorysModel *)model {
    
    self.selectModel = model;
    if (APP_TYPE == 3) {
        self.headViewTitleLabel.text = [OSSVSystemsConfigsUtils isRightToLeftShow] ? [NSString stringWithFormat:@"%@",[self firstCharactersCapitalized:model.cat_name]] : [NSString stringWithFormat:@"%@",[self firstCharactersCapitalized:model.cat_name]];
        self.headViewMoreBtn.hidden = YES;
        self.lineImageView.hidden = YES;
        if (!STLIsEmptyString(model.link)) {
            self.headViewMoreBtn.hidden = NO;
            self.lineImageView.hidden = NO;
        }
        

        [self.headViewTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.headBackGroundView.mas_top).offset(15);
        }];
        
    } else {
        self.headViewTitleLabel.text = [OSSVSystemsConfigsUtils isRightToLeftShow] ? [NSString stringWithFormat:@"%@  ",model.cat_name].uppercaseString : [NSString stringWithFormat:@"  %@",model.cat_name].uppercaseString;
        self.headViewMoreBtn.hidden = model.isAllCorners ? NO : YES;

        [self.headViewTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.headBackGroundView.mas_top).offset(model.isAllCorners ? 13 : 17);
        }];
    }
    self.channelId = model.cat_id;
//    self.headViewMoreBtn.hidden = model.cat_id.length >0?NO:YES;
    
    [self.headBackGroundView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(40);
    }];
    
    
    
    
    [self setNeedsDisplay];
}

- (NSString *)firstCharactersCapitalized:(NSString *)string {
    if (STLIsEmptyString(string)) {
        return @"";
    }
    
    string = [string lowercaseString];
    NSString *resultStr = [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] capitalizedString]];
    return resultStr;
}

- (UIView *)headBackGroundView {
    if (!_headBackGroundView)
    {
        _headBackGroundView = [UIView new];
        _headBackGroundView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _headBackGroundView;
}

- (UILabel *)headViewTitleLabel {
    if (!_headViewTitleLabel)
    {
        _headViewTitleLabel = [UILabel new];
        _headViewTitleLabel.textAlignment = NSTextAlignmentLeft;
        if (APP_TYPE == 3) {
            _headViewTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        } else {
            _headViewTitleLabel.font = [UIFont boldSystemFontOfSize:12];
        }
        _headViewTitleLabel.textColor = [OSSVThemesColors col_262626];
        _headViewTitleLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    }
    return _headViewTitleLabel;
}

- (UIButton *)headViewMoreBtn
{
    if (!_headViewMoreBtn)
    {
        _headViewMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _headViewMoreBtn.backgroundColor = [UIColor clearColor];
//        [_headViewMoreBtn setTitle:[NSString stringWithFormat:@"%@ >",STLLocalizedString_(@"seeAll", nil)] forState:UIControlStateNormal];
//        _headViewMoreBtn.titleLabel.textAlignment = NSTextAlignmentRight;
//        _headViewMoreBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//        [_headViewMoreBtn setTitleColor:OSSVThemesColors.col_666666 forState:UIControlStateNormal];
        [_headViewMoreBtn addTarget:self action:@selector(headViewMoreBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _headViewMoreBtn.hidden = YES;
        if (APP_TYPE == 3) {
            [_headViewMoreBtn setTitle:[NSString stringWithFormat:@"%@",STLLocalizedString_(@"viewAll", nil)] forState:UIControlStateNormal];
            if (APP_TYPE==3) {
                _headViewMoreBtn.titleLabel.font = [UIFont systemFontOfSize:12];

            } else {
                _headViewMoreBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            }
            [_headViewMoreBtn setTitleColor:[OSSVThemesColors col_000000:0.5] forState:UIControlStateNormal];
            _headViewMoreBtn.hidden = NO;
        }
    }
    return _headViewMoreBtn;
}

- (UIImageView *)lineImageView {
    if (!_lineImageView) {
        _lineImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        UIImage *backImg = STLImageWithName(@"spic_dash_line_black");
        UIColor*bcColor =[UIColor colorWithPatternImage:backImg];
        _lineImageView.hidden = YES;
        _lineImageView.backgroundColor = bcColor;
    }
    return _lineImageView;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (APP_TYPE == 3) {
        
    } else {
        if (self.selectModel.isAllCorners) {
            [self.headBackGroundView stlAddCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(6, 6)];
        } else {
            [self.headBackGroundView stlAddCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(6, 6)];
        }
    }

}
@end
