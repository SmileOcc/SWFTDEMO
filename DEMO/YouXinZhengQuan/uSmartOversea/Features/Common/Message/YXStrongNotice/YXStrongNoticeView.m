//
//  YXStrongNoticeView.m
//  uSmartOversea
//
//  Created by ellison on 2018/12/5.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXStrongNoticeView.h"
#import <YXKit/YXNetworkUtil.h>
#import <MMKV/MMKV.h>
#import "YXCycleScrollView.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"
#import <UIView+TYAlertView.h>
#import "YXNoticeCell.h"
//#import "UIImage+Color.h"

#define YXNoticeTimeOutKey @"YXNoticeTimeOutKey"
#define YXNoticeTimeOutTime (3 * 24 * 60 * 60)

@interface YXStrongNoticeView () <YXCycleScrollViewDelegate>

//@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) YXCycleScrollView *textScrollView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIStackView *accessoryStackView;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong, readwrite) YXMessageCenterService *services;

@end

@implementation YXStrongNoticeView

- (instancetype)initWithFrame:(CGRect)frame services:(YXMessageCenterService *)services
{
    self = [self initWithFrame:frame];
    if (self) {
        self.services = services;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeViews];
        self.hidden = YES;
        
        HLNetWorkStatus netWorkStatus = [YXNetworkUtil.sharedInstance.reachability currentReachabilityStatus];
        if (netWorkStatus == HLNetWorkStatusNotReachable) {
            self.noticeType = YXStrongNoticeTypeNetWork;
        } else {
            self.noticeType = YXStrongNoticeTypeNone;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetWorkChangeNotification:) name:kNetWorkReachabilityChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//setter 是否需要 展示 notice
- (void)setNeedShowNotice:(BOOL)needShowNotice {
    _needShowNotice = needShowNotice;
    
    if (_needShowNotice) {
        double oldTime = [[MMKV defaultMMKV] getDoubleForKey:YXNoticeTimeOutKey];
        double nowTime = [[NSDate date] timeIntervalSince1970];
        
        if (nowTime - oldTime > YXNoticeTimeOutTime) {
            self.noticeType = YXStrongNoticeTypeNotice;
        } else {
            _needShowNotice = NO;
            self.noticeType = YXStrongNoticeTypeNone;
        }
    } else { //不需要 展示
        self.noticeType = YXStrongNoticeTypeNone;
    }
}

//MARK: - 网络监听的回调
- (void)handleNetWorkChangeNotification:(NSNotification *)ntf
{
    HLNetWorkReachability *reachability = (HLNetWorkReachability *)ntf.object;
    HLNetWorkStatus netWorkStatus = [reachability currentReachabilityStatus];
    
    if (netWorkStatus == HLNetWorkStatusNotReachable) {
        self.noticeType = YXStrongNoticeTypeNetWork;
    } else {
        if (self.needShowNotice) {
            self.noticeType = YXStrongNoticeTypeNotice;
        } else {
            if ([self.dataSource count] > 0) {
                self.noticeType = YXStrongNoticeTypeNormal;
            } else {
                self.noticeType = YXStrongNoticeTypeNone;
            }
        }
    }
}

- (void)initializeViews {
    [self addSubview:self.textScrollView];
//    [self addSubview:self.iconView];
    [self addSubview:self.accessoryStackView];
    [self addSubview:self.tipLabel];
    [self addSubview:self.infoButton];
    
//    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.bottom.equalTo(self);
//        make.width.mas_equalTo(31);
//    }];

    [self.accessoryStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self);
        make.right.equalTo(self).offset(-6);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(16));
    }];
    
    [self.infoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(16));
        make.left.equalTo(self).offset(15);
        make.centerY.equalTo(self);
    }];

    [self.textScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.infoButton.mas_right).offset(8);
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
    if (self.noticeType == YXStrongNoticeTypeNetWork) {
        if (self.needShowNotice) {
            self.noticeType = YXStrongNoticeTypeNotice;
        } else {
            if ([self.dataSource count] > 0) {
                self.noticeType = YXStrongNoticeTypeNormal;
            } else {
                self.noticeType = YXStrongNoticeTypeNone;
            }
        }
    } else if (self.noticeType == YXStrongNoticeTypeNotice) {
        [[MMKV defaultMMKV] setDouble:[[NSDate date] timeIntervalSince1970] forKey:YXNoticeTimeOutKey];
        if ([self.dataSource count] > 0) {
            self.noticeType = YXStrongNoticeTypeNormal;
        } else {
            self.noticeType = YXStrongNoticeTypeNone;
        }
    } else if(self.noticeType == YXStrongNoticeTypeNormal) {
        YXNoticeModel *noticeModel = self.dataSource[self.currentIndex];
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[noticeModel.pushPloy dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
        if ([dict[@"clickClose"] integerValue] == 1) {
            if ([dict[@"donotSendReq"] integerValue] == 1) {} else {
                [self closeMsgRequestWithMsgid:[NSString stringWithFormat:@"%lld", noticeModel.msgId]];
            }
            
            NSMutableArray *array = [self.dataSource mutableCopy];
            [array removeObjectAtIndex:self.currentIndex];
            self.currentIndex = 0;
            self.dataSource = [array copy];
        }
        if (noticeModel.isBmp) {
            if (self.bmpCloseCallBack) {
                self.bmpCloseCallBack();
            }
        }

        if (noticeModel.isTempCode) {
            if (self.tempCodeCloseCallBack) {
                self.tempCodeCloseCallBack();
            }
        }
    }
    
    if (self.didClosed != nil) {
        self.didClosed();
    }
    
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
    }
    return _tipLabel;
}

