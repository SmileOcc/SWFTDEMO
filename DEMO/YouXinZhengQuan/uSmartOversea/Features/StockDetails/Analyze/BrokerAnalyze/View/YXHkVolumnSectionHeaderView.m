//
//  YXHkVolumnSectionHeaderView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/3/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXHkVolumnSectionHeaderView.h"
#import "YXHkVolumnModel.h"
#import "UILabel+create.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>
#import <YXKit/YXKit.h>
#import "uSmartOversea-Swift.h"

@interface YXHkVolumnSingleView: UIView

@property (nonatomic, strong) YXHkVolumnSubModel *model;

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *buyLabel;
@property (nonatomic, strong) UILabel *ratoLabel;

@property (nonatomic, assign) NSInteger priceBase;

@end

@implementation YXHkVolumnSingleView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}
#pragma mark - 设置UI
- (void)setUI {
    
    UILabel *dateLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:12]];
    UILabel *numberLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:12]];
    UILabel *buyLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:12]];
    UILabel *ratoLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:12]];
    
    
    self.dateLabel = dateLabel;
    self.numberLabel = numberLabel;
    self.buyLabel = buyLabel;
    self.ratoLabel = ratoLabel;
    
    float scale = YXConstant.screenWidth / 375.0;

    [self addSubview:dateLabel];
    [self addSubview:numberLabel];
    [self addSubview:buyLabel];
    [self addSubview:ratoLabel];
    
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(16);
        make.centerY.equalTo(self);
    }];
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(106 * scale);
        make.centerY.equalTo(self);
    }];
    [buyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-100 * scale);
        make.centerY.equalTo(self);
    }];
    [ratoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-16);
        make.centerY.equalTo(self);
    }];
    
}

- (void)setModel:(YXHkVolumnSubModel *)model {
    _model = model;
    if (model.dateType == 1) {
        self.dateLabel.text = [YXLanguageUtility kLangWithKey:@"recent_one_day"];
    } else if (model.dateType == 5) {
        self.dateLabel.text = [YXLanguageUtility kLangWithKey:@"recent_five_day"];
    } else if (model.dateType == 20) {
        self.dateLabel.text = [YXLanguageUtility kLangWithKey:@"recent_twenty_day"];
    } else if (model.dateType == 60) {
        self.dateLabel.text = [YXLanguageUtility kLangWithKey:@"recent_sixty_day"];
    }
    if (model.changeRatio < 100) {
        self.ratoLabel.text = [NSString stringWithFormat:@"%.3f%%", model.changeRatio / 100.0];
    } else {
        self.ratoLabel.text = [NSString stringWithFormat:@"%.2f%%", model.changeRatio / 100.0];
    }
    NSString *numberStr = [YXToolUtility stocKNumberData:model.changeVolume deciPoint:2 stockUnit:[YXLanguageUtility kLangWithKey:@"stock_unit"] priceBase:0].string;;
    if (model.changeVolume > 0) {
        numberStr = [NSString stringWithFormat:@"+%@", numberStr];
    }
    self.numberLabel.text = numberStr;
    
    NSString *buyStr = [YXToolUtility stocKNumberData:model.changeAmount deciPoint:2 stockUnit:@"" priceBase:self.priceBase].string;;
    if (model.changeAmount > 0) {
        buyStr = [NSString stringWithFormat:@"+%@", buyStr];
    }
    self.buyLabel.text = buyStr;
}


@end


@interface YXHkVolumnSectionHeaderView ()

@property (nonatomic, strong) UIView *bottomView;

@end

@implementation YXHkVolumnSectionHeaderView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    self.clipsToBounds = YES;
    UILabel *dateLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"broker_date"] textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:12]];
    UILabel *numberLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"economic_change_volume"] textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:12]];
    UILabel *buyLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"economic_change_amount"] textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:12]];
    UILabel *ratoLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"economic_hold_ratio"] textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:12]];
    
    float scale = YXConstant.screenWidth / 375.0;

    [self addSubview:dateLabel];
    [self addSubview:numberLabel];
    [self addSubview:buyLabel];
    [self addSubview:ratoLabel];
    
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(16);
        make.top.equalTo(self).offset(8);
    }];
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(106 * scale);
        make.top.equalTo(self).offset(8);
    }];
    [buyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-100 * scale);
        make.top.equalTo(self).offset(8);
    }];
    [ratoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-16);
        make.top.equalTo(self).offset(8);
    }];
    
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.top.equalTo(self).offset(30);
    }];
}

- (void)setModel:(YXHkVolumnModel *)model {
    _model = model;
    for (UIView *subView in self.bottomView.subviews) {
        [subView removeFromSuperview];
    }
    for (int i = 0; i < model.list.count; ++i) {
        YXHkVolumnSubModel *subModel = model.list[i];
        CGRect rect = CGRectMake(0, i * 30, YXConstant.screenWidth, 30);
        YXHkVolumnSingleView *view = [[YXHkVolumnSingleView alloc] initWithFrame:rect];
        view.priceBase = model.priceBase;
        view.model = subModel;
        [self.bottomView addSubview:view];
    }

}

#pragma mark - 懒加载

- (UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
    }
    return _bottomView;
}

@end
