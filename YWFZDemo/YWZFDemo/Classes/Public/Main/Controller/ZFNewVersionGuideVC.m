//
//  ZFNewVersionGuideVC.m
//  BossBuy
//
//  Created by BB on 15/7/20.
//  Copyright (c) 2015年 fasionspring. All rights reserved.
//

#import "ZFNewVersionGuideVC.h"
#import "ZFInitViewProtocol.h"
#import "ZFNewVersionSettingVC.h"
#import <AVFoundation/AVFoundation.h> //需要导入框架
#import "ZFThemeManager.h"
#import "ZFNavigationController.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "NSString+Extended.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFLaunchAnimationView.h"
#import "ZFButton.h"
#import "ZFBTSManager.h"
#import "SystemConfigUtils.h"

@interface ZFNewVersionGuideVC () <ZFInitViewProtocol, UIScrollViewDelegate>
@property (nonatomic, strong) UIButton              *closeButton;
@property (nonatomic, strong) UIView                *contentView;
@property (nonatomic, strong) UIButton              *shopinButton;
@property (nonatomic, strong) UIButton              *goShoppingButton;
@property (nonatomic, strong) UIButton              *goLoginButton;
@property (nonatomic, strong) UIScrollView          *scrollView;
@property (nonatomic, strong) NSArray               *scrollViewSubViews;
@property (nonatomic, strong) NSArray<UIColor *>    *guideBgColorArr;
@property (nonatomic, strong) NSArray<UIImage *>    *guideImageArr;
@property (nonatomic, strong) NSArray<NSString *>   *guideTitleArr;
@property (nonatomic, strong) NSArray<NSString *>   *guideSubTitleArr;
@property (nonatomic, strong) UIPageControl         *pageControl;//老版本支持几张图滑动引导
@property (nonatomic, strong) UIButton              *registerButton;
@property (nonatomic, assign) BOOL                  hasChangeSetting;
@property (nonatomic, strong) AVPlayer              *player;

@property (nonatomic, strong) UIButton              *vkButton;
@property (nonatomic, strong) UIButton              *facebookButton;
@property (nonatomic, strong) UIButton              *googlePlusButton;
@property (nonatomic, strong) UILabel               *tipLabel;
@end

@implementation ZFNewVersionGuideVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifacation];

    // 首次安装时先显示启动动画
//    [ZFLaunchAnimationView showAnimationViewCompletion:^{
        [self playLocalVideoToView];
        [self initZfSubviews];
//    }];
}

- (void)initZfSubviews {
    [self zfInitView];
    [self zfAutoLayoutView];
    
    NSString *title = [self fetchCountryName];
    [self.shopinButton setAttributedTitle:[self fetchShopInButtonTitle:title] forState:UIControlStateNormal];
    
    [self reloadPages];
}

/**
 * 播放本地视屏
 */
- (void)playLocalVideoToView {
    // 防止启动时有些低性能的手机加载本地视频很慢，先设置一个背景图占位
    UIImage *launchImage = [UIImage imageNamed:getLaunchImageName()];
    if ([launchImage isKindOfClass:[UIImage class]]) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:launchImage];
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"new_version_guide_video" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    AVPlayer *player = [AVPlayer playerWithURL:url];    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    layer.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    [self.view.layer addSublayer:layer];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    player.volume = 0.0;
    [player play];
    self.player = player;
}

- (void)appDidBecomeActive {
    [self.player play];
}

/**
 *  播放完成后重复播放
 */
-(void)playbackFinished:(NSNotification *)notification {
    // 跳到最新的时间点开始播放
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self.player play];
}

#pragma mark -===========通知===========

- (void)addNotifacation {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCurrentCountryInfo:) name:kRefreshCountryExchangeInfo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

/**
 * 刷新当前国家信息
 */
- (void)refreshCurrentCountryInfo:(NSNotification *)notify {
    if (self.hasChangeSetting) return;
    NSString *title2 = [self fetchCountryName];
    NSAttributedString *shopInTitle = [self fetchShopInButtonTitle:title2];
    [self.shopinButton setAttributedTitle:shopInTitle forState:UIControlStateNormal];
    self.tipLabel.text = [NSString stringWithFormat:@"— %@ —",ZFLocalizedString(@"sign_in_with", nil)];
    [self.closeButton setTitle:ZFLocalizedString(@"Guide_Skip_Tips", nil) forState:UIControlStateNormal];
}

