//
//  OSSVTabBarVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVTabBarVC.h"
#import "STLNavigationController.h"
#import "OSSWMHomeVC.h"
//#import "OSSVCategorysVC.h"
#import "OSSVCategorysVC.h"

#import "STLCartViewCtrl.h"
#import "OOSVAccountVC.h"
//#import "STLAccountCtrl.h"
#import "SignViewController.h"
#import "AccountManager.h"
#import "OSSVSearchVC.h"
#import "STLMessageCtrl.h"

// 社区POST功能使用
#import "STLTabbarManager.h"
#import "UIColor+Extend.h"
#import "UIImage+Color.h"

#import "Adorawe-Swift.h"

#define TAG_HINTDOT 999

@interface STLAnimationTabBar : UITabBar
@property (nonatomic, strong) NSMutableArray    *animViewArray;
@end

@implementation STLAnimationTabBar

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.animViewArray removeAllObjects];
    
//    for (UIView *button in self.subviews) {
//        if (![button isKindOfClass:[UIControl class]]) continue;
//
//        for (UIView *tmpView in button.subviews) {
//            if ([tmpView isKindOfClass:[NSClassFromString(@"UITabBarSwappableImageView") class]]) {
//                [self.animViewArray addObject:tmpView];
//            }
//        }
//    }
    
    ///消除TabBar顶部细线
    [self hideTabBarTopLine];
}

- (NSMutableArray *)animViewArray {
    if (!_animViewArray) {
        _animViewArray = [NSMutableArray array];
    }
    return _animViewArray;
}

///消除TabBar顶部细线
- (void)hideTabBarTopLine {
    for (UIView *tempView in self.subviews) {
        if (![tempView isKindOfClass:[NSClassFromString(@"_UIBarBackground") class]]) continue;
        
        for (UIView *tempSubView in tempView.subviews) {
            if (![tempSubView isKindOfClass:[NSClassFromString(@"_UIBarBackgroundShadowView") class]]) continue;
            
            for (UIView *thirdSubView in tempSubView.subviews) {
                if (![thirdSubView isKindOfClass:[NSClassFromString(@"_UIBarBackgroundShadowContentImageView") class]]) continue;
                
                if (thirdSubView.frame.size.height < 1.0) {
                    thirdSubView.backgroundColor = [UIColor clearColor];
                    thirdSubView.layer.backgroundColor = [UIColor clearColor].CGColor;
                }
                return;
            }
        }
    }
}

@end

//===========================================================================

@interface OSSVTabBarVC ()
<
UITabBarControllerDelegate,
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UIAlertViewDelegate,
UINavigationControllerDelegate
>
//@property (nonatomic, strong) YYAnimatedImageView *itemView;
@property (nonatomic, assign) NSInteger indexFlag;
@property (nonatomic, strong) OSSWMHomeVC                  *homeVC;
@property (nonatomic, strong) OSSVCategorysVC             *catagoryVC;
//@property (nonatomic, strong) STLMessageCtrl                        *messageVC;
@property (nonatomic, strong) OSSVNewChannelViewController              *channelNewVC;
@property (nonatomic, strong) STLCartViewCtrl                       *cartVC;
@property (nonatomic, strong) OOSVAccountVC                 *accountCTRL;

///** 首页logo */
//@property (nonatomic, strong) UIButton *homeBtn;
///** 标记视图 */
//@property (nonatomic, strong) UIView *tagView;
/** TabBar数组 */
@property (nonatomic, strong) NSMutableArray *tabbarbuttonArray;

@end

@implementation OSSVTabBarVC

- (void)dealloc
{
    STLLog(@"================ OSSVTabBarVC dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


+ (void)initialize {
    

    [[UITabBar appearance] setUnselectedItemTintColor:[STLThemeColor col_999999]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [STLThemeColor col_999999],
                                                        NSFontAttributeName : [UIFont systemFontOfSize:10]}
                                                        forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [STLThemeColor col_262626],
                                                        NSFontAttributeName : [UIFont systemFontOfSize:10]}
                                                        forState:UIControlStateSelected];
    [[UITabBarItem appearance] setBadgeColor:STLThemeColor.col_B62B21];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.delegate = self;
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
        
    [self setupControllers];
    [self setupTabBarAnimation];

    [self.tabBar setShadowImage:[UIImage new]];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.tabBar.bounds);
    self.tabBar.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    
    self.tabBar.layer.shadowColor = [STLThemeColor col_EEEEEE].CGColor;
    self.tabBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.tabBar.layer.shadowRadius = 1;
    self.tabBar.layer.shadowOpacity = 1;
    self.tabBar.clipsToBounds = NO;
    

    
    self.tabBar.backgroundColor =  [STLThemeColor stlWhiteColor];
    self.tabBar.translucent = NO; // 设置不半透明
    
