//
//  YXStockFilterGroupCell.m
//  uSmartOversea
//
//  Created by youxin on 2020/9/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockFilterGroupCell.h"
#import "uSmartOversea-Swift.h"
#import "UILabel+create.h"
#import <Masonry/Masonry.h>

@interface YXStockFilterGroupLRView: UIView

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;

@end

@implementation YXStockFilterGroupLRView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {

    self.leftLabel = [self createLabel:YES];
    self.rightLabel = [self createLabel:NO];

    [self addSubview:self.leftLabel];
    [self addSubview:self.rightLabel];

    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(6);
        make.top.equalTo(self);
        if ([YXUserManager isENMode]) {
            make.width.equalTo(@(80));
        } else {
            make.width.equalTo(@(88));
        }
    }];

    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftLabel.mas_right);
        make.right.equalTo(self).offset(-14);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];

}

- (UILabel *)createLabel:(BOOL)isTitle {
    UILabel *label = [UILabel labelWithText:@"" textColor:[QMUITheme.textColorLevel1 colorWithAlphaComponent:0.65] textFont:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft];
    label.adjustsFontSizeToFitWidth = true;
    label.minimumScaleFactor = 0.9;
    if (isTitle) {
        [label setContentCompressionResistancePriority:(UILayoutPriorityRequired) forAxis:(UILayoutConstraintAxisHorizontal)];
    }
    return label;
}
@end

@interface YXStockFilterGroupCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) NSArray *labelsArray;

@property (nonatomic, strong) YXStockPopoverButton *moreButton;

@end

@implementation YXStockFilterGroupCell
@dynamic model;

- (void)initialUI {
    [super initialUI];
    self.backgroundColor = QMUITheme.foregroundColor;

    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = [QMUITheme backgroundColor];
    [self.contentView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    UIView *cornerView = [[UIView alloc] init];
    cornerView.backgroundColor = QMUITheme.foregroundColor;
    cornerView.layer.cornerRadius = 6;
    [self.contentView addSubview:cornerView];
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(12);
        make.right.equalTo(self.contentView).offset(-12);
        make.top.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.contentView).offset(-5);
    }];

    self.nameLabel = [UILabel labelWithText:@"" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:16] textAlignment:(NSTextAlignmentLeft)];

    [cornerView addSubview:self.nameLabel];

    NSMutableArray *titleMutArr = [NSMutableArray array];
    for (int i = 0; i < 6; i ++) {
        YXStockFilterGroupLRView *view = [[YXStockFilterGroupLRView alloc] init];
        [titleMutArr addObject:view];
    }
    self.labelsArray = titleMutArr;


    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cornerView).offset(20);
        make.left.equalTo(cornerView).offset(14);
        make.right.equalTo(cornerView).offset(-36);
    }];

    UIView *preView = nil;
    for (YXStockFilterGroupLRView *lrView in self.labelsArray) {
        [self.contentView addSubview:lrView];
        [lrView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(cornerView);
            if (preView != nil) {
                make.top.equalTo(preView.mas_bottom).offset(8);
            } else {
                make.top.equalTo(self.nameLabel.mas_bottom).offset(14);
            }
        }];
        lrView.hidden = YES;
        preView = lrView;
    }

    [cornerView addSubview:self.moreButton];
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(25);
        make.right.equalTo(cornerView).offset(-9);
        make.centerY.equalTo(self.nameLabel);
    }];

}

- (void)refreshUI {

    self.nameLabel.text = self.model.name;

    for (YXStockFilterGroupLRView *lrView in self.labelsArray) {
        lrView.hidden = YES;
    }

    [self.model.groups enumerateObjectsUsingBlock:^(YXStokFilterGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if (idx < self.labelsArray.count) {
            YXStockFilterGroupLRView *lrView = self.labelsArray[idx];
//            if ([YXUserManager curLanguage] == YXLanguageTypeEN) {
//                lrView.leftLabel.text = [NSString stringWithFormat:@" [%@] ", obj.name ?: @""];
//            } else {
//                lrView.leftLabel.text = [NSString stringWithFormat:@"【%@】", obj.name ?: @""];
//            }

            lrView.leftLabel.text = [NSString stringWithFormat:@"【%@】", obj.name ?: @""];

            lrView.hidden = NO;
            NSInteger index = 0;
            NSString *content = @"";
            for (YXStockFilterItem *item in obj.items) {

                NSString *value = @"";
                NSInteger insideIndex = 0;
                for (YXStokFilterQueryValueListItem *info in item.queryValueList) {
                    for (YXStokFilterListItem *infoItem in info.list) {
                        if ([item.key isEqualToString:@"rangeChng"]) {

                            if (insideIndex > 1) {
                                value = [NSString stringWithFormat:@"%@，%@", value, infoItem.name];
                            } else if (insideIndex == 1) {
                                value = [NSString stringWithFormat:@"%@：%@", value, infoItem.name];
                            } else {
                                value = [NSString stringWithFormat:@"%@(%@)", value, infoItem.name];
                            }

                        } else {
                            if (insideIndex > 0) {
                                value = [NSString stringWithFormat:@"%@，%@", value, infoItem.name];
                            } else {
                                value = [NSString stringWithFormat:@"%@%@", value, infoItem.name];
                            }
                        }

                        insideIndex ++;
                    }
                }

                if (index > 0) {
                    content = [NSString stringWithFormat:@"%@ | %@：%@", content, item.name, value];
                } else {
                    if ([item.key isEqualToString:@"rangeChng"]) {
                        content = [NSString stringWithFormat:@"%@%@", item.name, value];
                    } else {
                        content = [NSString stringWithFormat:@"%@：%@", item.name, value];
                    }
                }
                index ++;
            }
            lrView.rightLabel.text = content;
        }

    }];


}



#pragma mark - setter


#pragma mark - getter

- (YXStockPopoverButton *)moreButton {
    if (!_moreButton) {

        _moreButton = [[YXStockPopoverButton alloc] initWithFrame:CGRectZero titles:@[[YXLanguageUtility kLangWithKey:@"modify_indicator"], [YXLanguageUtility kLangWithKey:@"rename"], [YXLanguageUtility kLangWithKey:@"common_delete"]]];

        [_moreButton setImage:[UIImage imageNamed:@"filter_more"] forState:UIControlStateNormal];
        _moreButton.needShowSelected = NO;
        _moreButton.isOnlyShowImage = YES;
        @weakify(self)
        [_moreButton setClickItemBlock:^(NSInteger index) {
            @strongify(self)
            if (self.operateBlock) {
                self.operateBlock(index);
            }
        }];
    }
    return _moreButton;
}

- (UILabel *)createLabel:(BOOL)isTitle {
    UILabel *label = [UILabel labelWithText:@"" textColor:[QMUITheme.textColorLevel1 colorWithAlphaComponent:0.65] textFont:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft];
    if (isTitle) {
        [label setContentCompressionResistancePriority:(UILayoutPriorityRequired) forAxis:(UILayoutConstraintAxisHorizontal)];
    }
    return label;
}
@end
