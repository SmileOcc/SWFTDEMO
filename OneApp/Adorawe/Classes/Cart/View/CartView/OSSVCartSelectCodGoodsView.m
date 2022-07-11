//
//  OSSVCartSelectCodGoodsView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/16.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartSelectCodGoodsView.h"

@implementation OSSVCartSelectCodGoodsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = OSSVThemesColors.col_FFFFFF;
        
        [self addSubview:self.codTitleLabel];
        [self addSubview:self.rightArrow];
        [self addSubview:self.horizontalLine];
        
        [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
            make.size.mas_equalTo(CGSizeMake(8, 16));
        }];
        
        [self.codTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).mas_offset(8);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-8);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
            make.trailing.mas_equalTo(self.rightArrow.mas_leading).mas_offset(-5);
        }];
        
        [self.horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTap)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)setHtmlTitle:(NSString *)htmlTitles specialUrl:(NSString *)url {
    
    _rightArrow.hidden = url.length > 0 ? NO : YES;
    
    self.codTitleLabel.hidden = htmlTitles.length > 0 ? NO : YES;
    
    if (htmlTitles.length) {
        
        [self.codTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).mas_offset(8);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-8);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
            make.trailing.mas_equalTo(self.rightArrow.mas_leading).mas_offset(-5);
        }];
        
        //NSHTMLTextDocumentType 要在主线程刷
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIFont *font=[UIFont systemFontOfSize:11];
            NSMutableAttributedString *componets=[[NSMutableAttributedString alloc] init];
            NSDictionary *optoins=@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,
                                    NSFontAttributeName:font};
            NSData *data=[STLToString(htmlTitles) dataUsingEncoding:NSUnicodeStringEncoding];
            
            NSAttributedString *textPart=[[NSAttributedString alloc] initWithData:data
                                                                          options:optoins
                                                               documentAttributes:nil
                                                                            error:nil];
            [componets appendAttributedString:textPart];
            self.codTitleLabel.attributedText = componets;
            self.codTitleLabel.font = [UIFont systemFontOfSize:11];
            self.codTitleLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft ;
            self.codTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        });
    } else {
        [self.codTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).mas_offset(0);
            make.height.mas_equalTo(0);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(0);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
            make.trailing.mas_equalTo(self.rightArrow.mas_leading).mas_offset(-5);
        }];
    }
}


- (void)clickTap {
    if (self.operateBlock) {
        self.operateBlock();
    }
}
- (void)actionTouch:(UIButton *)sender {
    if (self.operateBlock) {
        self.operateBlock();
    }
}

- (UILabel *)codTitleLabel {
    if (!_codTitleLabel) {
        _codTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _codTitleLabel.backgroundColor = [UIColor whiteColor];
        _codTitleLabel.font = [UIFont systemFontOfSize:11];
        _codTitleLabel.textColor = OSSVThemesColors.col_333333;
        _codTitleLabel.text = @"";
        _codTitleLabel.numberOfLines = 2;
    }
    return _codTitleLabel;
}


- (UIView *)horizontalLine {
    if (!_horizontalLine) {
        _horizontalLine = [[UIView alloc] init];
        _horizontalLine.backgroundColor = OSSVThemesColors.col_F6F6F6;
    }
    return _horizontalLine;
}

- (YYAnimatedImageView *)rightArrow {
    if (!_rightArrow) {
        _rightArrow = [[YYAnimatedImageView alloc] init];
        _rightArrow.image = [UIImage imageNamed:[OSSVSystemsConfigsUtils isRightToLeftShow] ? @"arrow_left" : @"arrow_right"];
        _rightArrow.hidden = YES;
    }
    return _rightArrow;
}


- (UIButton *)eventButton {
    if (!_eventButton) {
        _eventButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eventButton addTarget:self action:@selector(actionTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _eventButton;
}
@end
