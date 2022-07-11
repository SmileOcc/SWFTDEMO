//
//  OSSVDetailHeaderCoinView.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/8.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailHeaderCoinView.h"

#import "YYLabel.h"
#import "YYText.h"
@interface OSSVDetailHeaderCoinView()

@property (nonatomic, strong) UIImageView       *coinImgV;
@property (nonatomic, strong) UILabel           *tipLab;
@property (nonatomic, strong) YYLabel           *helpLabel;

@property (nonatomic, strong) OSSVDetailsBaseInfoModel *baseModel;
@end

@implementation OSSVDetailHeaderCoinView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView{
    [self addSubview:self.coinImgV];
    [self addSubview:self.tipLab];
    [self addSubview:self.helpLabel];
    
    [self.coinImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.leading.mas_equalTo(self.mas_leading);
        make.width.height.mas_equalTo(12);
    }];
    
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.coinImgV.mas_centerY);
        make.leading.mas_equalTo(self.coinImgV.mas_trailing).offset(4);
        make.height.mas_greaterThanOrEqualTo(20);
    }];
    
    UILabel *temp = [UILabel new];
    temp.font = [UIFont systemFontOfSize:12];
    temp.text = STLLocalizedString_(@"Learn_More", nil);
    CGFloat width = [temp sizeThatFits:CGSizeMake(MAXFLOAT, 20)].width;
    
    [self.helpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.coinImgV.mas_centerY);
        make.leading.mas_equalTo(self.tipLab.mas_trailing).offset(4);
        make.height.mas_greaterThanOrEqualTo(20);
        make.width.equalTo(width);
    }];
            
}


- (void)configBaseInfoModel:(OSSVDetailsBaseInfoModel *)baseInfoModel{
    _baseModel = baseInfoModel;
    NSString *tipCoin = baseInfoModel.return_coin_desc.return_coin;
    self.tipLab.text = tipCoin;
}


- (UIImageView *)coinImgV{
    if (!_coinImgV) {
        _coinImgV = [UIImageView new];
        _coinImgV.image = [UIImage imageNamed:@"coin_icon"];
    }
    return _coinImgV;
}

- (UILabel *)tipLab{
    if (!_tipLab) {
        _tipLab = [UILabel new];
        _tipLab.textColor = [OSSVThemesColors col_0D0D0D];
        _tipLab.font = [UIFont systemFontOfSize:12];
    }
    return _tipLab;
}

- (YYLabel *)helpLabel{
    if (!_helpLabel) {
        _helpLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        
        _helpLabel.font = [UIFont systemFontOfSize:12];
        _helpLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 12*2 - 14*2;

        if (APP_TYPE == 3) {
            
        } else {        
            [_helpLabel sizeToFit];
        }
        
        UIColor *textColor = [OSSVThemesColors col_6C6C6C];
        if (APP_TYPE == 3) {
            textColor = [OSSVThemesColors col_000000:0.5];
        }
        _helpLabel.textColor = textColor;
        
        NSMutableParagraphStyle *paragraphStyle  =[[NSMutableParagraphStyle alloc] init];
        NSDictionary *attrDict =@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                  NSForegroundColorAttributeName:textColor,
                                  NSParagraphStyleAttributeName:paragraphStyle};
        
        NSMutableAttributedString *conditionAtt = [[NSMutableAttributedString alloc] initWithString:STLLocalizedString_(@"Learn_More", nil) attributes:attrDict];
        
        NSRange LessRange = [conditionAtt.string rangeOfString:STLLocalizedString_(@"Learn_More", nil)];
        
        YYTextLineStyle decorationStyle =  YYTextLineStyleSingle;
        if (APP_TYPE == 3) {
            decorationStyle = YYTextLineStyleNone;
        }
        YYTextDecoration *decoration = [YYTextDecoration decorationWithStyle:decorationStyle
                                                                       width:@(0.5)
                                                                       color:textColor];
        
        if (LessRange.location != NSNotFound) {
            [conditionAtt yy_setTextUnderline:decoration range:LessRange];
            [conditionAtt yy_setTextHighlightRange:LessRange
                                             color:textColor
                                   backgroundColor:[UIColor clearColor]
                                         tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                
                [self helpBtnDidSelected];
                                             
            }];
            if (APP_TYPE == 3) {
                //虚线
//                [conditionAtt yy_setAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle|NSUnderlinePatternDot) range:LessRange];
//                [conditionAtt yy_setAttribute:NSUnderlineColorAttributeName value:textColor range:LessRange];
                //用图片
                for (UIView *view in _helpLabel.subviews) {
                    if (view.tag == 100) {
                        [view removeFromSuperview];
                    }
                }
                UIView *lineView = [UIView new];
                lineView.tag = 100;
                UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"spic_dash_line_black"]];
                lineView.backgroundColor = color;
                [_helpLabel addSubview:lineView];
                [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.equalTo(0);
                    make.bottom.equalTo(0);
                    make.height.equalTo(1);
                }];
            }
        }
        
        _helpLabel.attributedText = conditionAtt;
    }
    return _helpLabel;
}



- (void)helpBtnDidSelected{
    if (self.coinBlock) {
        self.coinBlock();
    }
}


@end
