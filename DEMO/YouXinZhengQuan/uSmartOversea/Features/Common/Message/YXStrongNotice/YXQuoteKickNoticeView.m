//
//  YXQuoteKickNoticeView.m
//  uSmartOversea
//
//  Created by youxin on 2021/1/21.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXQuoteKickNoticeView.h"
#import <MMKV/MMKV.h>
#import "YXCycleScrollView.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"
#import <UIView+TYAlertView.h>
#import "YXNoticeCell.h"


@interface YXQuoteKickNoticeView () <YXCycleScrollViewDelegate>

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) YXCycleScrollView *textScrollView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIStackView *accessoryStackView;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation YXQuoteKickNoticeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self initializeViews];
        self.hidden = YES;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)initializeViews {
    [self addSubview:self.textScrollView];
    [self addSubview:self.iconView];
    [self addSubview:self.accessoryStackView];
    [self addSubview:self.tipLabel];

    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.width.mas_equalTo(31);
    }];

    [self.accessoryStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self);
        make.right.equalTo(self).offset(-6);
    }];

    [self.textScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.mas_right).offset(0);
        make.right.equalTo(self.accessoryStackView.mas_left).offset(-10);
        make.top.bottom.equalTo(self);
    }];

    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.accessoryStackView.mas_left).offset(-10);
        make.centerY.equalTo(self);
    }];
}

- (void)infoButtonAction {
    [self cycleScrollView:self.textScrollView didSelectItemAtIndex:self.currentIndex];
}

//关闭的响应
- (void)closeButtonAction {
    //YXNoticeModel *noticeModel = self.dataSource[self.currentIndex];



    if (self.didClosed != nil) {
        self.didClosed();
    }

}

- (void)tipLabelTapAction {

}

#pragma mark - getter
- (YXCycleScrollView *)textScrollView {
    if (_textScrollView == nil) {
        _textScrollView = [[YXCycleScrollView alloc] init];
        _textScrollView.backgroundColor = [UIColor clearColor];
        _textScrollView.delegate = self;
        _textScrollView.titleLabelBackgroundColor = [UIColor clearColor];
        _textScrollView.titleLabelTextColor = QMUITheme.textColorLevel1;
        _textScrollView.titleLabelTextFont = [UIFont systemFontOfSize:14];
        _textScrollView.scrollDirection = UICollectionViewScrollDirectionVertical;
        _textScrollView.onlyDisplayText = YES;
        _textScrollView.autoScrollTimeInterval = 3;
        [_textScrollView disableScrollGesture];
    }
    return _textScrollView;
}

- (UILabel *)tipLabel {
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = [YXLanguageUtility kLangWithKey:@"strong_notice_go"];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = QMUITheme.textColorLevel1;
        _tipLabel.hidden = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tipLabelTapAction)];
        [_tipLabel addGestureRecognizer:tap];
    }
    return _tipLabel;
}

- (UIImageView *)iconView {
    if (_iconView == nil) {
        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeCenter;
    }
    return _iconView;
}

- (UIStackView *)accessoryStackView {
    if (!_accessoryStackView) {
        _accessoryStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.arrowView, self.infoButton, self.closeButton]];
        _accessoryStackView.distribution = UIStackViewDistributionEqualSpacing;
        _accessoryStackView.axis = UILayoutConstraintAxisHorizontal;
        _accessoryStackView.spacing = 16;
    }
    return _accessoryStackView;
}

- (UIButton *)infoButton {
    if (!_infoButton) {
        _infoButton = [UIButton buttonWithType:UIButtonTypeCustom
                                         image:[UIImage imageNamed:@"notice_info"]
                                        target:self
                                        action:@selector(infoButtonAction)];
        _infoButton.hidden = YES;
    }
    return _infoButton;
}

- (UIButton *)closeButton {
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:[UIImage imageNamed:@"notice_close"] forState:UIControlStateNormal];
    }
    return _closeButton;
}

- (UIImageView *)arrowView {
    if (_arrowView == nil) {
        _arrowView = [[UIImageView alloc] init];
        _arrowView.image = [UIImage imageNamed:@"notice_arrow"];
        _arrowView.hidden = YES;
    }
    return _arrowView;
}