- (NSString *)fetchCountryName {
    NSString *countryName = nil;
    ZFInitializeModel *initializeModel = [AccountManager sharedManager].initializeModel;
    NSString *sign = @"";
    if (initializeModel) {
        ZFInitExchangeModel *exchange = initializeModel.exchange;
        if (exchange) {
            sign = ZFToString(exchange.sign);
        }
        ZFInitCountryInfoModel *countryInfo = initializeModel.countryInfo;
        if (countryInfo) {
            NSString *region_name = ZFToString(countryInfo.region_name);
            
            ZFInitExchangeModel *exchange = initializeModel.exchange;
            NSString *exchangeName = ZFToString(exchange.name);
            countryName = [NSString stringWithFormat:@"%@ %@ %@ | ",region_name, sign, exchangeName];
            
        }
        [self configurationRus:[ZFAddressCountryModel isRussiaCountryID:countryInfo.region_id]];
    } else {
        [self configurationRus:NO];
    }
    YWLog(@"刷新当前国家信息===%@", countryName);
    return countryName;
}

#pragma mark -===========ZFInitViewProtocol===========

/*!
 *  @brief 添加试图
 */
- (void)zfInitView {
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.scrollView];
    [self.contentView addSubview:self.pageControl];
    
    
    if (![AccountManager sharedManager].isSignIn) {
        [self.contentView addSubview:self.registerButton];
        [self.contentView addSubview:self.goLoginButton];
        [self.contentView addSubview:self.tipLabel];
        [self.contentView addSubview:self.vkButton];
        [self.contentView addSubview:self.facebookButton];
        [self.contentView addSubview:self.googlePlusButton];
    } else {
        [self.contentView addSubview:self.goShoppingButton];
    }
    [self.view addSubview:self.closeButton];
    [self.view bringSubviewToFront:self.closeButton];
    [self.contentView addSubview:self.shopinButton];
    [self.contentView bringSubviewToFront:self.shopinButton];
}

/*!
 *  @brief 布局
 */
- (void)zfAutoLayoutView {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    if (![AccountManager sharedManager].isSignIn) {
        
        [self.googlePlusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-24-kiphoneXHomeBarHeight);
            make.size.mas_equalTo(CGSizeMake(44, 44));
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
//            if ([SystemConfigUtils isRightToLeftShow]) {
//                make.centerX.mas_equalTo(self.contentView.mas_centerX).offset(40);
//            } else {
//                make.centerX.mas_equalTo(self.contentView.mas_centerX).offset(-40);
//            }
        }];
        
        [self.facebookButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.googlePlusButton.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(44, 44));
            make.leading.mas_equalTo(self.googlePlusButton.mas_trailing).offset(40);

            //            if ([SystemConfigUtils isRightToLeftShow]) {
            //                make.centerX.mas_equalTo(self.contentView.mas_centerX).offset(-40);
            //            } else {
            //                make.centerX.mas_equalTo(self.contentView.mas_centerX).offset(40);
            //            }
        }];
        
        [self.vkButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.googlePlusButton.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(44, 44));
            make.trailing.mas_equalTo(self.googlePlusButton.mas_leading).offset(-40);
        }];
        
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.googlePlusButton.mas_top).offset(-15);
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
        }];
        
        [self.goLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.height.mas_equalTo(40);
            make.bottom.mas_equalTo(self.tipLabel.mas_top).offset(-15);
        }];
        
        [self.registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.bottom.mas_equalTo(self.goLoginButton.mas_top).offset(-16);
            make.height.mas_equalTo(40);
        }];
        
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.registerButton.mas_top).offset(-16);
        }];
        
    } else {
        // 如果已经登录则只显示"继续购物按钮"
        self.goShoppingButton.backgroundColor = [UIColor whiteColor];
        [self.goShoppingButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateNormal];
        [self.goShoppingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-self.fetchiPhoneXOffset);
            make.height.mas_equalTo(40);
        }];
        
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.goShoppingButton.mas_top).offset(-16);
        }];
    }    
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.scrollView.mas_bottom).offset(-12);
        make.height.mas_equalTo(5);
    }];
    
    [self.shopinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((STATUSHEIGHT + 10));
        make.centerX.mas_equalTo(self.contentView);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(self.shopinButton.mas_top).offset(10);
        make.height.mas_equalTo(22);
        make.width.mas_greaterThanOrEqualTo(48);
    }];
}

