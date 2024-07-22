//
//  ZFAppUpgradeView.m
//  ZZZZZ
//
//  Created by YW on 2018/12/22.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFAppUpgradeView.h"
#import "ZFInitViewProtocol.h"
#import "ZFUpgradeModel.h"
#import "NSDate+ZFExtension.h"
#import "UIView+ZFViewCategorySet.h"
#import "NSString+Extended.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

typedef void(^UpgradeAppBlock)(void);
typedef void(^UpgradeCloseBlock)(void);

@interface ZFAppUpgradeView () <ZFInitViewProtocol, UITextViewDelegate>
@property (nonatomic, strong) ZFUpgradeModel        *upgradeModel;
@property (nonatomic, copy) UpgradeAppBlock         upgradeAppBlock;
@property (nonatomic, copy) UpgradeCloseBlock       upgradeCloseBlock;
@property (nonatomic, strong) UIView                *contentView;
@property (nonatomic, strong) YYAnimatedImageView   *bannerImageView;
@property (nonatomic, strong) UIButton              *closeButtom;
@property (nonatomic, strong) UILabel               *titleLel;
@property (nonatomic, strong) UILabel               *subTitleLel;
@property (nonatomic, strong) UITextView            *descTextView;
@property (nonatomic, strong) UIButton              *upgradeButtom;
@property (nonatomic, assign) BOOL                  isForcedUpgrade;
@end

@implementation ZFAppUpgradeView

+ (void)showUpgradeView:(ZFUpgradeModel *)upgradeModel
        upgradeAppBlock:(void(^)(void))upgradeAppBlock
      upgradeCloseBlock:(void(^)(void))upgradeCloseBlock
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    //防止走两次
    UIView *oldAdvertView = [window viewWithTag:kZFAppUpgradeViewTag];
    if (oldAdvertView && [oldAdvertView isKindOfClass:[ZFAppUpgradeView class]]) {
        [oldAdvertView removeFromSuperview];
    }
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    ZFAppUpgradeView *upgradeView = [[ZFAppUpgradeView alloc] initWithFrame:screenRect upgradeModel:upgradeModel];
    upgradeView.tag = kZFAppUpgradeViewTag;
    upgradeView.upgradeAppBlock = upgradeAppBlock;
    upgradeView.upgradeCloseBlock = upgradeCloseBlock;
    [window addSubview:upgradeView];
    
    NSMutableDictionary *upgradeShowDict = [NSMutableDictionary dictionary];
    upgradeShowDict[kUpgradeShowVersion] = ZFToString(ZFSYSTEM_VERSION);
    upgradeShowDict[kUpgradeShowDate] = ZFToString([NSDate todayDateString]);
    upgradeShowDict[kUpgradeShowTimes] = @(1);
    SaveUserDefault(kAppUpgradeDataKey, upgradeShowDict);
}

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame upgradeModel:(ZFUpgradeModel *)upgradeModel {
    self = [super initWithFrame:frame];
    if (self) {
        //是否强制更新 1 是 0 不是, 非强制更新才显示关闭按钮
        self.isForcedUpgrade = [upgradeModel.is_forced isEqualToString:@"1"];
        [self zfInitView];
        [self zfAutoLayoutView];
        
        // 放到后用sett方法复制,防止提前加载约束崩溃
        self.upgradeModel = upgradeModel;
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.bannerImageView];
    [self.contentView addSubview:self.titleLel];
    [self.contentView addSubview:self.subTitleLel];
    [self.contentView addSubview:self.descTextView];
    [self.contentView addSubview:self.upgradeButtom];
    
    //是否强制更新 1 是 0 不是, 非强制更新才显示关闭按钮
    if (!self.isForcedUpgrade) {
        [self.contentView addSubview:self.closeButtom];
    }
}

- (void)zfAutoLayoutView {
    CGFloat offsetY = 47;
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY).offset(offsetY/2);
        make.width.mas_equalTo(self.mas_width).multipliedBy(270/KScreenWidth);
    }];
    
    [self.bannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(-offsetY);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(134);
    }];
    
    [self.titleLel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bannerImageView.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.contentView).offset(16);
        make.trailing.mas_equalTo(self.contentView).offset(-16);
    }];
    
    [self.subTitleLel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLel.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.contentView).offset(16);
        make.trailing.mas_equalTo(self.contentView).offset(-16);
    }];
    
    [self.descTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(26);
        make.trailing.mas_equalTo(self.contentView).offset(-26);
        make.top.mas_equalTo(self.subTitleLel.mas_bottom).offset(14);
        make.height.mas_equalTo(130);
    }];
    
    [self.upgradeButtom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.top.mas_equalTo(self.descTextView.mas_bottom).offset(12);
        make.size.mas_equalTo(CGSizeMake(239, 40));
        if (self.isForcedUpgrade) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        }
    }];
    
    if (!self.isForcedUpgrade) {
        [self.closeButtom mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.upgradeButtom.mas_bottom).offset(12);
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
            make.size.mas_equalTo(CGSizeMake(239, 44));
        }];
    }
}

/**
 * 更新信息
 */