- (void)setDataSource:(NSArray<YXNoticeModel *> *)dataSource {
    if (_dataSource.count < 1 && dataSource.count > 0) {
        self.currentIndex = 0;
    } else if (_dataSource.count > dataSource.count  && self.currentIndex > dataSource.count - 1) {
        self.currentIndex = dataSource.count - 1;
    }

    _dataSource = dataSource;

    self.tipLabel.hidden = YES;
    self.tipLabel.text = @"";
    self.arrowView.hidden = YES;
    self.infoButton.hidden = YES;
    self.textScrollView.titleLabelTextColor = QMUITheme.textColorLevel1;

    self.iconView.hidden = NO;
    [self.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(31);
    }];

    if ([self.dataSource count] > 0) {
        self.iconView.image = [UIImage imageNamed:@"notice"];
        self.iconView.hidden = YES;
        [self.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(8);
        }];

        [self.closeButton setImage:[UIImage imageNamed:@"notice_close"] forState:UIControlStateNormal];
        self.backgroundColor = [QMUITheme normalStrongNoticeBackgroundColor];
        __block BOOL showAttribute = NO;
        NSMutableArray *titlesGroup = [[NSMutableArray alloc] init];
        [self.dataSource enumerateObjectsUsingBlock:^(YXNoticeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [titlesGroup addObject:obj.content];
            if (obj.isQuoteKicks) {
                showAttribute = YES;
            }
        }];

        if (showAttribute) {
            NSMutableArray *attributeTitlesGroup = [[NSMutableArray alloc] init];
            [self.dataSource enumerateObjectsUsingBlock:^(YXNoticeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                if (obj.isQuoteKicks) {
                    [attributeTitlesGroup addObject:obj.attributeContent];
                } else {

                    NSAttributedString *attr = [YXToolUtility attributedStringWithText:obj.content font:self.textScrollView.titleLabelTextFont textColor:self.textScrollView.titleLabelTextColor lineSpacing:self.textScrollView.lineSpacing];
                    [attributeTitlesGroup addObject:attr];
                }
            }];

            self.textScrollView.attributeTitlesGroup = attributeTitlesGroup;
        }
        self.textScrollView.titlesGroup = titlesGroup;
        [self.textScrollView makeScrollViewScrollToIndex:self.currentIndex];

        if (_dataSource.count == 1) {
            self.textScrollView.autoScroll = NO;
        }

        YXNoticeModel *noticeModel = self.dataSource[self.currentIndex];
        NSData *pushPloyData = [noticeModel.pushPloy dataUsingEncoding:NSUTF8StringEncoding];
        if (!pushPloyData) {
            self.closeButton.hidden = YES;
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[noticeModel.pushPloy dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
            if ([dict[@"clickClose"] integerValue] == 1) {
                self.closeButton.hidden = NO;
            } else {
                self.closeButton.hidden = YES;
            }

            NSInteger result = [dict[@"clickResult"] integerValue];
            if (result == 2 || result == 3) {
                self.infoButton.hidden = NO;
            }
        }

        self.hidden = NO;
    } else {
        self.hidden = YES;
    }

}

- (Class)customCollectionViewCellClassForCycleScrollView:(YXCycleScrollView *)view {
    return [YXNoticeCell class];
}

- (void)setupCustomCell:(YXNoticeCell *)cell
               forIndex:(NSInteger)index
        cycleScrollView:(YXCycleScrollView *)view {
    if (view.attributeTitlesGroup.count && index < view.attributeTitlesGroup.count) {
        cell.titleLabel.attributedText = view.attributeTitlesGroup[index];
    } else if (view.titlesGroup.count && index < view.titlesGroup.count) {
        cell.titleLabel.text = view.titlesGroup[index];
    }
    cell.titleLabel.enableMarqueeAnimation = self.dataSource.count == 1;
    cell.titleLabel.font = view.titleLabelTextFont;
    cell.titleLabel.textColor = view.titleLabelTextColor;
}

- (void)cycleScrollView:(YXCycleScrollView *)cycleScrollView willDisplayCell:(YXNoticeCell *)cell{
    // 在 willDisplayCell 里开启动画（不能在 cellForItem 里开启，是因为 cellForItem 的时候，cell 尚未被 add 到 collectionView 上，cell.window 为 nil）
    [cell.titleLabel requestToStartAnimation];
}

- (void)cycleScrollView:(YXCycleScrollView *)cycleScrollView didEndDisplayingCell:(YXNoticeCell *)cell {
    // 在 didEndDisplayingCell 里停止动画，避免资源消耗
    [cell.titleLabel requestToStopAnimation];
}

- (void)cycleScrollView:(YXCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {

    YXNoticeModel *noticeModel = self.dataSource[index];
    if (noticeModel.isBmp) {
        YXAlertView *alertView = [YXAlertView alertViewWithMessage:noticeModel.content];
        [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_confirm2"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {

        }]];
        [alertView showInWindow];
    } else if (noticeModel.isQuoteKicks) {
        if (self.quoteLevelChangeBlock) {
            self.quoteLevelChangeBlock();
        }
    } else {
        if (self.selectedBlock) {
            self.selectedBlock();
        }
    }

}

- (void)cycleScrollView:(YXCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index {
    self.currentIndex = index;
    YXNoticeModel *noticeModel = self.dataSource[index];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[noticeModel.pushPloy dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
    if ([dict[@"clickClose"] integerValue] == 1) {
        self.closeButton.hidden = NO;
    } else {
        self.closeButton.hidden = YES;
    }

    NSInteger result = [dict[@"clickResult"] integerValue];
    if (result == 2 || result == 3) {
        self.infoButton.hidden = NO;
    } else {
        self.infoButton.hidden = YES;
    }
}



@end

