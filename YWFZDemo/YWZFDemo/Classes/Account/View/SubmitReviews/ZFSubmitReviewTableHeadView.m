//
//  ZFSubmitReviewTableHeadView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFSubmitReviewTableHeadView.h"
#import "ZFSubmitSelectView.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFOrderSizeModel.h"
#import "YSAlertView.h"
#import "SystemConfigUtils.h"
#import <Masonry/Masonry.h>
#import "UIImage+ZFExtended.h"

@interface ZFSubmitReviewTableHeadView ()

@property (nonatomic, strong) ZFSubmitSelectView *selectHeight;
@property (nonatomic, strong) ZFSubmitSelectView *selectWaist;
@property (nonatomic, strong) ZFSubmitSelectView *selectHips;
@property (nonatomic, strong) ZFSubmitSelectView *selectBustSize;

@property (nonatomic, strong) UIButton *publicInfoButton;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIButton *tipsButton;

@end

@implementation ZFSubmitReviewTableHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initUI];
    }
    
    return self;
}

- (void)initUI
{
    [self addSubview:self.selectHeight];
    [self addSubview:self.selectWaist];
    [self addSubview:self.selectHips];
    [self addSubview:self.selectBustSize];
    [self addSubview:self.publicInfoButton];
    [self addSubview:self.tipsButton];
    [self addSubview:self.tipsLabel];
    
    [self.selectHeight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
        make.trailing.mas_equalTo(self.selectWaist.mas_leading).mas_offset(-13);
        make.top.mas_equalTo(self.mas_top).mas_offset(16);
        make.height.mas_offset(36);
    }];
    
    [self.selectWaist mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.selectHeight.mas_trailing).mas_offset(-13);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
        make.top.mas_equalTo(self.selectHeight);
        make.width.mas_equalTo(self.selectHeight);
        make.height.mas_offset(36);
    }];
    
    [self.selectHips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.selectHeight.mas_bottom).mas_offset(12);
        make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
        make.trailing.mas_equalTo(self.selectBustSize.mas_leading).mas_offset(-13);
        make.width.mas_equalTo(self.selectHeight);
        make.height.mas_offset(36);
    }];
    
    [self.selectBustSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.selectHips);
        make.leading.mas_equalTo(self.selectHips.mas_trailing).mas_offset(-13);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
        make.width.mas_equalTo(self.selectHeight);
        make.height.mas_offset(36);
    }];
    
    [self.publicInfoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.selectHips.mas_bottom).mas_offset(16);
        make.leading.mas_equalTo(self.selectHips.mas_leading);
        make.height.mas_offset(25);
    }];
    
    [self.tipsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.publicInfoButton.mas_trailing).mas_offset(8);
        make.centerY.mas_equalTo(self.publicInfoButton);
    }];
    
    self.tipsLabel.preferredMaxLayoutWidth = KScreenWidth - 32;
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.publicInfoButton.mas_bottom).mas_offset(8);
        make.leading.mas_equalTo(self.publicInfoButton.mas_leading);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
//        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-10);
    }];
}

#pragma mark - public method

- (void)setContent:(NSString *)content sizeId:(NSString *)sizeId withType:(UserPropertyType)type;
{
    switch (type) {
        case UserPropertyType_Hips:
            self.selectHips.title = content;
            self.selectHips.sizeId = sizeId;
            break;
        case UserPropertyType_Waist:
            self.selectWaist.title = content;
            self.selectWaist.sizeId = sizeId;
            break;
        case UserPropertyType_Height:
            self.selectHeight.title = content;
            self.selectHeight.sizeId = sizeId;
            break;
        case UserPropertyType_BustSize:
            self.selectBustSize.title = content;
            self.selectBustSize.sizeId = sizeId;
            break;
        default:
            break;
    }
}

- (void)reloadSelectItemStatus:(UserPropertyType)type
{
    switch (type) {
        case UserPropertyType_Hips:
            [self.selectHips reloadArrowStatus];
            break;
        case UserPropertyType_Waist:
            [self.selectWaist reloadArrowStatus];
            break;
        case UserPropertyType_Height:
            [self.selectHeight reloadArrowStatus];
            break;
        case UserPropertyType_BustSize:
            [self.selectBustSize reloadArrowStatus];
            break;
        default:
            break;
    }
}

- (NSDictionary *)selectBodySize
{
    return @{
             @"height" : ZFToString(self.selectHeight.sizeId),
             @"bust" : ZFToString(self.selectBustSize.sizeId),
             @"waist" : ZFToString(self.selectWaist.sizeId),
             @"hips" : ZFToString(self.selectHips.sizeId),
             @"is_save" : @(self.publicInfoButton.selected),
             };
}

- (void)setDefaultValue:(NSArray<NSArray <ZFOrderSizeModel *> *> *)defaultValue
{
    for (int i = 0; i < [defaultValue count]; i++) {
        NSArray <ZFOrderSizeModel *> *list = defaultValue[i];
        for (int j = 0; j < list.count; j++) {
            ZFOrderSizeModel *sizeModel = list[j];
            if (sizeModel.is_select) {
                ZFSubmitSelectView *selectView = [self viewWithTag:i + 100];
                if (selectView) {
                    selectView.title = sizeModel.name;
                    selectView.sizeId = sizeModel.sizeId;
                }
                break;
            }
        }
    }
}

