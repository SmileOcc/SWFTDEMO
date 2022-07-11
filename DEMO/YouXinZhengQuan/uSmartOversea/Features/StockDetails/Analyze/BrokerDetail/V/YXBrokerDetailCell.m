//
//  YXBrokerDetailCell.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXBrokerDetailCell.h"
#import "YXBrokerDetailModel.h"
#import "UILabel+create.h"
#import <Masonry/Masonry.h>
#import "YXDateToolUtility.h"
#import "YXDateModel.h"
#import "YXToolUtility.h"
#import "uSmartOversea-Swift.h"

@interface YXBrokerDetailCell ()

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, strong) UILabel *holdLabel;

@property (nonatomic, strong) UILabel *changeLabel;

@property (nonatomic, strong) UILabel *buyLabel;


@end

@implementation YXBrokerDetailCell

- (void)initialUI {
    [super initialUI];
    
    self.backgroundColor = QMUITheme.foregroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.dateLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:12]];
    self.numberLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:12]];
    self.holdLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:12]];
    self.changeLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:12]];
    self.buyLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:12]];

    self.numberLabel.textAlignment = NSTextAlignmentRight;
    self.holdLabel.textAlignment = NSTextAlignmentRight;
    self.changeLabel.textAlignment = NSTextAlignmentRight;
    self.buyLabel.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.scrollView];
    [self.contentView addGestureRecognizer:self.scrollView.panGestureRecognizer];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(16);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(116);
        make.top.bottom.right.equalTo(self);
    }];
    
    self.numberLabel.frame = CGRectMake(0, 0, 100, 34);
    self.holdLabel.frame = CGRectMake(100, 0, 80, 34);
    self.changeLabel.frame = CGRectMake(180, 0, 80, 34);
    self.buyLabel.frame = CGRectMake(260, 0, 100, 34);
    
    self.scrollView.contentSize = CGSizeMake(360 + 16, 34);
    
    [self.scrollView addSubview:self.numberLabel];
    [self.scrollView addSubview:self.holdLabel];
    [self.scrollView addSubview:self.changeLabel];
    [self.scrollView addSubview:self.buyLabel];
    
}

- (void)setSubModel:(YXBrokerDetailSubModel *)subModel {
    _subModel = subModel;
    
    self.dateLabel.text = [YXDateHelper commonDateString:subModel.date format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:NO];
    
    self.numberLabel.attributedText = [YXToolUtility stocKNumberData:subModel.holdVolume deciPoint:2 stockUnit:[YXLanguageUtility kLangWithKey:@"stock_unit_en"] priceBase:0 numberFont:[UIFont systemFontOfSize:14] unitFont:[UIFont systemFontOfSize:14]];
    
    if (subModel.holdRatio < 100) {
        self.holdLabel.text = [NSString stringWithFormat:@"%.3f%%", subModel.holdRatio / 100.0];
    } else {
        self.holdLabel.text = [NSString stringWithFormat:@"%.2f%%", subModel.holdRatio / 100.0];
    }
    
    if (subModel.changeRatio > 0) {
        self.changeLabel.text = [NSString stringWithFormat:@"+%.2f%%", subModel.changeRatio / 100.0];
    } else {
        self.changeLabel.text = [NSString stringWithFormat:@"%.2f%%", subModel.changeRatio / 100.0];
    }
        
    NSString *buyStr = [YXToolUtility stocKNumberData:subModel.changeVolume deciPoint:2 stockUnit:[YXLanguageUtility kLangWithKey:@"stock_unit_en"] priceBase:0].string;
    if (subModel.changeVolume > 0) {
        self.buyLabel.text = [NSString stringWithFormat:@"+%@", buyStr];
    } else {
        self.buyLabel.text = buyStr;
    }
    
}


- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.userInteractionEnabled = NO;
    }
    return _scrollView;
}

@end