//    _itemView = [[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"xj_style"]];
//    _itemView.frame = CGRectMake(self.view.centerX-30, 1.5, 60, 46);
//    _itemView.hidden = YES;
    
    // 购物车数量
    NSInteger allGoodsCount = [[CartOperationManager sharedManager] cartValidGoodsAllCount];
    if (allGoodsCount > 0) {
        self.viewControllers[3].tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)allGoodsCount];
        if (allGoodsCount > 99) {
            allGoodsCount = 99;
            self.viewControllers[3].tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu+",(unsigned long)allGoodsCount];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSInteger tempIndex = 0;
    NSArray *itemIDs = @[@"nav_home",@"nav_category",@"nav_message",@"nav_bag",@"nav_account"];
    
    if (self.tabBar.items.count == itemIDs.count) {
        for (UIView *subView in self.tabBar.subviews) {
            if (([subView isKindOfClass:NSClassFromString(@"UITabBarButton")])) {
                
                for (UIView *itemSubView in subView.subviews) {
                    itemSubView.sensor_element_id = itemIDs[tempIndex];
                }
                tempIndex++;
            }
        }
    }
    
    [self showOrHiddenAccountDot];  // 个人中心红点提示
    [self notificationCenter];      // 通知
}

- (CAShapeLayer *)line {
    CAShapeLayer *solidShapeLayer = [CAShapeLayer layer];
    CGMutablePathRef solidShapePath =  CGPathCreateMutable();
    [solidShapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [solidShapeLayer setStrokeColor:[[STLThemeColor col_EEEEEE] CGColor]];
    solidShapeLayer.lineWidth = .1f ;
    CGPathMoveToPoint(solidShapePath, NULL, 0, 0);
    CGPathAddLineToPoint(solidShapePath, NULL, SCREEN_WIDTH,0);
    [solidShapeLayer setPath:solidShapePath];
    CGPathRelease(solidShapePath);
    return solidShapeLayer;
}

///自定义Tabbar为了获取icon的父视图
- (void)setupTabBarAnimation {
    STLAnimationTabBar *appTabBar = [[STLAnimationTabBar alloc] initWithFrame:self.tabBar.bounds];
    [self setValue:appTabBar forKeyPath:@"tabBar"];
}

- (void)setupControllers {
    
    FastAddManager.sheet = nil;
    
    NSUserDefaults *userdefault = NSUserDefaults.standardUserDefaults;
    
    NSArray *datas = [userdefault objectForKey:@"kConfigIconData"];
    NSArray<ConfigedIconModel *> *arr = [NSArray yy_modelArrayWithClass:ConfigedIconModel.class json:datas];
    if (arr.count == 5) {
        ConfigedIconModel *first = arr.firstObject;
        
        NSString *defaultColor = first.color_nocheck;
        if(defaultColor){
            self.tabBar.unselectedItemTintColor = [UIColor colorWithHexString:defaultColor];
            [[UITabBar appearance] setUnselectedItemTintColor:[UIColor colorWithHexString:defaultColor]];
            [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:defaultColor],
                                                                NSFontAttributeName : [UIFont systemFontOfSize:10]}
                                                                forState:UIControlStateNormal];
        }
        NSString *selectColor = first.color_check;
        if(selectColor){
            self.tabBar.tintColor = [UIColor colorWithHexString:selectColor];
            [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:selectColor],
                                                                NSFontAttributeName            : [UIFont systemFontOfSize:10]}
                                                                 forState:UIControlStateSelected];
        }
        _homeVC = [[OSSWMHomeVC alloc] init];
        [self setupChildViewController:_homeVC title:STLLocalizedString_(@"homeTitle",nil) imageName:@"tab_home" selectedImageName:@"tab_home_selected" configModel:arr[0]];
        
        _catagoryVC = [[OSSVCategorysVC alloc] init];
        [self setupChildViewController:_catagoryVC title:STLLocalizedString_(@"category",nil) imageName:@"tab_categories" selectedImageName:@"tab_categories_selected" configModel:arr[1]];
        
        