- (void)configurationRus:(BOOL)isRus {
    
    if (![AccountManager sharedManager].isSignIn && self.vkButton.superview) {
        
        if (isRus) {
            self.vkButton.hidden = NO;
            [self.googlePlusButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-24-kiphoneXHomeBarHeight);
                make.size.mas_equalTo(CGSizeMake(44, 44));
                make.centerX.mas_equalTo(self.contentView.mas_centerX);
            }];
            
            [self.facebookButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.googlePlusButton.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(44, 44));
                make.leading.mas_equalTo(self.googlePlusButton.mas_trailing).offset(40);
            }];
            
        } else {
            self.vkButton.hidden = YES;
            [self.googlePlusButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-24-kiphoneXHomeBarHeight);
                make.size.mas_equalTo(CGSizeMake(44, 44));
                make.trailing.mas_equalTo(self.contentView.mas_centerX).offset(-20);
            }];
            
            [self.facebookButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.googlePlusButton.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(44, 44));
                make.leading.mas_equalTo(self.contentView.mas_centerX).offset(20);
            }];
        }
    }
}


- (CGFloat)fetchiPhoneXOffset {
    return (IPHONE_X_5_15 ? (kiphoneXHomeBarHeight + 16) : 16);
}

#pragma mark -===========引导图数据源===========

/**
 * 所有背景色
 */
- (NSArray<UIColor *> *)guideBgColorArr {
    if(!_guideBgColorArr){
        _guideBgColorArr = @[ColorHex_Alpha(0x0090ff, 1),
                             ColorHex_Alpha(0xff665d, 1),
                             ColorHex_Alpha(0x6173d0, 1)];
    }
    return _guideBgColorArr;
}

/**
 * 获取所有引导图片
 */
- (NSArray<UIImage *> *)guideImageArr {
//    if(!_guideImageArr){
//        NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
//        if (lang.length>2) {
//            lang = [lang substringWithRange:NSMakeRange(0, 2)];
//            if (lang) {
//                lang = [lang lowercaseString];
//            }
//        }
//        NSMutableArray *iamgeArr = [NSMutableArray array];
//        for (NSInteger i=0; i<3; i++) {
//            UIImage *pageImage = ZFImageWithName([NSString stringWithFormat:@"guide_Page_image_%@_%zd",lang, i]);
//            if ([pageImage isKindOfClass:[UIImage class]]) {
//                [iamgeArr addObject:pageImage];
//            }
//        }
//        _guideImageArr = iamgeArr;
//    }
    if (!_guideImageArr) {
        _guideImageArr = [NSArray array];
    }
    return _guideImageArr;
}

/**
 * 获取所有引导图片底部标题
 */
- (NSArray<NSString *> *)guideTitleArr {
    if(!_guideTitleArr){
        _guideTitleArr = @[ZFLocalizedString(@"Guide_Page1_Title",nil),
                           ZFLocalizedString(@"Guide_Page2_Title",nil),
                           ZFLocalizedString(@"Guide_Page3_Title",nil)];
    }
    return _guideTitleArr;
}

/**
 * 获取所有引导图片底部副标题
 */
- (NSArray<NSString *> *)guideSubTitleArr {
    if(!_guideSubTitleArr){
        _guideSubTitleArr = @[ZFLocalizedString(@"Guide_Page1_SubTitle",nil),
                              ZFLocalizedString(@"Guide_Page2_SubTitle",nil),
                              ZFLocalizedString(@"Guide_Page3_SubTitle",nil)];
    }
    return _guideSubTitleArr;
}

#pragma mark -===========加载引导图===========

