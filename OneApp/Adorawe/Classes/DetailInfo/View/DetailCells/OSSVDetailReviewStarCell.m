//
//  OSSVDetailReviewStarCell.m
// XStarlinkProject
//
//  Created by odd on 2021/4/13.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailReviewStarCell.h"

@implementation OSSVDetailReviewStarCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self.contentView addSubview:self.leftTitle];
        [self.contentView addSubview:self.starRating];
        [self.contentView addSubview:self.starNumber];
        [self.contentView addSubview:self.rightArrow];
        [self.contentView addSubview:self.horizontalLine];
        
        [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-16);
            make.size.mas_equalTo(CGSizeMake(24, 24));
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        [self.starNumber mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.rightArrow.mas_leading);
            make.centerY.mas_equalTo(self.rightArrow.mas_centerY);
        }];
        
        [self.starRating mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.starNumber.mas_leading);
            make.centerY.mas_equalTo(self.rightArrow.mas_centerY);
            make.height.mas_equalTo(@16);
            make.width.mas_equalTo(@80);
        }];
        
        [self.leftTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(16);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(250);
        }];
        
        [self.horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}
#pragma mark - setter

- (void)setModel:(OSSVReviewsModel *)model {
    
    self.starRating.grade = model.agvRate;
    if (model.agvRate <= 0) {
        self.starNumber.text = @"";
    } else {
        self.starNumber.text = [NSString stringWithFormat:@"%.1f",model.agvRate];
    }
    
    self.count = model.reviewCount;
    NSString *countStr = [NSString stringWithFormat:@"%ld",(long)self.count];
    
    if (self.count >= 1000) {
        countStr = @"999+";
    }
    self.leftTitle.text =  [NSString stringWithFormat:@"%@ (%@)",STLLocalizedString_(@"reviews",nil),countStr];
    
    
    self.rightArrow.hidden = YES;
    self.starRating.hidden = YES;
    
    if (self.count > 0) {
        self.rightArrow.hidden = NO ;
        self.starRating.hidden = NO;
    }
}


- (UILabel *)leftTitle {
    if (!_leftTitle) {
        _leftTitle = [[UILabel alloc] init];
        _leftTitle.font = [UIFont boldSystemFontOfSize:13];
        _leftTitle.textColor = [OSSVThemesColors col_0D0D0D];
        _leftTitle.numberOfLines = 1;
        [_leftTitle convertTextAlignmentWithARLanguage];
    }
    return _leftTitle;
}

- (YYAnimatedImageView *)rightArrow {
    if (!_rightArrow) {
        _rightArrow = [[YYAnimatedImageView alloc] init];
        _rightArrow.image = [UIImage imageNamed:@"detail_right_arrow"];
        [_rightArrow convertUIWithARLanguage];
        _rightArrow.hidden = YES;
    }
    return _rightArrow;
}

- (ZZStarView *)starRating {
    if (!_starRating) {
        _starRating = [[ZZStarView alloc] initWithImage:[UIImage imageNamed:@"review_new_star"] selectImage:[UIImage imageNamed:@"review_new_star_h"] starWidth:24 starHeight:24 starMargin:8 starCount:5 callBack:^(CGFloat userGrade, CGFloat finalGrade) {
            
        }];
        _starRating.userInteractionEnabled = NO;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _starRating.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
        _starRating.sublevel = 1;
        _starRating.backgroundColor = [UIColor whiteColor];
        _starRating.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _starRating.hidden = YES;
    }
    return _starRating;
}

- (UILabel *)starNumber {
    if (!_starNumber) {
        _starNumber = [[UILabel alloc] initWithFrame:CGRectZero];
        _starNumber.textColor = [OSSVThemesColors col_FFCF60];
        _starNumber.font = [UIFont systemFontOfSize:13];
    }
    return _starNumber;
}

- (UIView *)horizontalLine {
    if (!_horizontalLine) {
        _horizontalLine = [[UIView alloc] init];
        _horizontalLine.backgroundColor = OSSVThemesColors.col_F6F6F6;
    }
    return _horizontalLine;
}
@end