//        _messageVC = [[STLMessageCtrl alloc] init];
//        [self setupChildViewController:_messageVC title:STLLocalizedString_(@"Message",nil) imageName:@"tab_message" selectedImageName:@"tab_message_selected" configModel:arr[2]];
        _channelNewVC = [[OSSVNewChannelViewController alloc] init];
        [self setupChildViewController:_channelNewVC title:STLLocalizedString_(@"new_in_tab_title",nil) imageName:@"tab_new" selectedImageName:@"tab_new_select" configModel:arr[2]];
        
        
        _cartVC = [[STLCartViewCtrl alloc] init];
        [self setupChildViewController:_cartVC title:STLLocalizedString_(@"Bag",nil) imageName:@"tab_bag" selectedImageName:@"tab_bag_selected" configModel:arr[3]];
        
            _accountCTRL = [[OOSVAccountVC alloc] init];
        [self setupChildViewController:_accountCTRL title:STLLocalizedString_(@"accountTitle",nil) imageName:@"tab_me" selectedImageName:@"tab_me_selected" configModel:arr[4]];
    }else{
        _homeVC = [[OSSWMHomeVC alloc] init];
        [self setupChildViewController:_homeVC title:STLLocalizedString_(@"homeTitle",nil) imageName:@"tab_home" selectedImageName:@"tab_home_selected"];
        
        _catagoryVC = [[OSSVCategorysVC alloc] init];
        [self setupChildViewController:_catagoryVC title:STLLocalizedString_(@"category",nil) imageName:@"tab_categories" selectedImageName:@"tab_categories_selected"];
        
        
//        _messageVC = [[STLMessageCtrl alloc] init];
//        [self setupChildViewController:_messageVC title:STLLocalizedString_(@"Message",nil) imageName:@"tab_message" selectedImageName:@"tab_message_selected"];
        _channelNewVC = [[OSSVNewChannelViewController alloc] init];
        [self setupChildViewController:_channelNewVC title:STLLocalizedString_(@"new_in_tab_title",nil) imageName:@"tab_new" selectedImageName:@"tab_new_select"];

        
        _cartVC = [[STLCartViewCtrl alloc] init];
        [self setupChildViewController:_cartVC title:STLLocalizedString_(@"Bag",nil) imageName:@"tab_bag" selectedImageName:@"tab_bag_selected"];
        
            _accountCTRL = [[OOSVAccountVC alloc] init];
        [self setupChildViewController:_accountCTRL title:STLLocalizedString_(@"accountTitle",nil) imageName:@"tab_me" selectedImageName:@"tab_me_selected"];
    }
    
}

/**
 *  初始化一个子控制器
 *
 *  @param childVc  需要初始化的子控制器
 *  @param title  标题
 *  @param imageName 图标
 *  @param selectedImageName 选中的图标
 *  @最后一步将子控制器包装成导航栏控制器
 */
- (void)setupChildViewController:(UIViewController *)childVc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName {
    childVc.title = title;
    childVc.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    childVc.tabBarItem.selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    STLNavigationController *nav = [[STLNavigationController alloc] initWithRootViewController:childVc];
    [self addChildViewController:nav];
}

/**
 *  初始化一个子控制器
 *
 *  @param childVc  需要初始化的子控制器
 *  @param title  标题
 *  @param imageName 图标
 *  @param selectedImageName 选中的图标
 *  @param configModel 网络获取的配置对象
 *  @最后一步将子控制器包装成导航栏控制器
 */