/**
 * 加载引导图
 */
- (void)reloadPages {
/** V3.5.0
    if (self.guideImageArr.count != self.guideTitleArr.count ||
        self.guideImageArr.count != self.guideSubTitleArr.count ||
        self.guideImageArr.count != self.guideBgColorArr.count) {
        YWLog(@"异常处理: 图片, 标题, 副标题个数必须相等");

        //将启动图片设置为scrollView的背景图
        NSString *launchImageName = getLaunchImageName();
        UIImage * launchImage = [UIImage imageNamed:launchImageName];
        if ([launchImage isKindOfClass:[UIImage class]]) {
            self.scrollView.backgroundColor = [UIColor colorWithPatternImage:launchImage];
        }
        return;
    }
 */
//    if (self.guideImageArr.count == 0) {
//        YWLog(@"异常处理: 图片个数为空");
//        return;
//
//        //将启动图片设置为scrollView的背景图
//        NSString *launchImageName = getLaunchImageName();
//        UIImage * launchImage = [UIImage imageNamed:launchImageName];
//        if ([launchImage isKindOfClass:[UIImage class]]) {
//            self.scrollView.backgroundColor = [UIColor colorWithPatternImage:launchImage];
//        }
//        return;
//    }
//
//    self.pageControl.numberOfPages = self.guideImageArr.count;
//    self.pageControl.hidden = self.guideImageArr.count<=1 ? YES : NO;
//    self.scrollView.contentSize = [self contentSizeOfScrollView];
//
//    [[self scrollViewSubViews] enumerateObjectsUsingBlock:^(UIView *subPageView, NSUInteger idx, BOOL *stop) {
//        subPageView.x = KScreenWidth * idx;
//        [self.scrollView addSubview:subPageView];
//    }];
//
//    // fix enterButton can not presenting if ScrollView have only one page
//    if (self.pageControl.numberOfPages == 1) {
//        self.pageControl.alpha = 0;
//    }
//
//    // fix ScrollView can not scrolling if it have only one page
//    if (self.scrollView.contentSize.width == self.scrollView.frame.size.width) {
//        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width + 1, self.scrollView.contentSize.height);
//    }
}

- (CGSize)contentSizeOfScrollView {
    UIView *view = [[self scrollViewSubViews] firstObject];
    return CGSizeMake(view.frame.size.width * [self scrollViewSubViews].count, view.frame.size.height);
}

#pragma mark -===========点击事件===========

/**
 * Shop in
 */
- (void)shopinButtonAction:(UIButton *)sender {
    ZFNewVersionSettingVC *settingVC = [[ZFNewVersionSettingVC alloc] init];
    @weakify(self)
    settingVC.saveInfoBlock = ^(NSString *regionName, NSString *exchangeSignAndName, NSString *selectedLanguge) {
        @strongify(self)
        self.hasChangeSetting = YES;
        if (!ZFIsEmptyString(selectedLanguge)) {
            [self.contentView removeFromSuperview];
            self.contentView = nil;
            [self.shopinButton removeFromSuperview];
            self.shopinButton = nil;
            [self.goShoppingButton removeFromSuperview];
            self.goShoppingButton = nil;
            [self.goLoginButton removeFromSuperview];
            self.goLoginButton = nil;
            [self.scrollView removeFromSuperview];
            self.scrollView = nil;
            [self.pageControl removeFromSuperview];
            self.pageControl = nil;
            [self.registerButton removeFromSuperview];
            self.registerButton = nil;
            [self initZfSubviews];
        }
        NSString *title2 = [NSString stringWithFormat:@"%@ %@ | ", ZFToString(regionName), ZFToString(exchangeSignAndName)];
        [self.shopinButton setAttributedTitle:[self fetchShopInButtonTitle:title2] forState:UIControlStateNormal];
        self.tipLabel.text = [NSString stringWithFormat:@"— %@ —",ZFLocalizedString(@"sign_in_with", nil)];
        [self.closeButton setTitle:ZFLocalizedString(@"Guide_Skip_Tips", nil) forState:UIControlStateNormal];
    };
    ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:settingVC];
    [self presentViewController:nav animated:YES completion:nil];
}

