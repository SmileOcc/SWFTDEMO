//
//  AppDelegate+STLCategory.m
// XStarlinkProject
//
//  Created by odd on 2020/7/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "AppDelegate+STLCategory.h"
#import "OSSVCheckOutVC.h"

@implementation AppDelegate (STLCategory)


- (void)launchingSetting:(NSDictionary *)launchOptions {
    
    NSUserDefaults *versionDefaults = [NSUserDefaults standardUserDefaults];
    NSString * cur_version = [versionDefaults stringForKey: APPVIERSION];
    NSString *las_Lang = [versionDefaults stringForKey:kLastLanag];
    NSString *cur_Lang = [STLLocalizationString shareLocalizable].nomarLocalizable;;
   
    if ([OSSVNSStringTool isEmptyString:cur_version] || ![cur_version isEqualToString:kAppVersion] || ![cur_Lang isEqualToString:las_Lang]) {
        
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
        [versionDefaults setObject:kAppVersion forKey:APPVIERSION];
        [versionDefaults setObject:cur_Lang forKey:kLastLanag];
        [versionDefaults synchronize];
        
        [CacheFileManager clearDatabaseCache:STL_PATH_DATABASE_CACHE];
    }
    
    
    //预发布设置
    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || type == DomainType_Release) {
        addSTLLinkCookie();
    } else {
        deleteSTLLinkCookie();
    }

    // 存入首次打开app的时间
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppFirtOpenBehindInstall"];
    if (!date) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"AppFirtOpenBehindInstall"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
//    [self showLoadingVC];
}

/**
 * 初始化AppTabbr
 */
- (void)initAppRootVC {
    self.tabBarVC = [[OSSVTabBarVC alloc] init];
    self.window.rootViewController = self.tabBarVC;
}

- (void)showLoadingVC {
    
    NSArray *imageNames = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:nil];
    UIImage *img = [UIImage imageNamed:@"startLaunchImage"];
    
//    for (NSString *str in imageNames){
//        if ([str rangeOfString:@"startLaunchImage"].location != NSNotFound) {
//            img = [UIImage imageWithContentsOfFile:str];
//            if (CGSizeEqualToSize(img.size, [UIScreen mainScreen].bounds.size)) {
//                break;
//            }
//        }
//    }
    
    UIViewController *vc = [[UIViewController alloc] init];
    if (img) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:vc.view.bounds];
        iv.image = img;
        [vc.view addSubview:iv];
    }
    
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleGray;
//    style = UIActivityIndicatorViewStyleWhiteLarge;
    UIActivityIndicatorView *indi = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    indi.frame = CGRectMake(0, 0, 50, 50);
    indi.center = vc.view.center;
    indi.hidesWhenStopped = YES;
    indi.color = OSSVThemesColors.col_999999;
    [indi startAnimating];
    [vc.view addSubview:indi];
    
    self.window.rootViewController = vc;
}

- (void)networkStatusChangeHandle:(RealReachability *)reachability {
    
    ReachabilityStatus status = [reachability currentReachabilityStatus]; //获取当前网络状态
    ReachabilityStatus previousStatus = [reachability previousReachabilityStatus]; //改变网络前的网络状态
    
    if (status == previousStatus) return; //如果改变后和之前一样就直接 return
    
    // 改变当前网络状态
    [STLNetworkStateManager sharedManager].curStatus = status;
    switch (status) {
        case RealStatusNotReachable:
        {
//            if (!self.networkBackgroundView) {
//                UIView *networkBgView = [UIView new];
//                [WINDOW addSubview:networkBgView];
//                self.networkBackgroundView = networkBgView;
//                [networkBgView mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.leading.trailing.mas_equalTo(0);
//                    make.top.mas_equalTo(kNavHeight);
//                    make.height.mas_equalTo(40);
//                }];
//                
//                UIImageView *imgView = [UIImageView new];
//                imgView.image = [UIImage imageNamed:@"network_icon"];
//                [networkBgView addSubview:imgView];
//                [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.leading.mas_equalTo(10);
//                    make.centerY.mas_equalTo(networkBgView.mas_centerY);
//                    make.width.height.mas_equalTo(40);
//                }];
//                
//                UILabel *textLab = [UILabel new];
//                textLab.font = [UIFont systemFontOfSize:14];
//                textLab.textColor = OSSVThemesColors.col_FFFFFF;
//                textLab.text = STLLocalizedString_(@"networkErrorMsg",nil);
//                [networkBgView addSubview:textLab];
//                [textLab mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.leading.mas_equalTo(imgView.mas_trailing).offset(0);
//                    make.centerY.mas_equalTo(networkBgView.mas_centerY);
//                }];
//            }
//            self.networkBackgroundView.hidden = NO;
        }
            break;
        case RealStatusUnknown:
        case RealStatusViaWWAN:
        case RealStatusViaWiFi:
        {
            self.networkBackgroundView.hidden = YES;
            [self.networkBackgroundView removeFromSuperview];
            self.networkBackgroundView = nil;
        }
            break;
    }
}