- (void)setUpgradeModel:(ZFUpgradeModel *)upgradeModel {
    _upgradeModel = upgradeModel;
    
    [self.bannerImageView yy_setImageWithURL:[NSURL URLWithString:upgradeModel.image]
                                 placeholder:ZFImageWithName(@"Upgrade_banner")
                                     options:YYWebImageOptionAvoidSetImage
                                  completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                      if (image && stage == YYWebImageStageFinished) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              self.bannerImageView.image = image;
                                              [self.bannerImageView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(8, 8)];
                                          });                                          
                                      }
                                  }];
    
    NSString *title = ZFToString(upgradeModel.title);
    if (ZFIsEmptyString(title)) {
        title = @"There are new versions to upgrade";
    }
    self.titleLel.text = title;
    
    
    NSString *subTitle = ZFToString(upgradeModel.msg);
    if (ZFIsEmptyString(subTitle)) {
        subTitle = @"99% of users have upgraded";
    }
    self.subTitleLel.text = subTitle;
    
    
    NSString *descText = ZFToString(upgradeModel.upgradeDesc);
    if (ZFIsEmptyString(descText)) {
        descText = ZFLocalizedString(@"ForceUpgrade_message",nil);
        //ZFLocalizedString(@"SettingViewModel_Version_Alert_Message",nil);
    }
    
    CGSize size = [descText textSizeWithFont:ZFFontSystemSize(14) constrainedToSize:CGSizeMake((KScreenWidth-52*2), MAXFLOAT) lineBreakMode:(NSLineBreakByWordWrapping)];
    CGFloat textViewHeight = size.height + 30;
    if (textViewHeight > 130) {
        textViewHeight = 130;
    }
    [self.descTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textViewHeight);
    }];
    self.descTextView.text = descText;
}

#pragma mark - UITextViewDelegate

// 禁止弹出复制, 放大, 等操作
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return NO;
}

#pragma mark - Init View

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 8;
        //_contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (YYAnimatedImageView *)bannerImageView {
    if (!_bannerImageView) {
        _bannerImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _bannerImageView.backgroundColor = [UIColor clearColor];
        _bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bannerImageView.userInteractionEnabled = YES;
    }
    return _bannerImageView;
}

- (UILabel *)titleLel {
    if (!_titleLel) {
        _titleLel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLel.font = [UIFont systemFontOfSize:14];
        _titleLel.textColor = ZFCOLOR(45, 45, 45, 1);
        _titleLel.textAlignment = NSTextAlignmentCenter;
        _titleLel.numberOfLines = 2;
    }
    return _titleLel;
}

- (UILabel *)subTitleLel {
    if (!_subTitleLel) {
        _subTitleLel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subTitleLel.textAlignment = NSTextAlignmentCenter;
        _subTitleLel.textColor = ZFCOLOR(207, 101, 36, 1);
        _subTitleLel.font = [UIFont systemFontOfSize:14];
        _subTitleLel.textAlignment = NSTextAlignmentCenter;
        _subTitleLel.numberOfLines = 2;
    }
    return _subTitleLel;
}

- (UITextView *)descTextView {
    if (!_descTextView) {
        _descTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        _descTextView.textColor = ZFCOLOR(102, 102, 102, 1.f);
        _descTextView.font = [UIFont systemFontOfSize:12];
        _descTextView.directionalLockEnabled = YES;
        _descTextView.showsVerticalScrollIndicator = YES;
//        _descTextView.editable = NO;
        _descTextView.delegate = self;
        //设置需要识别的类型，这设置的是全部
        _descTextView.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;
    }
    return _descTextView;
}

- (UIButton *)upgradeButtom {
    if (!_upgradeButtom) {
        _upgradeButtom = [UIButton buttonWithType:UIButtonTypeCustom];
        [_upgradeButtom setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_upgradeButtom addTarget:self action:@selector(upgradeAction:) forControlEvents:UIControlEventTouchUpInside];
        _upgradeButtom.backgroundColor = ZFC0x2D2D2D();
        [_upgradeButtom setTitle:ZFLocalizedString(@"Upgrade_Now", nil) forState:0];
        _upgradeButtom.titleLabel.font = ZFFontBoldSize(16);
        _upgradeButtom.layer.cornerRadius = 3;
        _upgradeButtom.layer.masksToBounds = YES;
    }
    return _upgradeButtom;
}

- (UIButton *)closeButtom {
    if (!_closeButtom) {
        _closeButtom = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButtom addTarget:self action:@selector(closeButtomAction:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButtom setTitle:ZFLocalizedString(@"Push_Later", nil) forState:0];
        [_closeButtom setTitleColor:ZFCOLOR(153, 153, 153, 1) forState:UIControlStateNormal];
        _closeButtom.titleLabel.font = ZFFontBoldSize(16);
    }
    return _closeButtom;
}

- (void)closeButtomAction:(UIButton *)buttom {
    if (self.upgradeCloseBlock) {
        self.upgradeCloseBlock();
    }
    [self removeFromSuperview];
}

- (void)upgradeAction:(UIButton *)buttom {
    if (self.upgradeAppBlock) {
        self.upgradeAppBlock();
    }
    //非强制更新时关闭当前弹框
    if (ZFIsEmptyString(self.upgradeModel.is_forced) || [self.upgradeModel.is_forced isEqualToString:@"0"]) {
        [self removeFromSuperview];
    }
}

@end