/**
 * AB时左上角关闭按钮
 */
- (void)closeAtion:(UIButton *)sender {
    [self enterNextStep];
}

/**
 * 继续购物
 */
- (void)goShoppingButtonAction:(UIButton *)sender {
    NSString *signInTitle = ZFLocalizedString(@"SignIn_Button", nil);
    if ([sender.currentTitle isEqualToString:signInTitle]) {
        [self dealWithloginWithType:YWLoginEnterTypeLogin];
    } else {
        [self enterNextStep];
    }
}

/**
 * 点击登录
 */
- (void)loginButtonAction:(UIButton *)sender {
    [self dealWithloginWithType:YWLoginEnterTypeLogin];
}

/**
 * 点击注册按钮
 */
- (void)registerButtonAction:(UIButton *)sender {
    [self dealWithloginWithType:YWLoginEnterTypeRegister];
}

/**
 * 处理登录注册流程
 */
- (void)dealWithloginWithType:(YWLoginEnterType)loginEnterType {
    @weakify(self);
    [self judgePresentLoginVCChooseType:loginEnterType
                           comeFromType:YWLoginViewControllerEnterTypeGuidePage
                             Completion:^{
         @strongify(self);
         [self enterNextStep];
     }];
}

/**
 * 最后一页显示完成, 进入下一步回调
 */
- (void)enterNextStep {
    if (self.didFinishBlock) {
        self.didFinishBlock();
    }
}

- (void)facebookButtonAction:(UIButton *)sender {
    [self dealWithloginWithType:YWLoginEnterTypeFacebook];
}

- (void)vkontakteButtonAction:(UIButton *)sender {
    [self dealWithloginWithType:YWLoginEnterTypeVKontakte];
}


- (void)googleplusButtonAction:(UIButton *)sender {
    [self dealWithloginWithType:YWLoginEnterTypeGoogle];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.pageControl.currentPage = scrollView.contentOffset.x / (scrollView.contentSize.width / self.guideImageArr.count);
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].x < 0) {
        if (self.pageControl.numberOfPages <= (self.pageControl.currentPage + 1)) {
            [self enterNextStep];
        }
    }
}

#pragma mark - UIScrollView & UIPageControl DataSource

- (NSArray *)scrollViewSubViews {
    if (self.guideImageArr.count == 0) return nil;
    
    if (_scrollViewSubViews) {
        return _scrollViewSubViews;
    }
    NSMutableArray *tmpArray = [NSMutableArray new];

    [self.view layoutIfNeeded];
    CGFloat pageBgViewHeight = CGRectGetMaxY(self.scrollView.frame);
    
    if (pageBgViewHeight < 150) { //防止约束后获取Frame不准
        CGFloat bottomViewHeight = ([AccountManager sharedManager].isSignIn ? 60 : 152) + self.fetchiPhoneXOffset;
        pageBgViewHeight = KScreenHeight - bottomViewHeight;
    }
    
    //获取所有引导图的子视图, 每页子视图都有背景颜色, 图片, 标题, 副标题
    [self.guideImageArr enumerateObjectsUsingBlock:^(id image, NSUInteger idx, BOOL *stop) {
        
        UIView *pageBgView = [[UIView alloc] init];
        pageBgView.frame = CGRectMake(0, 0, KScreenWidth, pageBgViewHeight);
        
        //图片
        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, KScreenWidth, pageBgViewHeight);
        imageView.clipsToBounds = YES;
        [pageBgView addSubview:imageView];
        if (idx == 0) {
            imageView.contentMode = UIViewContentModeTop;
        } else {
            imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        
        
  /** V3.5.0 功能
   CGFloat pageTextSpace = 150.0;
   pageBgView.backgroundColor = self.guideBgColorArr[idx];
        
        //图片
        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        imageView.center = CGPointMake(pageBgView.width/2, pageBgView.height/2 - 30);
        [pageBgView addSubview:imageView];
        
        //标题
        UILabel *titleLabel = nil;
        if (self.guideTitleArr.count > idx) {
            titleLabel = [[UILabel alloc] init];
            titleLabel.frame = CGRectMake(20, pageBgView.height-pageTextSpace, KScreenWidth-20*2, 25);
            titleLabel.font = ZFFontBoldSize(20);
            titleLabel.numberOfLines = 2;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.textColor = ZFCOLOR_WHITE;
            titleLabel.text = self.guideTitleArr[idx];
            [pageBgView addSubview:titleLabel];
        }
        
        //副标题
        UILabel *subTitleLabel = nil;
        if (self.guideSubTitleArr.count > idx) {
            subTitleLabel = [[UILabel alloc] init];
            subTitleLabel.frame = CGRectMake(20, CGRectGetMaxY(titleLabel.frame), KScreenWidth-20*2, 70);
            subTitleLabel.font = ZFFontSystemSize(14);
            subTitleLabel.numberOfLines = 3;
            subTitleLabel.textAlignment = NSTextAlignmentCenter;
            subTitleLabel.textColor = ZFCOLOR_WHITE;
            subTitleLabel.text = self.guideSubTitleArr[idx];;
            [pageBgView addSubview:subTitleLabel];
        }
   */
        
        //装载子视图
        [tmpArray addObject:pageBgView];
    }];
    
    _scrollViewSubViews = tmpArray;
    return _scrollViewSubViews;
}

