//
//  ZFGoodsDetailActivityTimeView.m
//  ZZZZZ
//
//  Created by YW on 2019/7/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailActivityTimeView.h"
#import "ZFInitViewProtocol.h"
#import "ZFCountDownView.h"
#import "NSDate+ZFExtension.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "ExchangeManager.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFGoodsDetailGroupBuyModel.h"

@interface ZFGoodsDetailActivityTimeView ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel               *tipLabel;
@property (nonatomic, strong) ZFCountDownView       *countDownView;
@property (nonatomic, strong) YYLabel               *starTimeLabel;
@end

@implementation ZFGoodsDetailActivityTimeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    self.backgroundColor = ZFCOLOR(255, 54, 95, 1);
    [self addSubview:self.tipLabel];
}

- (void)zfAutoLayoutView {
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(6);
        make.trailing.equalTo(self.mas_trailing).offset(-10);
    }];
}

#pragma mark - Setter
- (void)setActivityModel:(GoodsDetailActivityModel *)activityModel {
    [self.countDownView removeFromSuperview];
    [self.starTimeLabel removeFromSuperview];
    
    switch (activityModel.type) {
        case GoodsDetailActivityTypeFlashing:
        {
            self.tipLabel.text = ZFLocalizedString(@"Detail_Ends_in", nil);
            [self addSubview:self.countDownView];
            [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.tipLabel.mas_bottom).offset(5);
                make.trailing.equalTo(self.tipLabel.mas_trailing);
            }];
            // 开启倒计时
            @weakify(self)
            [self.countDownView startTimerWithStamp:activityModel.countDownTime
                                           timerKey:activityModel.countDownTimerKey
                                      completeBlock:^{
                                          @strongify(self)
                                          if (self.countDownCompleteBlock) {
                                              self.countDownCompleteBlock();
                                          }
                                      }];
        }
            break;
        case GoodsDetailActivityTypeFlashNotice:
        {
            self.tipLabel.text = ZFLocalizedString(@"Starts_at", nil);
            [self.tipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(8);
            }];
            
            [self addSubview:self.starTimeLabel];
            [self.starTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.tipLabel.mas_bottom).offset(3);;
                make.trailing.equalTo(self.tipLabel.mas_trailing);
                make.width.mas_equalTo(self.mas_width);
            }];
            
            NSString *resultTime = [self dealTimeStamp:ZFToString(activityModel.beginTime)];
            self.starTimeLabel.text = resultTime;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Private method
- (NSString *)dealTimeStamp:(NSString *)timeStamp {
    NSTimeInterval time = [timeStamp doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateformatter = date.queryZFDateFormatter;
    NSLocale *zhLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateformatter setLocale:zhLocale];
    dateformatter.dateFormat = @"MMM.dd,YYYY HH:mm";
    //    dateformatter.dateFormat = [SystemConfigUtils isRightToLeftShow] ? @"dd.MMM,YYYY HH:mm" : @"MMM.dd,YYYY HH:mm";
    return [dateformatter stringFromDate:date];
}

#pragma mark - Getter
- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = ZFFontSystemSize(12);
        _tipLabel.textColor = ZFC0xFFFFFF();
        _tipLabel.textAlignment = NSTextAlignmentRight;
        _tipLabel.backgroundColor = ZFCOLOR(255, 54, 95, 1);
    }
    return _tipLabel;
}

- (ZFCountDownView *)countDownView {
    if (!_countDownView) {
        _countDownView = [[ZFCountDownView alloc] initWithFrame:CGRectZero tierSizeHeight:18 showDay:NO];
        _countDownView.backgroundColor = ZFCOLOR(255, 54, 95, 1);
        _countDownView.timerCircleRadius = 3;
        _countDownView.timerDotColor = ZFCOLOR_WHITE;
        _countDownView.timerTextColor = ZFCOLOR(255, 54, 95, 1);
    }
    return _countDownView;
}

- (YYLabel *)starTimeLabel {
    if (!_starTimeLabel) {
        _starTimeLabel = [[YYLabel alloc] init];
        _starTimeLabel.font = ZFFontSystemSize(14);
        _starTimeLabel.textColor = ZFC0xFFFFFF();;
        _starTimeLabel.textAlignment = NSTextAlignmentRight;
        _starTimeLabel.backgroundColor = ZFCOLOR(255, 54, 95, 1);
    }
    return _starTimeLabel;
}

@end