//- (UIImageView *)iconView {
//    if (_iconView == nil) {
//        _iconView = [[UIImageView alloc] init];
//        _iconView.contentMode = UIViewContentModeCenter;
//    }
//    return _iconView;
//}

- (UIStackView *)accessoryStackView {
    if (!_accessoryStackView) {
        _accessoryStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.arrowView, self.closeButton]];
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
        _arrowView.contentMode = UIViewContentModeScaleAspectFit;
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
    if (self.noticeType != YXStrongNoticeTypeNetWork) {
        if ([_dataSource count] > 0) {
            if (_dataSource.count == 1) {
                self.textScrollView.autoScroll = NO;
            } else {
                self.textScrollView.autoScroll = YES;
            }
            self.noticeType = YXStrongNoticeTypeNormal;
        } else {
            self.noticeType = YXStrongNoticeTypeNone;
        }
    }
}

- (void)setNoticeType:(YXStrongNoticeType)noticeType {
    _noticeType = noticeType;
    
    self.tipLabel.hidden = YES;
    self.tipLabel.text = @"";
    self.arrowView.hidden = YES;
    self.infoButton.hidden = YES;
    self.textScrollView.titleLabelTextColor = QMUITheme.themeTintColor;
    
//    self.iconView.hidden = NO;
//    [self.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(31);
//    }];
    
    if (_noticeType == YXStrongNoticeTypeNetWork) {
        // 【没有网络连接，请检查你的网络】
        self.backgroundColor = QMUITheme.noticeBackgroundColor;
//        self.iconView.image =   [UIImage imageNamed:@"notice_warning"];
        self.textScrollView.titlesGroup = @[[YXLanguageUtility kLangWithKey:@"strong_notice_no_net"]];
        self.arrowView.hidden = YES;
        self.closeButton.hidden = YES;
        self.infoButton.hidden = NO;
        [self.infoButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(16));
        }];
        self.hidden = NO;
        