/**
 * Shop In 标题
 */
- (NSAttributedString *)fetchShopInButtonTitle:(NSString *)regionSignExchange {
    NSString *title1 = [NSString stringWithFormat:@"%@ \n", ZFLocalizedString(@"NewVersionGuide_ShopIn", nil)];
    NSString *title2 = @"United States , $ USD | ";
    NSString *title3 = ZFLocalizedString(@"NewVersionGuide_Change", nil);

    if (!ZFIsEmptyString(regionSignExchange)) {
        title2 = regionSignExchange;
    }
    NSArray *fontArr = @[ZFFontBoldSize(14),ZFFontSystemSize(12),ZFFontBoldSize(14)];
    NSMutableAttributedString *shopInTitle = [NSString getAttriStrByTextArray:@[title1, title2, title3]
                                                                      fontArr:fontArr
                                                                     colorArr:@[[UIColor whiteColor]]
                                                                  lineSpacing:0
                                                                    alignment:0];
    [shopInTitle addAttribute:NSUnderlineStyleAttributeName
                        value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                        range:NSMakeRange(shopInTitle.string.length-title3.length, title3.length)];
    
    NSShadow *shadow = [[NSShadow alloc]init];
    shadow.shadowBlurRadius = 3.0;
    shadow.shadowOffset = CGSizeMake(0, 0);
    shadow.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [shopInTitle addAttribute:NSShadowAttributeName
                        value:shadow
                        range:NSMakeRange(0, shopInTitle.string.length)];
    
    return shopInTitle;
}

/**
 * 登录标题
 */
- (NSAttributedString *)fetchSignInButtonTitle {
    NSString *signInTitle = ZFLocalizedString(@"SignIn_Button", nil);
    NSRange range = NSMakeRange(0, signInTitle.length);
    NSMutableAttributedString *titleAttr = [[NSMutableAttributedString alloc] initWithString:signInTitle];
    
    [titleAttr addAttribute:NSUnderlineStyleAttributeName
                        value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                        range:range];
    
    [titleAttr addAttribute:NSForegroundColorAttributeName
                      value:[UIColor whiteColor]
                      range:range];
    
    [titleAttr addAttribute:NSFontAttributeName
                      value:ZFFontBoldSize(14)
                      range:range];
    return titleAttr;
}

#pragma mark -===========初始化UI===========

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.layer.cornerRadius = 11;
        _closeButton.layer.masksToBounds = YES;
        _closeButton.backgroundColor = ZFCOLOR(0, 0, 0, 0.4);
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_closeButton setTitle:ZFLocalizedString(@"Guide_Skip_Tips", nil) forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAtion:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}


- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (UIButton *)shopinButton {
    if (!_shopinButton) {
        _shopinButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        NSString *title = [self fetchCountryName];
//        [_shopinButton setAttributedTitle:[self fetchShopInButtonTitle:title] forState:UIControlStateNormal];
        [_shopinButton setTitleColor:ZFCOLOR(255, 255, 255, 1) forState:UIControlStateNormal];
        [_shopinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_shopinButton addTarget:self action:@selector(shopinButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _shopinButton.titleLabel.font = ZFFontSystemSize(14);
        _shopinButton.titleLabel.numberOfLines = 0;
        _shopinButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _shopinButton;
}

- (UIScrollView *)scrollView {
    if(!_scrollView){
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if(!_pageControl){
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.hidden = YES;
    }
    return _pageControl;
}

- (UIButton *)registerButton {
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerButton.backgroundColor = [UIColor whiteColor];
        [_registerButton setTitle:ZFLocalizedString(@"Guide_Register_Button", nil) forState:UIControlStateNormal];
        [_registerButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateNormal];
        _registerButton.titleLabel.font = ZFFontBoldSize(16);
        [_registerButton addTarget:self action:@selector(registerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _registerButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _registerButton.layer.borderWidth = 1.f;
        _registerButton.layer.cornerRadius = 3;
        _registerButton.layer.masksToBounds = YES;
    }
    return _registerButton;
}

- (UIButton *)goShoppingButton {
    if (!_goShoppingButton) {
        _goShoppingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _goShoppingButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [_goShoppingButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateNormal];
        _goShoppingButton.titleLabel.font = ZFFontSystemSize(16);
        [_goShoppingButton addTarget:self action:@selector(goShoppingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _goShoppingButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _goShoppingButton.layer.borderWidth = 1.f;
        _goShoppingButton.layer.cornerRadius = 3;
        _goShoppingButton.layer.masksToBounds = YES;
        
        NSString *title = ZFLocalizedString(@"NewVersionGuide_GoShopping", nil);
//        if (self.showABFlag && ![AccountManager sharedManager].isSignIn) {
//            title = ZFLocalizedString(@"SignIn_Button", nil);
//        }
        [_goShoppingButton setTitle:title forState:UIControlStateNormal];
    }
    return _goShoppingButton;
}

- (UIButton *)goLoginButton {
    if (!_goLoginButton) {
        _goLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _goLoginButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [_goLoginButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateNormal];
        _goLoginButton.titleLabel.font = ZFFontBoldSize(16);
        [_goLoginButton addTarget:self action:@selector(goShoppingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _goLoginButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _goLoginButton.layer.borderWidth = 1.f;
        _goLoginButton.layer.cornerRadius = 3;
        _goLoginButton.layer.masksToBounds = YES;
        [_goLoginButton setTitle:ZFLocalizedString(@"SignIn_Button", nil) forState:UIControlStateNormal];
    }
    return _goLoginButton;
}

- (UIButton *)facebookButton {
    if (!_facebookButton) {
        _facebookButton = [ZFButton buttonWithType:UIButtonTypeCustom];
        [_facebookButton setImage:[UIImage imageNamed:@"register_fb"] forState:UIControlStateNormal];
        [_facebookButton addTarget:self action:@selector(facebookButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _facebookButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    }
    return _facebookButton;
}

- (UIButton *)googlePlusButton {
    if (!_googlePlusButton) {
        _googlePlusButton = [ZFButton buttonWithType:UIButtonTypeCustom];
        [_googlePlusButton setImage:[UIImage imageNamed:@"register_google"] forState:UIControlStateNormal];
        [_googlePlusButton addTarget:self action:@selector(googleplusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _googlePlusButton;
}

- (UIButton *)vkButton {
    if (!_vkButton) {
        _vkButton = [ZFButton buttonWithType:UIButtonTypeCustom];
        [_vkButton setImage:[UIImage imageNamed:@"VKontakte"] forState:UIControlStateNormal];
        [_vkButton addTarget:self action:@selector(vkontakteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _vkButton;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = ZFFontSystemSize(14);
        _tipLabel.text = [NSString stringWithFormat:@"— %@ —",ZFLocalizedString(@"sign_in_with", nil)];
        _tipLabel.textColor = ZFCOLOR(255, 255, 255, 1);
    }
    return _tipLabel;
}

@end
