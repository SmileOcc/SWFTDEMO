
//
//  ZFSubmitReviewCheckTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/3/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSubmitReviewCheckTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFReviewsDetailStarsView.h"
#import "ZFThemeManager.h"
#import "ZFReviewSizeView.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "ZFLocalizationString.h"

@interface ZFSubmitReviewCheckTableViewCell() <ZFInitViewProtocol>

//@property (nonatomic, strong) ZFReviewsDetailStarsView      *starsView;
@property (nonatomic, strong) UILabel                       *overallLabel;
@property (nonatomic, strong) UILabel                       *contentLabel;
@property (nonatomic, strong) UILabel                       *timeLabel;
@property (nonatomic, strong) ZFReviewSizeView              *sizeView;

@end

@implementation ZFSubmitReviewCheckTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
//    [self.contentView addSubview:self.starsView];
    [self.contentView addSubview:self.overallLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.sizeView];
}

- (void)zfAutoLayoutView {
    
//    [self.starsView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.contentView.mas_top).offset(12);
//        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
//        make.size.mas_equalTo(CGSizeMake(120, 20));
//    }];
    
    [self.overallLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.top.mas_equalTo(self.contentView.mas_top).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.overallLabel);
        make.top.mas_equalTo(self.overallLabel.mas_bottom).offset(8);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.overallLabel);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(4);
    }];
    
    [self.sizeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).mas_offset(14);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        make.height.mas_offset(32);
    }];
}

#pragma mark - setter
- (void)setModel:(ZFOrderReviewModel *)model {
    _model = model;
    self.contentLabel.text = _model.reviewList.firstObject.content;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:[[ZFLocalizationString shareLocalizable] fetchAppLocalLanguage]];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:[[ZFLocalizationString shareLocalizable] fetchAppLocalLanguage]];
    dateFormatter.timeZone = timeZone;
    [dateFormatter setDateFormat:@"MMM.dd,yyyy  HH:mm:ss aa"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[_model.reviewList.firstObject.add_time integerValue]]];
    NSMutableString* date= [[NSMutableString alloc]initWithString:currentDateStr];
    [date insertString:@"at" atIndex:12];
    self.timeLabel.text = date;
    
    //顺序 <Height, Waist, Hips, Bust Size>
    if (_model.reviewList.firstObject.reviewSize.is_save && [_model.reviewList.firstObject.reviewSize isShowReviewsSize]) {
        self.sizeView.hidden = NO;
        [self.sizeView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(32);
        }];
        self.sizeView.contentList = @[
                                      ZFToString(_model.reviewList.firstObject.reviewSize.height),
                                      ZFToString(_model.reviewList.firstObject.reviewSize.waist),
                                      ZFToString(_model.reviewList.firstObject.reviewSize.hips),
                                      ZFToString(_model.reviewList.firstObject.reviewSize.bust)
                                      ];
    } else {
        self.sizeView.hidden = YES;
        [self.sizeView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
    }
    
    NSString *overallFit = ZFLocalizedString(@"Reviews_OverallFit", nil);
    self.overallLabel.text = [NSString stringWithFormat:@"%@ : %@", overallFit, [model.reviewList.firstObject.reviewSize reviewsOverallContent]];
}

#pragma mark - getter
//- (ZFReviewsDetailStarsView *)starsView {
//    if (!_starsView) {
//        _starsView = [[ZFReviewsDetailStarsView alloc] initWithFrame:CGRectZero];
//        _starsView.backgroundColor = ZFCOLOR_WHITE;
//    }
//    return _starsView;
//}

-(UILabel *)overallLabel
{
    if (!_overallLabel) {
        _overallLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 1;
            label.textColor = ZFC0x2D2D2D();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _overallLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _timeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _timeLabel;
}

-(ZFReviewSizeView *)sizeView
{
    if (!_sizeView) {
        _sizeView = [[ZFReviewSizeView alloc] init];
    }
    return _sizeView;
}

@end