- (void)setupChildViewController:(UIViewController *)childVc title:(NSString *)title
                       imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
                     configModel:(ConfigedIconModel *)configModel {
    childVc.title = title;
    
    YYImageCache *cache = YYWebImageManager.sharedManager.cache;
    UIImage *defaultWebImage = [cache getImageForKey:configModel.icon_src_nocheck];
    defaultWebImage = [[defaultWebImage yy_imageByResizeToSize:CGSizeMake(30, 30)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selectedWebImage = [cache getImageForKey:configModel.icon_src_check];
    selectedWebImage = [[selectedWebImage yy_imageByResizeToSize:CGSizeMake(30, 30)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *defaultImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.image = defaultWebImage ?: defaultImage;
    childVc.tabBarItem.selectedImage = selectedWebImage ?: selectedImage;
    STLNavigationController *nav = [[STLNavigationController alloc] initWithRootViewController:childVc];
    [self addChildViewController:nav];
}

- (STLNavigationController *)navigationControllerWithMoudle:(STLMainMoudle)moudle {
    if (self.viewControllers.count > moudle) {
        STLNavigationController *nav = [self.viewControllers objectAtIndex:moudle];
        return nav;
    } else {
        return nil;
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UINavigationController *)viewController {
    
//    if ([viewController.topViewController isKindOfClass:STLMessageCtrl.class] && ![AccountManager sharedManager].isSignIn) {
//        SignViewController *signVC = [SignViewController new];
//        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
//        @weakify(self)
//        signVC.signBlock = ^{
//            @strongify(self)
//            self.selectedIndex = [self.viewControllers indexOfObject:viewController];
//        };
//        [self presentViewController:signVC animated:YES completion:nil];
//        return NO;
//    }
    return YES;
}

- (void)setModel:(STLMainMoudle)model {
    if (self.selectedIndex == model) {
        return;
    } else {
        if([self tabBarController:self shouldSelectViewController:[self.viewControllers objectAtIndex:model]]) {
            self.selectedIndex = model;
        }
    }
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSInteger index = [self.tabBar.items indexOfObject:item];
    if (self.indexFlag != index) {
    }
    NSString *actionStr = @"";
    NSString *navStr = @"Home";
    switch (index) {
        case 0:
            actionStr = @"tab_click_home";
            navStr = @"Home";
            break;
        case 1:
            actionStr = @"tab_click_catagory";
            navStr = @"Category";
            break;
        case 2:
            actionStr = @"tab_click_message";
            navStr = @"New";
            break;
        case 3:
            actionStr = @"tab_click_cart";
            navStr = @"Cart";

            break;
        case 4:
            actionStr = @"tab_click_me";
            navStr = @"Me";

        default:
            break;
    }
    
    [STLAnalytics analyticsGAEventWithName:@"top_function" parameters:@{
           @"screen_group":navStr,
           @"navigation":navStr}];

}

- (void)animationWithIndex:(NSInteger) index {

    CABasicAnimation*pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulse.duration = 0.08;
    pulse.repeatCount= 1;
    pulse.autoreverses= YES;
    pulse.fromValue= [NSNumber numberWithFloat:0.8];
    pulse.toValue= [NSNumber numberWithFloat:1.0];

    [[self.tabbarbuttonArray[index] layer] addAnimation:pulse forKey:nil];
    self.indexFlag = index;
}


- (void)notificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeValue:) name:kNotif_CartBadge object:nil]; // 刷新购物车
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeValue:) name:kNotif_Login object:nil]; // 登录
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeValue:) name:kNotif_Logout object:nil]; // 退出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOrHiddenAccountDot) name:kNotif_ChangeAccountRedDot object:nil]; // 消息

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTabbarIcon:) name:kNotif_LoadFinishTabbarIcon object:nil]; // 下载完成首页气氛消息通知
}