//        [self.textScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self).offset(16);
//
//        }];
        
    } else if (self.needShowNotice && _noticeType == YXStrongNoticeTypeNotice) {
        // 【消息通知已关闭,您可能错过及时通知】
        self.backgroundColor = QMUITheme.themeTextColor;
//        self.iconView.image = [UIImage imageNamed:@"notice"];
//        self.iconView.hidden = YES;
//        [self.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(8);
//        }];

        self.textScrollView.titlesGroup = @[[YXLanguageUtility kLangWithKey:@"strong_notice_noti_close"]];
        self.closeButton.hidden = NO;
        self.arrowView.hidden = NO;
        self.tipLabel.hidden = NO;
        self.hidden = NO;
        
    } else if (_noticeType == YXStrongNoticeTypeNormal || _noticeType == YXStrongNoticeTypeCustom) {
        if ([self.dataSource count] > 0) {
            if (self.isCurrencyExchange) {
//                self.iconView.image = [UIImage imageNamed:@"notice"];
                [self.closeButton setImage:[UIImage imageNamed:@"notice_close"] forState:UIControlStateNormal];
                self.backgroundColor = [QMUITheme normalStrongNoticeBackgroundColor];
            } else {
//                self.iconView.image = [UIImage imageNamed:@"notice"];
                [self.closeButton setImage:[UIImage imageNamed:@"icon_close_clear"] forState:UIControlStateNormal];
                self.backgroundColor = [[UIColor qmui_colorWithHexString:@"#414FFF"] colorWithAlphaComponent:0.1];
                self.textScrollView.titleLabelTextColor = [QMUITheme mainThemeColor];
            }

//            self.iconView.hidden = YES;
//            [self.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.width.mas_equalTo(8);
//            }];

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
            
            YXNoticeModel *noticeModel = self.dataSource[self.currentIndex];

            if (noticeModel.isBmp) {
                self.infoButton.hidden = NO;
                [self.infoButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@(16));
                }];
            } else {
                [self.infoButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@(0));
                }];
            }
            
            if (_noticeType == YXStrongNoticeTypeCustom) {
                self.infoButton.hidden = NO;
                self.closeButton.hidden = YES;
                self.arrowView.hidden = YES;
                self.tipLabel.hidden = YES;
                
                [self.infoButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@(16));
                }];
            } else {
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
                        [self.infoButton mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.width.equalTo(@(16));
                        }];
                    } else {
                        [self.infoButton mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.width.equalTo(@(0));
                        }];
                    }
                }

            }

            self.hidden = NO;
        } else {
            self.hidden = YES;
        }
    }  else {
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
    
    cell.titleLabel.enableMarqueeAnimation = self.dataSource.count == 0 || self.dataSource.count == 1;
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
    if (self.noticeType == YXStrongNoticeTypeNetWork) {

        YXAlertView *alertView = [[YXAlertView alloc] initWithTitle:[YXLanguageUtility kLangWithKey:@"strong_notice_no_net_title"] message:[YXLanguageUtility kLangWithKey:@"strong_notice_no_net_message"] prompt:nil style:YXAlertStyleDefault messageAlignment:NSTextAlignmentCenter];
        YXAlertAction *cancelAction = [YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_iknow"] style:YXAlertActionStyleCancel handler:^(YXAlertAction * _Nonnull action) {
            
        }];
        YXAlertAction *sureAction = [YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"strong_notice_no_net_setting"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertView addAction:cancelAction];
        [alertView addAction:sureAction];
        [alertView showInWindow];
        
    } else if (self.noticeType == YXStrongNoticeTypeNotice) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    } else if (self.noticeType == YXStrongNoticeTypeNormal) {
        YXNoticeModel *noticeModel = self.dataSource[index];
        if (noticeModel.isBmp) {
            YXAlertView *alertView = [YXAlertView alertViewWithMessage:noticeModel.content];
            [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_confirm2"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {
                
            }]];
            [alertView showInWindow];
        } else if (noticeModel.isTempCode) {
            if (self.tempCodeJumpCallBack) {
                self.tempCodeJumpCallBack();
            }
        } else if (noticeModel.isQuoteKicks) {
            if (self.quoteLevelChangeBlock) {
                self.quoteLevelChangeBlock();
            }
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[noticeModel.pushPloy dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];

        NSInteger result = [dict[@"clickResult"] integerValue];
        if (result == 2) {
            //泰语、马来语先用英文
            NSString *resultSupplement = @"";
            if ([YXUserManager curLanguage] == YXLanguageTypeCN) {
                resultSupplement = dict[@"resultSupplement"];
            } else if ([YXUserManager curLanguage] == YXLanguageTypeHK) {
                resultSupplement = dict[@"resultSupplementHk"];
            } else if ([YXUserManager curLanguage] == YXLanguageTypeEN) {
                resultSupplement = dict[@"resultSupplementUs"];
            } else if ([YXUserManager curLanguage] == YXLanguageTypeTH) {
                resultSupplement = dict[@"resultSupplementUs"];
            } else if ([YXUserManager curLanguage] == YXLanguageTypeML) {
                resultSupplement = dict[@"resultSupplementUs"];
            }
            YXAlertView *alertView = [YXAlertView alertViewWithMessage:resultSupplement];
            [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_confirm2"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {

            }]];
            [alertView showInWindow];
        } else if (result == 3) {
            NSString *jumpPageUrl = dict[@"jumpPageUrl"];
            [YXGoToNativeManager.shared gotoNativeViewControllerWithUrlString:jumpPageUrl];
        }
    } else if (self.noticeType == YXStrongNoticeTypeCustom) {
        if (self.selectedBlock) {
            self.selectedBlock();
        }
    }
}

- (void)cycleScrollView:(YXCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index {
    self.currentIndex = index;

    self.infoButton.hidden = YES;

    if (self.noticeType == YXStrongNoticeTypeNormal) {
        YXNoticeModel *noticeModel = self.dataSource[index];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[noticeModel.pushPloy dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
        if ([dict[@"clickClose"] integerValue] == 1) {
            self.closeButton.hidden = NO;
        } else {
            self.closeButton.hidden = YES;
        }

        NSInteger result = [dict[@"clickResult"] integerValue];
        if (noticeModel.isBmp || result == 2 || result == 3) {
            self.infoButton.hidden = NO;
            [self.infoButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(16));
            }];
        } else {
            [self.infoButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(0));
            }];
        }
    } else if (self.noticeType == YXStrongNoticeTypeCustom){
        if (self.selectedBlock) {
            self.selectedBlock();
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