+ (void)appVersionAdvertRegisterNotificationBlock:(void(^)(void))registerBlock {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL show = [userDefaults boolForKey:[NSString stringWithFormat:@"version_%@", kAppVersion]];
    
    if (!show) {
        
        [[OSSVAdvsViewsManager sharedManager] showAdv:YES startOpen:YES];
        
        //注册通知
        if (registerBlock) {
            registerBlock();
        }
        
        [userDefaults setBool:YES forKey:[NSString stringWithFormat:@"version_%@", kAppVersion]];
        [userDefaults synchronize];
    } else {
        [AppDelegate addAdvertView];
    }
}

#pragma mark - 启动广告
+ (void)addAdvertView {
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAdvertApiData"];
    if (STLJudgeNSDictionary(dict)) {
        OSSVAdvsEventsModel *advEventModel = [OSSVAdvsEventsModel yy_modelWithJSON:dict[kResult][@"advertInfo"]];
        [OSSVAdvsEventsManager sharedManager].advEventModel = advEventModel;
        [OSSVAdvsViewsManager sharedManager].isLaunchAdv = YES;
    }
    OSSVAdvsEventsModel *advEventModel = [OSSVAdvsEventsManager sharedManager].advEventModel;
    
    /////
//    advEventModel = [[OSSVAdvsEventsModel alloc] init];
//    advEventModel.imageURL = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1607315079216&di=ebd8383d8db79af68bca9f59dbb13156&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201611%2F04%2F20161104110413_XzVAk.gif";
    
    if (advEventModel == nil || [advEventModel.imageURL length] == 0) {   //没有返回广告信息 广告图为空
        [AppDelegate showHomeAdv];
        return;
    }
    
    NSString *currentLang = [STLLocalizationString shareLocalizable].nomarLocalizable;
    NSString *localImageKey = [NSString stringWithFormat:@"advertIconUrl_%@",currentLang];
    //获取redirectUrl，看是否一致，一致则不需要重新下载tab Icon
    NSString *oldIconUrl = [[NSUserDefaults standardUserDefaults] stringForKey:localImageKey];
    NSString *newIconUrl = advEventModel.imageURL;
    
    NSString * fileName = [NSString stringWithFormat:@"advertIcon_%@.png",currentLang];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),fileName];
    
    STLLog(@"图片地址----- %@",documentsDirectory);
    BOOL isFileExist = [fileManager fileExistsAtPath:documentsDirectory];
    
    if (isFileExist) {
        if (![oldIconUrl isEqualToString:newIconUrl]) {
            
            [AppDelegate showHomeAdv];
            [AppDelegate downloadImage:newIconUrl fileName:fileName];
            
            // 保存新的活动链接
            [[NSUserDefaults standardUserDefaults] setObject:newIconUrl forKey:localImageKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            
            
            if ([oldIconUrl isEqualToString:newIconUrl]) {
                // 取出图片
                NSData *imageData = [NSData dataWithContentsOfFile:documentsDirectory];
                UIImage *image = [UIImage imageWithData:imageData];
                if (image) {
                    
                    OSSVLanuchsAdvView *lanuchAdv = [[OSSVLanuchsAdvView alloc] initWithFrame:WINDOW.bounds advModel:advEventModel image:image];
                    lanuchAdv.advDoActionBlock = ^(OSSVAdvsEventsModel *OSSVAdvsEventsModel) {
                        if (OSSVAdvsEventsModel) {
                            [AppDelegate advertImgViewDoAction];
                        } else {
                            [AppDelegate showHomeAdv];
                        }
                    };
                    
                }
            }
        }
    }else
    {
        [AppDelegate downloadImage:newIconUrl fileName:fileName];
        
        // 保存新的活动链接
        [[NSUserDefaults standardUserDefaults] setObject:newIconUrl forKey:localImageKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark -===========启动判断显示页面跳转逻辑===========

/**
 * 显示启动倒计时广告
 */
+ (void)showLaunchAdvertView:(OSSVAdvsEventsModel *)advEventModel
                   imageData:(NSData *)imageData
             completeHandler:(void(^)(void))completeHandler {
    
//    void (^jumpBannerBlock)(void) = ^(void){
//        STLLog(@"点击了倒计时广告");
//        if(completeHandler){
//            completeHandler();
//        }
//        //获取到的应该是主页的控制器
//        UIViewController *homeVC = [UIViewController currentTopViewController];
//
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            //[OSSVAccountsManager sharedManager].hasShowAdvertIntoApp = NO;
//        });
//    };
    
    NSString *currentLang = [STLLocalizationString shareLocalizable].nomarLocalizable;
    NSString *localImageKey = [NSString stringWithFormat:@"advertIconUrl_%@",currentLang];
    //获取redirectUrl，看是否一致，一致则不需要重新下载tab Icon
    NSString *oldIconUrl = [[NSUserDefaults standardUserDefaults] stringForKey:localImageKey];
    NSString *newIconUrl = advEventModel.imageURL;
    
    NSString * fileName = [NSString stringWithFormat:@"advertIcon_%@.png",currentLang];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),fileName];
    
    STLLog(@"图片地址----- %@",documentsDirectory);
    BOOL isFileExist = [fileManager fileExistsAtPath:documentsDirectory];
    
    if (isFileExist) {
        if (![oldIconUrl isEqualToString:newIconUrl]) {
            
            //[AppDelegate showHomeAdv];
            [AppDelegate downloadImage:newIconUrl fileName:fileName];
            
            // 保存新的活动链接
            [[NSUserDefaults standardUserDefaults] setObject:newIconUrl forKey:localImageKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if(completeHandler){
                completeHandler();
            }
        } else {

            // 取出图片
            NSData *imageData = [NSData dataWithContentsOfFile:documentsDirectory];
            UIImage *image = [UIImage imageWithData:imageData];
            if (image) {
                
                OSSVLanuchsAdvView *lanuchAdv = [[OSSVLanuchsAdvView alloc] initWithFrame:WINDOW.bounds advModel:advEventModel image:image];
                lanuchAdv.advDoActionBlock = ^(OSSVAdvsEventsModel *OSSVAdvsEventsModel) {
                    if (OSSVAdvsEventsModel) {
                        [AppDelegate advertImgViewDoAction];
                    } else {
                        //[AppDelegate showHomeAdv];
                    }
                    if(completeHandler){
                        completeHandler();
                    }
                };
                
                lanuchAdv.skipBlock = ^{
                    [OSSVAnalyticsTool analyticsGAEventWithName:@"ski_promotion" parameters:@{
                        @"screen_group":@"Opening Ads"}];
                };
                
                // item
                NSMutableDictionary *item = [@{
//                  kFIRParameterItemID: $itemId,
//                  kFIRParameterItemName: $itemName,
//                  kFIRParameterItemCategory: $itemCategory,
//                  kFIRParameterItemVariant: $itemVariant,
//                  kFIRParameterItemBrand: $itemBrand,
//                  kFIRParameterPrice: $price,
//                  kFIRParameterCurrency: $currency
                } mutableCopy];


                // Prepare promotion parameters
                NSMutableDictionary *promoParams = [@{
//                  kFIRParameterPromotionID: $promotionId,
//                  kFIRParameterPromotionName:$promotionName,
//                  kFIRParameterCreativeName: $creativeName,
                  kFIRParameterCreativeSlot: @"Opening Ads",
                  @"screen_group":@"Opening Ads",
                  @"position": @"Opening Ads"
                } mutableCopy];

                // Add items
                promoParams[kFIRParameterItems] = @[item];
                
                [OSSVAnalyticsTool analyticsGAEventWithName:@"kFIREventViewPromotion" parameters:promoParams];
                
            } else {
                if(completeHandler){
                    completeHandler();
                }
            }
        }
    }else {
        
        if(completeHandler){
            completeHandler();
        }
        
        [AppDelegate downloadImage:newIconUrl fileName:fileName];
        
        // 保存新的活动链接
        [[NSUserDefaults standardUserDefaults] setObject:newIconUrl forKey:localImageKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)firstDownloadImage:(NSString *)imagerUrl {
    
    if (!STLIsEmptyString(imagerUrl)) {
        
        NSString *currentLang = [STLLocalizationString shareLocalizable].nomarLocalizable;
        NSString *localImageKey = [NSString stringWithFormat:@"advertIconUrl_%@",currentLang];
        //    //获取redirectUrl，看是否一致，一致则不需要重新下载tab Icon
        //    NSString *oldIconUrl = [[NSUserDefaults standardUserDefaults] stringForKey:localImageKey];
        
        
        
        NSString *newIconUrl = imagerUrl;
        
        NSString * fileName = [NSString stringWithFormat:@"advertIcon_%@.png",currentLang];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsDirectory = [NSString stringWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),fileName];
        
        BOOL isFileExist = [fileManager fileExistsAtPath:documentsDirectory];
        if (!isFileExist) {
            // 保存新的活动链接
            [[NSUserDefaults standardUserDefaults] setObject:imagerUrl forKey:localImageKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [AppDelegate downloadImage:newIconUrl fileName:fileName];
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 保存新的活动链接
                [[NSUserDefaults standardUserDefaults] setObject:imagerUrl forKey:localImageKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [AppDelegate downloadImage:newIconUrl fileName:fileName];
            });
        }
    }
}

+ (void)downloadImage:(NSString *)imageUrl fileName:(NSString *)fileName {
    NSFileManager *fileManager   = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),fileName];
    
    // 判断是否已经存在，已经存在 ，删除之前的 icon
    NSArray *directory = [fileManager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/Library/Caches",NSHomeDirectory()] error:nil];
    for (NSString *cachesFileName in directory) {
        NSString *pathExStr = [cachesFileName pathExtension];
        if ([pathExStr isEqualToString:@"png"] || [pathExStr isEqualToString:@"PNG"] ||
            [pathExStr isEqualToString:@"jpg"] || [pathExStr isEqualToString:@"JPG"] ||
            [pathExStr isEqualToString:@"gif"] || [pathExStr isEqualToString:@"GIF"] ) {
            if ( [cachesFileName isEqualToString:fileName] ) {
                [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),fileName] error:nil];
                
            }
        }
    }
    
//    NSURL *url = [NSURL URLWithString:imageUrl];
//
//    [[YYWebImageManager sharedManager] requestImageWithURL:url options:(YYWebImageOptionShowNetworkActivity) progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
//
//    }];
//
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
//    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error) {
//            STLLog(@"gif download error:%@", error);
//        } else {
//             STLLog(@"gif download success, file path:%@",location.path);
//             //图片下载已完成，处理数据
//
//            NSString *ttt =  [NSString stringWithFormat:@"%@/Library/Caches",NSHomeDirectory()];
//
//            [[NSFileManager defaultManager] copyItemAtPath:location.path toPath:ttt error:&error];
//
//
//
//
//        }
//    }];
//    [task resume];
//
//    return;
    // 异步加载
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    [[AFImageDownloader defaultInstance] downloadImageForURLRequest:imageRequest success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
        NSError *tmpError = nil;
        @try {
            //保存图片
            STLLog(@"启动图片地址----- %@",documentsDirectory);
            [UIImagePNGRepresentation(responseObject) writeToFile:documentsDirectory atomically:YES];
        }
        @catch (NSException *exception) {
            //是否被写入
            BOOL isFileExist = [fileManager fileExistsAtPath:documentsDirectory];
            if (isFileExist) {
                //删除此图片
                [fileManager removeItemAtPath:documentsDirectory error:&tmpError];
            }
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        NSError *tmpError = nil;
        BOOL isFileExist = [fileManager fileExistsAtPath:documentsDirectory];  //是否被写入
        if (isFileExist) {   //删除此图片
            [fileManager removeItemAtPath:documentsDirectory error:&tmpError];
        }
    }];
}