- (void)changeValue:(NSNotification *)notify {
    UITabBarItem * tabBarItem;

    tabBarItem =  [self.viewControllers[3] tabBarItem];
    tabBarItem.badgeColor = [STLThemeColor stlWhiteColor];

    // 购物车数量
    NSInteger allGoodsCount = [[CartOperationManager sharedManager] cartValidGoodsAllCount];
    if (allGoodsCount > 0) {
        tabBarItem.badgeColor = [STLThemeColor col_B62B21];
        if (allGoodsCount > 99) {
            allGoodsCount = 99;
            tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu+",(unsigned long)allGoodsCount];
        }else{
            tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)allGoodsCount];
        }
    } else {
        tabBarItem.badgeValue = nil;
    }
    
    if ([notify.name isEqualToString:kNotif_Login] || [notify.name isEqualToString:kNotif_Logout]) {
        [self showOrHiddenAccountDot];
    }
}
//个人中心 红点
- (void)showOrHiddenAccountDot {
    for (UIView *v in self.tabBar.subviews) {
        if (v.tag>=TAG_HINTDOT) {
            if ([v isKindOfClass:[UILabel class]] && v.tag-TAG_HINTDOT == STLMainMoudleAccount) {
                [v removeFromSuperview];
            }
        }
    }
    if (USERID) {
        AccountModel *accountModel = [AccountManager sharedManager].account;
        
        if (accountModel.appUnreadCouponNum > 0
            || accountModel.outstandingOrderNum > 0
            || accountModel.processingOrderNum > 0
            || accountModel.shippedOrderNum > 0
            || accountModel.reviewedNum > 0) {
            
            CGFloat itemWidth = 0;

            itemWidth = SCREEN_WIDTH/5;
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(itemWidth*(STLMainMoudleAccount+1)-25*DSCREEN_WIDTH_SCALE, 5, 8, 8)];
            if ([SystemConfigUtils isRightToLeftShow]) {
                lbl.frame = CGRectMake(25*DSCREEN_WIDTH_SCALE - 7, 5, 8, 8);
            } else {
                lbl.frame = CGRectMake(itemWidth*(STLMainMoudleAccount+1)-25*DSCREEN_WIDTH_SCALE, 5, 8, 8);
            }
            lbl.tag = TAG_HINTDOT + STLMainMoudleAccount;
            lbl.backgroundColor = [STLThemeColor col_B62B21];
            lbl.layer.cornerRadius = 4;
            lbl.clipsToBounds = YES;
            [self.tabBar addSubview:lbl];
        }
    }
}
//消息中心红点
//- (void)showOrHiddenMessageDot {
//    for (UIView *v in self.tabBar.subviews) {
//        if (v.tag>=TAG_HINTDOT) {
//            if ([v isKindOfClass:[UILabel class]] && v.tag-TAG_HINTDOT == STLMainMoudleMessage) {
//                [v removeFromSuperview];
//            }
//        }
//    }
//    if (USERID) {
//
//        if ([AccountManager sharedManager].appUnreadMessageNum > 0) {
//            CGFloat itemWidth = 0;
//
//            itemWidth = SCREEN_WIDTH/5;
//            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(itemWidth*(STLMainMoudleMessage+1)-25*DSCREEN_WIDTH_SCALE, 5, 8, 8)];
//            if ([SystemConfigUtils isRightToLeftShow]) {
//                lbl.frame = CGRectMake(SCREEN_WIDTH - (itemWidth*(STLMainMoudleMessage+1)-20*DSCREEN_WIDTH_SCALE), 5, 8, 8);
//
//            } else {
//                lbl.frame = CGRectMake(itemWidth*(STLMainMoudleMessage+1)-25*DSCREEN_WIDTH_SCALE, 5, 8, 8);
//            }
//            lbl.tag = TAG_HINTDOT + STLMainMoudleMessage;
//            lbl.backgroundColor = [STLThemeColor col_FF4E6A];
//            lbl.layer.cornerRadius = 4;
//            lbl.clipsToBounds = YES;
//            [self.tabBar addSubview:lbl];
//        }
//    }
//}

- (void)updateTabbarIcon:(NSNotification *)nofi {
    
    //暂时隐藏氛围
    return;
    
    NSDictionary *dict = [nofi userInfo];
    STLTabbarModel *model = [dict objectForKey:@"model"];
    STLTabbarManager *manager = [STLTabbarManager sharedInstance];
    YYImageCache *imageCahce = [YYImageCache sharedCache];
    
    if (!manager.model.isDownLoadTabbarIcon) {
        return;
    }
    
    NSString *bgUrl = @"";
    if (manager.type == STLDeviceImageTypeIphoneX || manager.type == STLDeviceImageType3X)
    {
        bgUrl = model.body.backgroup_url_3x;
    }
    else
    {
        bgUrl = model.body.backgroup_url_2x;
    }
    UIImage *bgCacheImage = [imageCahce getImageForKey:bgUrl withType:YYImageCacheTypeDisk];
    if (bgCacheImage) {
        self.tabBar.backgroundImage = bgCacheImage;
    }
}

//MARK: 获取存放TabBar上的子控件的可变数组
- (NSMutableArray *)tabbarbuttonArray {
    if (!_tabbarbuttonArray) {
        _tabbarbuttonArray = [NSMutableArray array];
        for (UIView *tabBarButton in self.tabBar.subviews) {
            if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
                [_tabbarbuttonArray addObject:tabBarButton];
            }
        }
    }
    return _tabbarbuttonArray;
}


@end
