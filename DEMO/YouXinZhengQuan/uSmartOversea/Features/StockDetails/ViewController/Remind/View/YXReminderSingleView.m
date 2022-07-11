//
//  YXReminderSingleView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXReminderSingleView.h"
#import "YXReminderModel.h"
#import "YXRemindTool.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXReminderSingleCell ()

@property (nonatomic, strong) YXReminderSingleView *detailView;

@end

@implementation YXReminderSingleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    self.backgroundColor = QMUITheme.foregroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.detailView];
    [self.detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}


- (void)setModel:(YXReminderModel *)model {
    _model = model;
    self.detailView.model = model;
}

- (void)setStChangeCallBack:(void (^)(UISwitch * _Nonnull))stChangeCallBack {
    _stChangeCallBack = stChangeCallBack;
    self.detailView.stChangeCallBack = stChangeCallBack;
}

- (YXReminderSingleView *)detailView {
    if (_detailView == nil) {
        _detailView = [[YXReminderSingleView alloc] init];
        _detailView.isMyRemind = NO;
    }
    return _detailView;
}


@end



@interface YXReminderSingleView ()

//@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *valueLabel;

@property (nonatomic, strong) UILabel *notiLabel;

@property (nonatomic, strong) UISwitch *st;

@property (nonatomic, strong) QMUILabel *statusLabel;

@end

@implementation YXReminderSingleView


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
    
//    self.iconImageView = [[UIImageView alloc] init];
    self.nameLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:16]];
    self.nameLabel.adjustsFontSizeToFitWidth = true;
    self.nameLabel.minimumScaleFactor = 0.3;
    self.valueLabel = [UILabel labelWithText:@"" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:16]];
    self.notiLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:12]];    
    self.statusLabel = [QMUILabel labelWithText:[YXLanguageUtility kLangWithKey:@"remind_close"] textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:10]];
    self.statusLabel.layer.cornerRadius = 1;
    self.statusLabel.layer.borderWidth = 1;
    self.statusLabel.layer.borderColor = [QMUITheme.textColorLevel1 colorWithAlphaComponent:0.3].CGColor;
    self.statusLabel.clipsToBounds = YES;
    self.statusLabel.contentEdgeInsets = UIEdgeInsetsMake(2, 8, 2, 8);
    
    self.st = [[UISwitch alloc] init];
    self.st.onTintColor = QMUITheme.themeTextColor;
    
    self.st.hidden = YES;
    self.statusLabel.hidden = YES;
    
//    [self addSubview:self.iconImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.valueLabel];
    [self addSubview:self.notiLabel];
    [self addSubview:self.st];
    [self addSubview:self.statusLabel];
    
//    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(12);
//        make.centerY.equalTo(self);
//        make.width.height.mas_equalTo(20);
//    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.top.equalTo(self).offset(16);
        make.height.mas_equalTo(19);
    }];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).offset(6);
        make.centerY.equalTo(self.nameLabel);
        make.right.lessThanOrEqualTo(self.st.mas_left).offset(-10);
    }];
    
    [self.notiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(14);
    }];
    
    [self.st mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-12);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.valueLabel.mas_right).offset(10);
    }];
    
    [self.nameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.valueLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    @weakify(self);
    [[self.st rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        if (self.stChangeCallBack) {
            self.stChangeCallBack(x);
        }
    }];
}

- (void)setModel:(YXReminderModel *)model {
    _model = model;
    
    self.notiLabel.text = model.notifyStr;
    
    if (model.ntfType > 0) {
        self.nameLabel.text = [YXRemindTool getTitleWithType:model.ntfType];
//        self.iconImageView.image = [UIImage imageNamed:[YXRemindTool getImageNameWithType:model.ntfType]];
        int a = [YXRemindTool getUnitWithType:model.ntfType];
        self.valueLabel.text = [NSString stringWithFormat:@"%@ %@", [YXRemindTool formatFloat:(model.ntfValue.doubleValue / a) andType:model.ntfType] , [YXRemindTool getUnitStrWithType:model.ntfType]];
    } else {
        self.nameLabel.text = [YXRemindTool getTitleWithType:model.formShowType];
//        self.iconImageView.image = [UIImage imageNamed:[YXRemindTool getImageNameWithType:model.formShowType]];
        self.valueLabel.text = @"";
    }
    
    if (self.isMyRemind) {
        if (model.status == 1) {
            self.statusLabel.hidden = YES;
            self.nameLabel.textColor = QMUITheme.textColorLevel1;
            self.valueLabel.textColor = QMUITheme.textColorLevel1;
        } else {
            self.nameLabel.textColor = QMUITheme.textColorLevel3;
            self.valueLabel.textColor = QMUITheme.textColorLevel3;
            self.statusLabel.hidden = NO;
        }
    } else {
        self.st.on = model.status == 1;
    }
}

- (void)setIsMyRemind:(BOOL)isMyRemind {
    _isMyRemind = isMyRemind;
    self.st.hidden = isMyRemind;
    self.statusLabel.hidden = !isMyRemind;
}

@end
