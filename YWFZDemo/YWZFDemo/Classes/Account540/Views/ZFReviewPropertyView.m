//
//  ZFReviewPropertyView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFReviewPropertyView.h"
#import "ZFSubmitSelectView.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFOrderSizeModel.h"
#import "YSAlertView.h"
#import "SystemConfigUtils.h"
#import <Masonry/Masonry.h>
#import "ZFThemeManager.h"
#import "UIImage+ZFExtended.h"

@interface ZFReviewPropertyView ()
@property (nonatomic, strong) UILabel            *tipsLabel;
@property (nonatomic, strong) ZFSubmitSelectView *selectHeight;
@property (nonatomic, strong) ZFSubmitSelectView *selectWaist;
@property (nonatomic, strong) ZFSubmitSelectView *selectHips;
@property (nonatomic, strong) ZFSubmitSelectView *selectBustSize;
@property (nonatomic, strong) UIButton           *publicInfoButton;
@property (nonatomic, strong) UIButton           *tipsButton;
//@property (nonatomic, strong) UILabel            *publicTipsLabel;
@end

@implementation ZFReviewPropertyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.tipsLabel];
    self.tipsLabel.preferredMaxLayoutWidth = KScreenWidth - 16*2;
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.leading.mas_equalTo(self.mas_leading);
        make.trailing.mas_equalTo(self.mas_trailing);
    }];
    
    [self addSubview:self.selectHeight];
    [self.selectHeight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipsLabel.mas_bottom).offset(13);
        make.leading.mas_equalTo(self.tipsLabel.mas_leading);
        make.size.mas_equalTo(CGSizeMake((KScreenWidth-16*2-13)/2, 36));
    }];
    
    [self addSubview:self.selectWaist];
    [self.selectWaist mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.selectHeight.mas_top);
        make.leading.mas_equalTo(self.selectHeight.mas_trailing).offset(13);
        make.size.mas_equalTo(self.selectHeight);
    }];
    
    [self addSubview:self.selectHips];
    [self.selectHips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.selectHeight.mas_bottom).offset(13);
        make.leading.mas_equalTo(self.tipsLabel.mas_leading);
        make.size.mas_equalTo(self.selectHeight);
    }];
    
    [self addSubview:self.selectBustSize];
    [self.selectBustSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.selectHips.mas_top);
        make.leading.mas_equalTo(self.selectHips.mas_trailing).offset(13);
        make.size.mas_equalTo(self.selectHeight);
        //make.bottom.mas_equalTo(self.mas_bottom).offset(-16);
    }];
    
    [self addSubview:self.publicInfoButton];
    [self.publicInfoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.selectHips.mas_bottom).offset(14);
        make.leading.mas_equalTo(self.selectHips.mas_leading);
        make.height.mas_offset(25);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-16);
    }];
    
    [self addSubview:self.tipsButton];
    [self.tipsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.publicInfoButton.mas_trailing).offset(8);
        make.centerY.mas_equalTo(self.publicInfoButton);
    }];
    
//    [self addSubview:self.publicTipsLabel];
//    [self.publicTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.publicInfoButton.mas_bottom).offset(8);
//        make.leading.mas_equalTo(self.publicInfoButton.mas_leading);
//        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
//        make.bottom.mas_equalTo(self.mas_bottom).offset(-16);
//    }];
}

#pragma mark - public method

- (void)setContent:(NSString *)content sizeId:(NSString *)sizeId withType:(ZFReviewPropertyType)type;
{
    switch (type) {
        case ZFReviewPropertyType_Hips:
            self.selectHips.title = content;
            self.selectHips.sizeId = sizeId;
            break;
        case ZFReviewPropertyType_Waist:
            self.selectWaist.title = content;
            self.selectWaist.sizeId = sizeId;
            break;
        case ZFReviewPropertyType_Height:
            self.selectHeight.title = content;
            self.selectHeight.sizeId = sizeId;
            break;
        case ZFReviewPropertyType_BustSize:
            self.selectBustSize.title = content;
            self.selectBustSize.sizeId = sizeId;
            break;
        default:
            break;
    }
}

- (void)reloadSelectItemStatus:(ZFReviewPropertyType)type
{
    switch (type) {
        case ZFReviewPropertyType_Hips:
            [self.selectHips reloadArrowStatus];
            break;
        case ZFReviewPropertyType_Waist:
            [self.selectWaist reloadArrowStatus];
            break;
        case ZFReviewPropertyType_Height:
            [self.selectHeight reloadArrowStatus];
            break;
        case ZFReviewPropertyType_BustSize:
            [self.selectBustSize reloadArrowStatus];
            break;
        default:
            break;
    }
}

- (NSDictionary *)selectBodySize {
    return @{
             @"height"  : ZFToString(self.selectHeight.sizeId),
             @"bust"    : ZFToString(self.selectBustSize.sizeId),
             @"waist"   : ZFToString(self.selectWaist.sizeId),
             @"hips"    : ZFToString(self.selectHips.sizeId),
             @"is_save" : @(self.publicInfoButton.selected),
             };
}

