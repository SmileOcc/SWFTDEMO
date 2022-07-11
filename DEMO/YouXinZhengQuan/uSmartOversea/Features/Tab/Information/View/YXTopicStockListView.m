//
//  YXTopicStockListView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/30.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTopicStockListView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "YXHotTopicModel.h"

@interface YXTopicStockSingleView: UIView

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *rocLabel;

@property (nonatomic, strong) YXHotTopicStockModel *model;

@property (nonatomic, copy) void (^clickCallBack)(YXHotTopicStockModel *model);

@end

@implementation YXTopicStockSingleView


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
    
    self.backgroundColor = [UIColor qmui_colorWithHexString:@"#EDEDED"];
    self.layer.cornerRadius = 2;
    self.clipsToBounds = YES;
    
    UIView *leftView = [[UIView alloc] init];
    leftView.backgroundColor = QMUITheme.themeTextColor;
    
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons_news_blue_more"]];
    
    [self addSubview:leftView];
    [self addSubview:arrowView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.rocLabel];
    
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self);
        make.width.mas_equalTo(2);
        make.height.mas_equalTo(8);
    }];
    [arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-6);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(6);
        make.centerY.equalTo(self);
    }];
    [self.rocLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).offset(4);
        make.centerY.equalTo(self);
        make.right.lessThanOrEqualTo(self).offset(-20);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(stockClick:)];
    [self addGestureRecognizer:tap];
}

- (void)setModel:(YXHotTopicStockModel *)model {
    _model = model;
    NSString *operator = @"";
    UIColor *color = QMUITheme.stockGrayColor;
    if (model.pctchng > 0) {
        operator = @"+";
        color = QMUITheme.stockRedColor;
    } else if (model.pctchng < 0) {
        color = QMUITheme.stockGreenColor;
    }
    self.rocLabel.textColor = color;
    self.rocLabel.text = [NSString stringWithFormat:@"%@%.2f%%", operator, model.pctchng / 100.0];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ (%@.%@)",model.name, model.symbol, [model.market uppercaseString]];
    
}

- (void)stockClick:(UIControl *)sender {
    if (self.clickCallBack) {
        self.clickCallBack(self.model);
    }
}

#pragma mark - lazy load
- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.themeTextColor textFont:[UIFont systemFontOfSize:10]];
    }
    return _nameLabel;
}

- (UILabel *)rocLabel {
    if (_rocLabel == nil) {
        _rocLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.stockGrayColor textFont:[UIFont systemFontOfSize:10]];
    }
    return _rocLabel;
}

@end




@interface YXTopicStockListView()

@end

@implementation YXTopicStockListView


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
    
}

- (void)setList:(NSArray *)list {
    _list = list;
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    UIView *tempView = nil;
    NSInteger count = list.count > 2 ? 2 : list.count;
    for (int i = 0; i < count; ++i) {
        YXTopicStockSingleView *view = [[YXTopicStockSingleView alloc] init];
        view.model = list[i];
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            if (tempView) {
                make.left.equalTo(tempView.mas_right).offset(8);
            } else {
                make.left.equalTo(self).offset(8);
            }
            make.centerY.equalTo(self);
            make.height.mas_equalTo(16);
        }];
        tempView = view;
        [self layoutIfNeeded];
        if (CGRectGetMaxX(tempView.frame) > YXConstant.screenWidth) {
            tempView.hidden = YES;
        }
        @weakify(self);
        [view setClickCallBack:^(YXHotTopicStockModel *model) {
            @strongify(self);
            if (self.stockClickCallBack) {
                self.stockClickCallBack(model);
            }
        }];
    }
}

#pragma mark - lazy load



@end
