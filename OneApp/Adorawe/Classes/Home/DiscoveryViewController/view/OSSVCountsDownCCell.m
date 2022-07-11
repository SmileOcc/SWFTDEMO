//
//  OSSVCountsDownCCell.m
// OSSVCountsDownCCell
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCountsDownCCell.h"
#import "ZJJTimeCountDown.h"
#import "OSSVSecondsKillsModel.h"

@interface OSSVCountsDownCCell ()

@property (nonatomic, strong) UIView         *countView;
@property (nonatomic, strong) UIImageView    *iconImageView;
@property (nonatomic, strong) UILabel        *iconLabel;
@property (nonatomic, strong) ZJJTimeCountDownLabel *countDownLabel;
@end

@implementation OSSVCountsDownCCell
@synthesize model = _model;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.countView];
        [self.countView addSubview:self.iconImageView];
        [self.countView addSubview:self.iconLabel];
        [self.countView addSubview:self.countDownLabel];
        
        [self.countView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self);
            make.height.mas_offset(frame.size.height);
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.countView);
            make.leading.mas_equalTo(self.countView.mas_leading).mas_offset(15);
            make.trailing.mas_equalTo(self.iconLabel.mas_leading).mas_offset(-5);
        }];
        
        [self.iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.countView);
            make.leading.mas_equalTo(self.iconImageView.mas_trailing).mas_offset(5);
            make.height.mas_equalTo(self.countView);
            make.trailing.mas_equalTo(self.countDownLabel.mas_leading).mas_offset(-5);
        }];
        
        [self.countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.countView);
            make.leading.mas_equalTo(self.iconLabel.mas_trailing).mas_offset(5);
            make.height.mas_equalTo(self.countView);
            make.trailing.mas_equalTo(self.countView.mas_trailing).mas_offset(-15);
            ///如果不设置一个固定的宽度，时间在变化的时候会相应的有微微的移动
            ///24是小黑宽的宽度，16是 : 的宽度  15是一个缺省宽度
            make.width.mas_offset(24 * 3 + 16 * 2 + 15);
        }];
    }
    return self;
}

#pragma mark - setter and getter

-(void)setModel:(OSSVTimeDownCCellModel *)model
{
    if (model == _model) return;
    _model = model;
    
    if ([_model.dataSource isKindOfClass:[OSSVSecondsKillsModel class]]) {
        OSSVSecondsKillsModel *killModel = (OSSVSecondsKillsModel *)_model.dataSource;
        [model.countDown deleteTimeLabel:self.countDownLabel];
        NSInteger time = killModel.timing.integerValue;
        ///拿到天数
        NSString *str_day = [NSString stringWithFormat:@"%ld",(NSInteger)time/86400];
        if (str_day.integerValue > 0) {
            //加一个 X D
            self.iconLabel.text = STLLocalizedString_(@"endIn", nil);
            NSString *XD = [NSString stringWithFormat:@"%@D", str_day];
            NSMutableAttributedString *iconDay = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", self.iconLabel.text, XD]];
            NSRange dayRange = [iconDay.string rangeOfString:XD];
            [iconDay addAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]} range:dayRange];
            self.iconLabel.attributedText = iconDay;
        }
        [model.countDown addTimeLabel:self.countDownLabel time:[NSString stringWithFormat:@"%ld", time]];
    }
}

-(UIView *)countView
{
    if (!_countView) {
        _countView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = self.backgroundColor;
            view;
        });
    }
    return _countView;
}

-(UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"flash"];
            imageView;
        });
    }
    return _iconImageView;
}

-(UILabel *)iconLabel {
    if (!_iconLabel) {
        _iconLabel = [[UILabel alloc] init];
        _iconLabel.text = STLLocalizedString_(@"endIn", nil);
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        _iconLabel.textColor = [UIColor blackColor];
        _iconLabel.font = [UIFont systemFontOfSize:15];
    }
    return _iconLabel;
}

-(ZJJTimeCountDownLabel *)countDownLabel {
    if (!_countDownLabel) {
        _countDownLabel = [[ZJJTimeCountDownLabel alloc] init];
        _countDownLabel.font = [UIFont systemFontOfSize:12];
        _countDownLabel.textAdjustsWidthToFitFont = YES;
        _countDownLabel.textStyle = ZJJTextStlyeHHMMSSBox;
        _countDownLabel.textColor = [UIColor whiteColor];
        _countDownLabel.textHeight = 24;
        _countDownLabel.textWidth = 24;
        _countDownLabel.textBackgroundColor = [UIColor blackColor];
        _countDownLabel.textBackgroundInterval = 16;
        _countDownLabel.textBackgroundRadius = 2;
        _countDownLabel.textIntervalSymbol = @":";
        _countDownLabel.textIntervalSymbolColor = [UIColor blackColor];
        _countDownLabel.textAlignment = NSTextAlignmentCenter;
        _countDownLabel.isRetainFinalValue = YES;
    }
    return _countDownLabel;
}

@end
