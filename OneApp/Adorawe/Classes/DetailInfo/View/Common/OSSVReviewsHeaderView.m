//
//  OSSVReviewsHeaderView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVReviewsHeaderView.h"
#import "ZZStarView.h"

@interface OSSVReviewsHeaderView ()

@property (nonatomic, weak) ZZStarView *starRating; // 评价分数
@property (nonatomic, weak) UILabel *starNumber; // 平均分

@end

@implementation OSSVReviewsHeaderView


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        UIView *ws = self;
        
        ws.backgroundColor = [OSSVThemesColors col_F5F5F5];
        
        /*平均分*/
        UILabel *starNumber = [[UILabel alloc] initWithFrame:CGRectZero];
        starNumber.textColor = [OSSVThemesColors col_0D0D0D];
        starNumber.font = [UIFont boldSystemFontOfSize:36];
        [ws addSubview:starNumber];
        
        [starNumber mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(ws.mas_leading);
            make.centerY.mas_equalTo(ws.mas_centerY);
        }];
        self.starNumber = starNumber;
        
        /*星星*/
        ZZStarView *starRating = [[ZZStarView alloc] initWithImage:[UIImage imageNamed:@"star_small_review"] selectImage:[UIImage imageNamed:@"star_small_review_h"] starWidth:14 starHeight:14 starMargin:2 starCount:5 callBack:^(CGFloat userGrade, CGFloat finalGrade) {
            
        }];
        _starRating.sublevel = 1;
        starRating.userInteractionEnabled = NO;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            starRating.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
        starRating.backgroundColor = [UIColor clearColor];
        starRating.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [ws addSubview:starRating];
        
        [starRating mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.starNumber.mas_trailing).mas_offset(8);
            make.centerY.mas_equalTo(ws.mas_centerY);
            make.height.mas_equalTo(@14);
            make.width.mas_equalTo(@78);
        }];
        self.starRating = starRating;
    }
    
    return self;
}

- (void)setModel:(OSSVReviewsModel *)model {
    _model = model;
    self.starRating.grade = model.agvRate;
    // 此处只保留1位小数
    self.starNumber.text = [NSString stringWithFormat:@"%.1f",model.agvRate];
}

@end