- (BOOL)setDefaultValue:(NSArray<NSArray <ZFOrderSizeModel *> *> *)defaultValue {
    BOOL hasSelected = NO;
    for (int i = 0; i < [defaultValue count]; i++) {
        NSArray <ZFOrderSizeModel *> *list = defaultValue[i];
        for (int j = 0; j < list.count; j++) {
            ZFOrderSizeModel *sizeModel = list[j];
            if (sizeModel.is_select) {
                hasSelected = YES;
                ZFSubmitSelectView *selectView = [self viewWithTag:i + 100];
                if (selectView) {
                    selectView.title = sizeModel.name;
                    selectView.sizeId = sizeModel.sizeId;
                }
                break;
            }
        }
    }
    self.tipsLabel.hidden = hasSelected;//选择过就不在提示送积分
    if (hasSelected) {
        [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    return hasSelected;
}

///获取title
- (NSString *)gainTitleWithType:(ZFReviewPropertyType)type
{
    switch (type) {
        case ZFReviewPropertyType_Hips:
            return ZFLocalizedString(@"Hips", nil);
            break;
        case ZFReviewPropertyType_Waist:
            return ZFLocalizedString(@"Waist", nil);
            break;
        case ZFReviewPropertyType_Height:
            return ZFLocalizedString(@"Height", nil);
            break;
        case ZFReviewPropertyType_BustSize:
            return ZFLocalizedString(@"Bust Size", nil);
            break;
        default:
            break;
    }
}

- (void)tipsButtonAction {
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

- (void)publicInfoBtnAction:(UIButton *)button {
    self.publicInfoButton.selected = !self.publicInfoButton.selected;
    if (self.publicInfoButton.selected) {
        //颜色正常
        self.selectHeight.enable = YES;
        self.selectHips.enable = YES;
        self.selectWaist.enable = YES;
        self.selectBustSize.enable = YES;
    } else { //置灰
        self.selectHeight.enable = NO;
        self.selectHips.enable = NO;
        self.selectWaist.enable = NO;
        self.selectBustSize.enable = NO;
    }
    BOOL canTap = self.publicInfoButton.selected;
    self.selectHeight.userInteractionEnabled = canTap;
    self.selectHips.userInteractionEnabled = canTap;
    self.selectWaist.userInteractionEnabled = canTap;
    self.selectBustSize.userInteractionEnabled = canTap;
}

- (void)configurateExtrePoint:(NSAttributedString *)attr {
    if (attr) {
        self.tipsLabel.attributedText = attr;
    }
}

#pragma mark - target

- (void)tapProperty:(UIGestureRecognizer *)sender {
    if (self.selectedPropertyHandler) {
        self.selectedPropertyHandler(self, sender.view.tag - 100);
    }
}

#pragma mark - private method

- (ZFSubmitSelectView *)createWithPlaceHolder:(NSString *)placeHolder tag:(NSInteger)tag
{
    ZFSubmitSelectView *selectView = [[ZFSubmitSelectView alloc] init];
    selectView.placeHold = placeHolder;
    selectView.tag = tag + 100;
    selectView.clipsToBounds = YES;
    selectView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProperty:)];
    [selectView addGestureRecognizer:tap];
    return selectView;
}

#pragma mark - Property

- (ZFSubmitSelectView *)selectHeight
{
    if (!_selectHeight) {
        _selectHeight = [self createWithPlaceHolder:[self gainTitleWithType:ZFReviewPropertyType_Height] tag:0];
    }
    return _selectHeight;
}

- (ZFSubmitSelectView *)selectWaist
{
    if (!_selectWaist) {
        _selectWaist = [self createWithPlaceHolder:[self gainTitleWithType:ZFReviewPropertyType_Waist] tag:1];
    }
    return _selectWaist;
}

- (ZFSubmitSelectView *)selectHips
{
    if (!_selectHips) {
        _selectHips = [self createWithPlaceHolder:[self gainTitleWithType:ZFReviewPropertyType_Hips] tag:2];
    }
    return _selectHips;
}

- (ZFSubmitSelectView *)selectBustSize {
    if (!_selectBustSize) {
        _selectBustSize = [self createWithPlaceHolder:[self gainTitleWithType:ZFReviewPropertyType_BustSize] tag:3];
    }
    return _selectBustSize;
}

-(UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.numberOfLines = 3;
        _tipsLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _tipsLabel.font = [UIFont systemFontOfSize:14];
        _tipsLabel.numberOfLines = 0;
    }
    return _tipsLabel;
}

-(UIButton *)publicInfoButton {
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
        [_publicInfoButton addTarget:self action:@selector(publicInfoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _publicInfoButton.selected = YES;
    }
    return _publicInfoButton;
}

-(UIButton *)tipsButton {
    if (!_tipsButton) {
        _tipsButton = [[UIButton alloc] init];
        [_tipsButton addTarget:self action:@selector(tipsButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_tipsButton setImage:[UIImage imageNamed:@"nationalID"] forState:UIControlStateNormal];
    }
    return _tipsButton;
}

//-(UILabel *)publicTipsLabel {
//    if (!_publicTipsLabel) {
//        _publicTipsLabel = [[UILabel alloc] init];
//        _publicTipsLabel.numberOfLines = 3;
//        _publicTipsLabel.textColor = ZFC0x999999();
//        _publicTipsLabel.font = [UIFont systemFontOfSize:12];
//        _publicTipsLabel.text = ZFLocalizedString(@"Reviews_SubmitInfo2Poinst", nil);
//    }
//    return _publicTipsLabel;
//}

@end