///获取title
- (NSString *)gainTitleWithType:(UserPropertyType)type
{
    switch (type) {
        case UserPropertyType_Hips:
            return ZFLocalizedString(@"Hips", nil);
            break;
        case UserPropertyType_Waist:
            return ZFLocalizedString(@"Waist", nil);
            break;
        case UserPropertyType_Height:
            return ZFLocalizedString(@"Height", nil);
            break;
        case UserPropertyType_BustSize:
            return ZFLocalizedString(@"Bust Size", nil);
            break;
        default:
            break;
    }
}

#pragma mark - target

- (void)tapProperty:(UIGestureRecognizer *)sender
{
    if (self.publicInfoButton.selected) {
        if (self.didClickPropertyHandler) {
            self.didClickPropertyHandler(self, sender.view.tag - 100);
        }
    }
}

- (void)tipsButtonAction
{
    NSString *title = ZFLocalizedString(@"Profile_Privacy", nil);
    NSString *message = ZFLocalizedString(@"Reviews_PrivacyContent", nil);
    NSString *messageOne = ZFLocalizedString(@"Reviews_PrivacyContentOne", nil);
    NSString *messageTwo = ZFLocalizedString(@"Reviews_PrivacyContentTwo", nil);
    NSString *messageThree = ZFLocalizedString(@"Reviews_PrivacyContentThree", nil);
    
    message = [NSString stringWithFormat:@"%@ \n\n· %@", message, messageOne];
    message = [NSString stringWithFormat:@"%@ \n\n· %@", message, messageTwo];
    message = [NSString stringWithFormat:@"%@ \n\n· %@", message, messageThree];
    message = [NSString stringWithFormat:@"%@ \n\n· %@", message, ZFLocalizedString(@"Review_SizeTips", nil)];
    NSString *okTitle = ZFLocalizedString(@"OK", nil);
    [YSAlertView alertWithTitle:title message:message cancelButtonTitle:okTitle cancelButtonBlock:nil otherButtonBlock:nil otherButtonTitles:nil, nil];
}

- (void)publicInfoButtonAction
{
    self.publicInfoButton.selected = !self.publicInfoButton.selected;
    if (self.publicInfoButton.selected) {
        //颜色正常
        self.selectHeight.enable = YES;
        self.selectHips.enable = YES;
        self.selectWaist.enable = YES;
        self.selectBustSize.enable = YES;
    } else {
        //置灰
        self.selectHeight.enable = NO;
        self.selectHips.enable = NO;
        self.selectWaist.enable = NO;
        self.selectBustSize.enable = NO;
    }
}

#pragma mark - private method

- (ZFSubmitSelectView *)createWithPlaceHolder:(NSString *)placeHolder tag:(NSInteger)tag
{
    ZFSubmitSelectView *selectView = [[ZFSubmitSelectView alloc] init];
    selectView.placeHold = placeHolder;
    selectView.tag = tag + 100;
    selectView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProperty:)];
    [selectView addGestureRecognizer:tap];
    return selectView;
}

#pragma mark - Property

- (ZFSubmitSelectView *)selectHeight
{
    if (!_selectHeight) {
        _selectHeight = [self createWithPlaceHolder:[self gainTitleWithType:UserPropertyType_Height] tag:0];
    }
    return _selectHeight;
}

- (ZFSubmitSelectView *)selectWaist
{
    if (!_selectWaist) {
        _selectWaist = [self createWithPlaceHolder:[self gainTitleWithType:UserPropertyType_Waist] tag:1];
    }
    return _selectWaist;
}

- (ZFSubmitSelectView *)selectHips
{
    if (!_selectHips) {
        _selectHips = [self createWithPlaceHolder:[self gainTitleWithType:UserPropertyType_Hips] tag:2];
    }
    return _selectHips;
}

- (ZFSubmitSelectView *)selectBustSize
{
    if (!_selectBustSize) {
        _selectBustSize = [self createWithPlaceHolder:[self gainTitleWithType:UserPropertyType_BustSize] tag:3];
    }
    return _selectBustSize;
}

-(UIButton *)publicInfoButton
{
    if (!_publicInfoButton) {
        _publicInfoButton = [[UIButton alloc] init];
        _publicInfoButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_publicInfoButton setImage:[UIImage imageNamed:@"default_no"] forState:UIControlStateNormal];
        [_publicInfoButton setImage:[UIImage imageNamed:@"default_ok"] forState:UIControlStateSelected];
        [_publicInfoButton setTitle:ZFLocalizedString(@"Reviews_SubmitInfo", nil) forState:UIControlStateNormal];
        [_publicInfoButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        if ([SystemConfigUtils isRightToLeftShow]) {
            [_publicInfoButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        } else {
            [_publicInfoButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -10)];
        }
        [_publicInfoButton addTarget:self action:@selector(publicInfoButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _publicInfoButton.selected = YES;
    }
    return _publicInfoButton;
}

-(UIButton *)tipsButton
{
    if (!_tipsButton) {
        _tipsButton = [[UIButton alloc] init];
        [_tipsButton addTarget:self action:@selector(tipsButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_tipsButton setImage:[UIImage imageNamed:@"nationalID"] forState:UIControlStateNormal];
    }
    return _tipsButton;
}

-(UILabel *)tipsLabel
{
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.numberOfLines = 3;
        _tipsLabel.textColor = ZFC0x999999();
        _tipsLabel.font = [UIFont systemFontOfSize:12];
        _tipsLabel.text = ZFLocalizedString(@"Reviews_SubmitInfo2Poinst", nil);
    }
    return _tipsLabel;
}

@end