+ (void)advertImgViewDoAction {
    
    OSSVAdvsEventsModel *advEventModel = [OSSVAdvsEventsManager sharedManager].advEventModel;
    [OSSVAdvsViewsManager sharedManager].isLaunchAdv = NO;
    if ([AppDelegate mainTabBar]) {
        
        OSSVTabBarVC *tab = [AppDelegate mainTabBar];
        [tab setModel:STLMainMoudleHome];
        OSSVNavigationVC *nav = [tab navigationControllerWithMoudle:STLMainMoudleHome];
        if (nav) {
            if (nav.viewControllers.count>1) {
                [nav popToRootViewControllerAnimated:NO];
            }
            OSSWMHomeVC *homeVC = nav.viewControllers[0];
            [OSSVAdvsEventsManager advEventTarget:homeVC withEventModel:advEventModel];
        } else {
            
            OSSWMHomeVC *homeVC = nav.viewControllers[0];
            [OSSVAdvsEventsManager advEventTarget:homeVC withEventModel:advEventModel];
        }
    }
    
    NSString *pageName = [UIViewController currentTopViewControllerPageName];
    NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                @"attr_node_1":@"splash_page",
                                 @"attr_node_2":@"",
                                 @"attr_node_3":@"",
                                 @"position_number":@(0),
                                 @"venue_position":@(0),
                                 @"action_type":@([advEventModel advActionType]),
                                 @"url":[advEventModel advActionUrl],
            };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDic];
                            
                        // item
                        NSMutableDictionary *item = [@{
                    //          kFIRParameterItemID: $itemId,
                    //          kFIRParameterItemName: $itemName,
                    //          kFIRParameterItemCategory: $itemCategory,
                    //          kFIRParameterItemVariant: $itemVariant,
                    //          kFIRParameterItemBrand: $itemBrand,
                    //          kFIRParameterPrice: $price,
                    //          kFIRParameterCurrency: $currency
                        } mutableCopy];


                        // Prepare promotion parameters
                        NSMutableDictionary *promoParams = [@{
//                            kFIRParameterPromotionID: $promotionId,
//                              kFIRParameterPromotionName:$promotionName,
//                              kFIRParameterCreativeName: $creativeName,
                              kFIRParameterCreativeSlot: @"Opening Ads",
                              @"screen_group":@"Opening Ads",
                              @"position": @"Opening Ads"
                        } mutableCopy];

                        // Add items
                        promoParams[kFIRParameterItems] = @[item];
                        
                    [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
}

