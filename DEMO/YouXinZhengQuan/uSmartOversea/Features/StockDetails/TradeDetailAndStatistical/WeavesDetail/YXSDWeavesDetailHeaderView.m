//
//  YXSDWeavesDetailHeaderView.m
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXSDWeavesDetailHeaderView.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "uSmartOversea-Swift.h"

@interface YXSDWeavesDetailHeaderView()

@property (nonatomic, assign) BOOL isUsNation;

@end

@implementation YXSDWeavesDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame andIsUsNation: (BOOL)isUsNation {
    self = [super initWithFrame:frame];
    if (self) {
        self.isUsNation = isUsNation;
        [self configureView];
    }
    return self;
}

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self configureView];
//    }
//    return self;
//}

- (void) configureView {
    self.backgroundColor = [QMUITheme backgroundColor];
    
    //白色背景
    UIView * bgView = [UIView new];
    bgView.backgroundColor = [QMUITheme foregroundColor];
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.trailing.equalTo(self);
    }];
    
    QMUIButton *dateBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
    dateBtn.imagePosition = QMUIButtonImagePositionRight;
    [dateBtn setTitle:[YXLanguageUtility kLangWithKey:@"stock_deal_time"] forState:UIControlStateNormal];
    dateBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [dateBtn setTitleColor:[QMUITheme textColorLevel2] forState:UIControlStateNormal];
    [dateBtn setImagePosition:QMUIButtonImagePositionRight];
    [dateBtn setSpacingBetweenImageAndTitle:5];
    [dateBtn setImage:[UIImage imageNamed:@"params_info"] forState:UIControlStateNormal];
    
    UILabel *dealLab = [self buildLabelWith:[YXLanguageUtility kLangWithKey:@"stock_deal_final_price"]];
    
    UILabel *dealNumLab = [self buildLabelWith:[YXLanguageUtility kLangWithKey:@"market_volume"]];
    
    QMUIButton *directionBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
    directionBtn.imagePosition = QMUIButtonImagePositionRight;
    [directionBtn setTitle:[YXLanguageUtility kLangWithKey:@"trading_direction_tip"] forState:UIControlStateNormal];
    directionBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [directionBtn setTitleColor:[QMUITheme textColorLevel2] forState:UIControlStateNormal];
    [directionBtn setImagePosition:QMUIButtonImagePositionRight];
    [directionBtn setSpacingBetweenImageAndTitle:5];
    [directionBtn setImage:[UIImage imageNamed:@"params_info"] forState:UIControlStateNormal];
    directionBtn.titleLabel.numberOfLines = 2;
    directionBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [[directionBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(__kindof UIControl * _Nullable x) {
        [YXWebViewModel pushToWebVC:[YXH5Urls tradeDirectionExplainUrl]];
    }];
    
    [[dateBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(__kindof UIControl * _Nullable x) {
        //响应
        [YXWebViewModel pushToWebVC:[YXH5Urls tickTypeExplainUrl]];
        
    }];
    
    [bgView addSubview:dateBtn];
    [bgView addSubview:dealLab];
    [bgView addSubview:dealNumLab];
    [bgView addSubview:directionBtn];
    
    if (self.isUsNation) {
        UILabel *exchangeLab = [self buildLabelWith:[YXLanguageUtility kLangWithKey:@"exchange"]];
        [bgView addSubview:exchangeLab];
        
        [dateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(bgView).offset(12);
            make.centerY.equalTo(bgView);
        }];
        
        [dealLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(bgView).offset(105);
            make.centerY.equalTo(bgView);
        }];
        
        [dealNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(bgView).offset(195);
            make.centerY.equalTo(bgView);
            make.width.mas_lessThanOrEqualTo(40);
        }];
        
        [directionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bgView);
            make.trailing.equalTo(bgView).offset(-85);
            make.width.mas_lessThanOrEqualTo(45);
        }];
        [exchangeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bgView);
            make.trailing.equalTo(bgView).offset(-12);
            make.width.mas_lessThanOrEqualTo(65);
        }];
        
    } else {
        [dateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(bgView).offset(12);
            make.centerY.equalTo(bgView);
        }];
        
        [dealLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(bgView.mas_centerX).offset(-70);
            make.centerY.equalTo(bgView);
        }];
        
        [dealNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(bgView.mas_centerX).offset(40);
            make.centerY.equalTo(bgView);
            make.width.mas_lessThanOrEqualTo(55);
        }];
        
        [directionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bgView);
            make.trailing.equalTo(bgView).offset(-20);
            make.width.mas_lessThanOrEqualTo(50);
        }];
    }
    
    //横线
    UIView *topLine = [UIView new];
    topLine.backgroundColor = QMUITheme.separatorLineColor;
    [self addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(7);
        make.trailing.equalTo(self).offset(-7);
        make.top.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    
}



- (UILabel *)buildLabelWith:(NSString *)text {
    UILabel * lab = [UILabel new];
    lab.text = text;
    lab.textColor = [QMUITheme textColorLevel2];
    lab.font = [UIFont systemFontOfSize:12];
    if (YXUserManager.isENMode) {
        lab.numberOfLines = 2;
        lab.adjustsFontSizeToFitWidth = YES;
    }
    return lab;
}

@end
