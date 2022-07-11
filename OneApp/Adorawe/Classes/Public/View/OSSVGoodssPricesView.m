//
//  OSSVGoodssPricesView.m
// XStarlinkProject
//
//  Created by odd on 2020/12/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVGoodssPricesView.h"

@implementation OSSVGoodssPricesView

- (instancetype)initWithFrame:(CGRect)frame isShowIcon:(BOOL)isShow{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        

        [self addSubview:self.titleLabel];
        [self addSubview:self.priceLabel];
        [self addSubview:self.originalPriceLabel];
        [self addSubview:self.activityFullReductionView];
        
        if (APP_TYPE == 3) {
            self.titleLabel.hidden = NO;
            self.originalPriceLabel.hidden = YES;
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.mas_top).offset(4);
                if (isShow) {
                    make.trailing.mas_equalTo(self.mas_trailing).offset(-34);
                } else {
                    make.trailing.mas_equalTo(self.mas_trailing).offset(-8);
                }
                make.leading.mas_equalTo(self.mas_leading);
            }];
            
            [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
                make.leading.mas_equalTo(self.mas_leading);
            }];
            
            [self.originalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.centerY.mas_equalTo(self.priceLabel.mas_centerY);
                make.trailing.mas_equalTo(self.mas_trailing);
                make.leading.mas_equalTo(self.priceLabel.mas_trailing).offset(2);
            }];
            
            [self.activityFullReductionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading);
                make.height.mas_equalTo(0);
                make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-8);
            }];
            
            // 设置抗压缩优先级
            [self.priceLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
            [self.priceLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];

            [self.originalPriceLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            [self.originalPriceLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

        } else {
            
            [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.top.mas_equalTo(self.mas_top).offset(8);
                make.trailing.mas_equalTo(self);
                make.leading.mas_equalTo(self.mas_leading).offset(8);
            }];
            
            [self.originalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.top.mas_equalTo(self.priceLabel.mas_bottom).offset(2);
                make.trailing.mas_equalTo(self);
                make.leading.mas_equalTo(self.mas_leading).offset(8);
            }];
            
            [self.activityFullReductionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading);
                make.height.mas_equalTo(0);
                make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-8);
            }];
        }
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.priceLabel];
        [self addSubview:self.originalPriceLabel];
        [self addSubview:self.activityFullReductionView];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.mas_equalTo(self.mas_top).offset(8);
            make.trailing.mas_equalTo(self);
            make.leading.mas_equalTo(self.mas_leading).offset(8);
        }];
        
        [self.originalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.mas_equalTo(self.priceLabel.mas_bottom).offset(2);
            make.trailing.mas_equalTo(self);
            make.leading.mas_equalTo(self.mas_leading).offset(8);
        }];
        
        [self.activityFullReductionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading);
            make.height.mas_equalTo(0);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-8);
        }];
    }
    return self;
}

- (void)price:(NSString *)price originalPrice:(NSString *)originPrice activityMsg:(NSString *)activityMsg activityHeight:(CGFloat)activityHeight title:(NSString *)title{
    
    self.titleLabel.text = STLToString(title);
    self.priceLabel.text = STLToString(price);
    self.originalPriceLabel.text = STLToString(originPrice);
    self.activityFullReductionView.tipMessage = STLToString(activityMsg);
    
    if (activityHeight > 0) {
        [self.activityFullReductionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(activityHeight);
        }];
        
        [self.activityFullReductionView updateTipMasWidth:activityHeight > 20 ? YES : NO];
    } else {
        [self.activityFullReductionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
   
}

+ (CGFloat)activithHeight:(NSString *)msg contentWidth:(CGFloat)width {
    CGFloat fullHeight = 0;
    if (!STLIsEmptyString(msg)) {
        
        //标题内容高
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:4];

        
        UIFont *textFont = [UIFont systemFontOfSize:10];
        CGSize titleSize;
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        paragraph.lineSpacing = 4;//连字符

        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};

        if (APP_TYPE == 3) {
            titleSize = [[STLToString(msg) uppercaseString] boundingRectWithSize:CGSizeMake(width - 8- 4 - 8, CGFLOAT_MAX)
                                                            options:(NSStringDrawingUsesLineFragmentOrigin |
                                                                     NSStringDrawingTruncatesLastVisibleLine)
                                                         attributes:attributes
                                                            context:nil].size;
            
        } else {
            titleSize = [[STLToString(msg) uppercaseString] boundingRectWithSize:CGSizeMake(width - 8 - 4 - 8, CGFLOAT_MAX)
                                                            options:(NSStringDrawingUsesLineFragmentOrigin |
                                                                     NSStringDrawingTruncatesLastVisibleLine)
                                                         attributes:attributes
                                                            context:nil].size;
            
        }
        
        if (titleSize.width <= 0) {//没有内容
            titleSize.height = 0;
        } else if (titleSize.height < 21) {//内容没有超过1行
            titleSize.height = 16;
        } else {
            titleSize.height = 28;
        }
        
        fullHeight = titleSize.height;
    }
    return fullHeight;
}

+ (CGFloat)contentHeight:(CGFloat)activityHeight {
    CGFloat bottomHeight = kHomeCellBottomViewHeight;
    if (activityHeight > 0) {
        return bottomHeight + activityHeight + 4;
    } else {
        return bottomHeight;
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _titleLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [OSSVThemesColors col_000000:0.7];
        _titleLabel.hidden = YES;
    }
    return _titleLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _priceLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        if (APP_TYPE == 3) {
            _priceLabel.font = [UIFont boldSystemFontOfSize:14];
            _priceLabel.textColor = [OSSVThemesColors col_000000:1];

        } else {
            _priceLabel.font = [UIFont boldSystemFontOfSize:15];
            _priceLabel.textColor = [OSSVThemesColors col_0D0D0D];

        }
        _priceLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _priceLabel;
}

- (STLCLineLabel *)originalPriceLabel {
    if (!_originalPriceLabel) {
        _originalPriceLabel = [[STLCLineLabel alloc] init];
        _originalPriceLabel.backgroundColor = [OSSVThemesColors stlWhiteColor];
        if (APP_TYPE == 3) {
            _originalPriceLabel.font = [UIFont systemFontOfSize:12];
            _originalPriceLabel.textColor = [OSSVThemesColors col_000000:0.5];
        } else {
            _originalPriceLabel.font = [UIFont systemFontOfSize:11];
            _originalPriceLabel.textColor = [OSSVThemesColors col_6C6C6C];
        }
        _originalPriceLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _originalPriceLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _originalPriceLabel;
}

- (OSSVDetailsActivityFullReductionView *)activityFullReductionView {
    if (!_activityFullReductionView) {
        _activityFullReductionView = [[OSSVDetailsActivityFullReductionView alloc] initWithFrame:CGRectZero];
    }
    return _activityFullReductionView;
}
@end