+ (void)showHomeAdv {
    [OSSVAdvsViewsManager sharedManager].isLaunchAdv = NO;
    [[OSSVAdvsViewsManager sharedManager] showAdv:YES startOpen:YES];
}

+ (void)handleReceiveMemoryWarning {
    
    //商品详情页是属于内存消耗大户，当报警告时，先查询控制器栈里面有多少个商品详情的页面，优先dealloc几个
    UIViewController *topViewController = [OSSVAdvsEventsManager gainTopViewController];
    
    NSArray *viewControllers = topViewController.navigationController.viewControllers;
    NSInteger detailsNums = 0;
    NSMutableArray *detailsIdxSet = [[NSMutableArray alloc] init];
    NSInteger maxCount = [viewControllers count];
    ///移除掉90%的控制器
    NSInteger removeCount = (maxCount - 3) * 0.9;
    NSInteger endCount = [viewControllers count] - 1;///栈底的是当前正在显示的，不能移除
    ///从第三个开始算
    for (int i = 3; i < endCount; i++) {
        if (detailsNums >= removeCount) {
            break;
        }
        UIViewController *viewController = viewControllers[i];
        NSString *classString = NSStringFromClass(viewController.class);
        if ([classString isEqualToString:NSStringFromClass(OSSVCheckOutVC.class)]) {
            continue;
        }
        detailsNums++;
        [detailsIdxSet addObject:viewController];
    }
    
    if ([detailsIdxSet count]) {
        NSMutableArray *mutViewControllers = [viewControllers mutableCopy];
        for (int i = 0; i < [detailsIdxSet count]; i++) {
            UIViewController *viewController = detailsIdxSet[i];
            [mutViewControllers removeObject:viewController];
        }
        @synchronized(self){
            [topViewController.navigationController setViewControllers:[mutViewControllers copy] animated:NO];
        }
    }
    [[YYWebImageManager sharedManager].cache.memoryCache removeAllObjects];
}


+ (OSSVTabBarVC *)mainTabBar {
    
    AppDelegate *appDele = APPDELEGATE;
       if ([appDele.window.rootViewController isMemberOfClass:[OSSVTabBarVC class]]) {
           
           OSSVTabBarVC *tabbarCtrl = (OSSVTabBarVC *)appDele.window.rootViewController;
           return tabbarCtrl;
       }
    return nil;
}

/// 获取app的安装或者更新时间（不是打开app的时间，是安装或者更新的时间）
+ (NSDate *)getAppInstallOrUpdateTime {
//    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:bundlePath error:nil];
//    NSDate *date = [fileAttributes objectForKey:NSFileCreationDate];
//    return date;
    
    NSURL* urlToDocumentsFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    __autoreleasing NSError *error;
    NSDate *installDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:urlToDocumentsFolder.path error:&error] objectForKey:NSFileCreationDate];
    return installDate;
}

@end
