//
//  OSSVOrdersReviewsScoreView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVOrdersReviewsScoreView.h"
#import "Adorawe-Swift.h"


@interface OSSVOrdersReviewsScoreView() {
    CGFloat  _allHeight;
}


@end

@implementation OSSVOrdersReviewsScoreView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _allHeight = 6 + 36*4 + 18 + 44 + 12 + 1+4;
        frame.size.height = _allHeight;
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
//        self.backgroundColor = UIColor.greenColor;
        
        
        self.transportView = [[OrderReviewRatingItem alloc] initWithFrame:CGRectZero];
        self.transportView.titleLabel.text = STLLocalizedString_(@"Shipping_rating", nil);
        self.transportView.type = @"ShippingRating";
        self.goodsView = [[OrderReviewRatingItem alloc] initWithFrame:CGRectZero];
        self.goodsView.titleLabel.text = STLLocalizedString_(@"Item_rating", nil);
        self.goodsView.type = @"ItemRating";
        self.payView = [[OrderReviewRatingItem alloc] initWithFrame:CGRectZero];
        self.payView.titleLabel.text = STLLocalizedString_(@"Payment_rating", nil);
        self.payView.type = @"PaymentRating";
        self.serviceView = [[OrderReviewRatingItem alloc] initWithFrame:CGRectZero];
        self.serviceView.titleLabel.text = STLLocalizedString_(@"Service_rating", nil);
        self.serviceView.type = @"ServiceRating";
        
        UIView *bgView = [[UIView alloc] init];
        [self addSubview:bgView];
        bgView.backgroundColor = UIColor.whiteColor;
        bgView.layer.cornerRadius = 6;
        bgView.layer.masksToBounds = true;
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(UIEdgeInsetsMake(1, 0, 4, 0));
        }];
        
        ///四个评分
        [self addSubview:self.transportView];
        [self addSubview:self.goodsView];
        [self addSubview:self.payView];
        [self addSubview:self.serviceView];
        [self addSubview:self.submitButton];
        
        
        
       
        
        [self.transportView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).mas_offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
            make.top.mas_equalTo(self.mas_top).mas_offset(6+1);
            make.height.mas_equalTo(36);
        }];
        
        [self.goodsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.height.mas_equalTo(self.transportView);
            make.top.mas_equalTo(self.transportView.mas_bottom);
        }];
        
        [self.payView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.height.mas_equalTo(self.transportView);
            make.top.mas_equalTo(self.goodsView.mas_bottom);
        }];
        
        [self.serviceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.height.mas_equalTo(self.transportView);
            make.top.mas_equalTo(self.payView.mas_bottom);
        }];
        
        [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.transportView);
            make.top.mas_equalTo(self.serviceView.mas_bottom).mas_offset(18);
            make.height.mas_equalTo(44);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-16);
        }];

    }
    return self;
}

- (void)handleRating:(CGFloat)trans goods:(CGFloat)goods pay:(CGFloat)pay service:(CGFloat)service {
    self.transportView.ratingControl.grade = trans;
    self.goodsView.ratingControl.grade = goods;
    self.payView.ratingControl.grade = pay;
    self.serviceView.ratingControl.grade = service;
}

- (void)hideCommitButton {
    
    self.userInteractionEnabled = NO;

    _allHeight = 6 + 36*4;;
    CGRect frame = self.frame;
    frame.size.height = _allHeight;
    self.frame = frame;
    [self.submitButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.serviceView.mas_bottom).mas_offset(5);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.height.mas_equalTo(0);
    }];
    
    self.submitButton.hidden = YES;
}


- (void)submitAction:(UIButton *)sender {
    [GATools
     logReviewsWithAction:[NSString stringWithFormat:@"Submit_Shipping-%d/Item-%d/Payment-%d/Service-%d",(int)self.transportView.rateCount,(int)self.goodsView.rateCount,(int)self.payView.rateCount,(int)self.serviceView.rateCount]
     content:[NSString stringWithFormat:@"Product_%@",STLToString(self.orderId)]
    ];
    if (self.reviewBlock) {
        self.reviewBlock();
    }
}

#pragma mark - LazyLoad

- (UIButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_submitButton setTitle:STLLocalizedString_(@"submit",nil).uppercaseString forState:UIControlStateNormal];
        _submitButton.titleLabel.font = [UIFont stl_buttonFont:14];
        _submitButton.backgroundColor = UIColor.whiteColor;
        [_submitButton setTitleColor:OSSVThemesColors.col_0D0D0D forState:UIControlStateNormal];
        _submitButton.layer.cornerRadius = 0;
        _submitButton.layer.borderWidth = 1;
        _submitButton.layer.borderColor = OSSVThemesColors.col_EEEEEE.CGColor;
        _submitButton.layer.masksToBounds = YES;
        [_submitButton addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}
@end


@interface OrderReviewRatingItem()
@end

@implementation OrderReviewRatingItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.rateCount = 5;
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.ratingControl];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.ratingControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(@24);
            make.width.mas_equalTo(@152);
        }];
    }
    return self;
}



- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = OSSVThemesColors.col_666666;
    }
    return _titleLabel;
}

- (ZZStarView *)ratingControl {
    if (!_ratingControl) {
        @weakify(self)
        _ratingControl = [[ZZStarView alloc] initWithImage:[UIImage imageNamed:@"review_new_star"] selectImage:[UIImage imageNamed:@"review_new_star_h"] starWidth:24 starHeight:24 starMargin:8 starCount:5 callBack:^(CGFloat userGrade, CGFloat finalGrade) {
            @strongify(self)
            self.rateCount = userGrade;
//            [GATools
//             logReviewsWithAction:[NSString stringWithFormat:@"%@_Rate_%d",self.type,(int)finalGrade]
//             content:[NSString stringWithFormat:@"Product_%@",STLToString(self.prodName)]
//            ];

        }];
        _ratingControl.userInteractionEnabled = YES;
        _ratingControl.sublevel = 1;
        _ratingControl.grade = _rateCount;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _ratingControl.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
        _ratingControl.backgroundColor = [UIColor whiteColor];
        _ratingControl.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _ratingControl;
}

@end
