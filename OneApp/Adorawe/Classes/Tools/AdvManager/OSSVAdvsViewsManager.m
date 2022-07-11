//
//  OSSVAdvsViewsManager.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAdvsViewsManager.h"
#import "OSSVNSStringTool.h"
#import "OSSVAdvsEventsManager.h"

#import "STLBaseCtrl.h"
#import "OSSWMHomeVC.h"


// 英语
#define kHomeAdvEnFolderPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingString:@"/JumpAdvEn"]

// 阿语
#define kHomeAdvArFolderPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingString:@"/JumpAdvAr"]

// 图片
#define kHomeAdvImageFolderPath [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingString:@"/JumpAdvImage"]

@implementation OSSVAdvsViewsManager

+ (OSSVAdvsViewsManager *)sharedManager {
    static OSSVAdvsViewsManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

//文件路径
+ (NSString *)homeAdvFolerPath {
    return [OSSVSystemsConfigsUtils isRightToLeftShow] ? kHomeAdvArFolderPath : kHomeAdvEnFolderPath;
}

//判断文件是否存在
+ (BOOL)isFileExistWithFilePath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

- (NSMutableArray *)advsArray {
    if (!_advsArray) {
        _advsArray = [[NSMutableArray alloc] init];
    }
    return _advsArray;
}

#pragma mark - 保存到本地
- (void)saveEventModel:(OSSVAdvsEventsModel *)model {
    
    // 没有图片 及 返回数据弹窗次数为0时，不存储 ，活动卡片
    if ([OSSVNSStringTool isEmptyString:model.imageURL]
        || [model.popupNumber isEqualToString:@"0"]
        || [model.popupType isEqualToString:@"1"]) {
        return;
    }
    
    if(![OSSVAdvsViewsManager isFileExistWithFilePath:[OSSVAdvsViewsManager homeAdvFolerPath]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[OSSVAdvsViewsManager homeAdvFolerPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filepath = [NSString stringWithFormat:@"%@/%@",[OSSVAdvsViewsManager homeAdvFolerPath],[OSSVNSStringTool stringMD5:model.imageURL]];

    int popupSHowNumber = 0;
    BOOL isFileExist = [OSSVAdvsViewsManager isFileExistWithFilePath:filepath];
    if (isFileExist) {
        OSSVAdvsEventsModel *localModel = [self findLocalCurrentAdvModel:model];
        
        // 如果后台修改了弹出数，并且大于本地的
        if ([model.popupNumber integerValue] > [localModel.popupNumber integerValue]) {
            // 本地可弹出次数 需要加上 差值
            int moreCount = [model.popupNumber intValue] - [localModel.popupNumber intValue];
            popupSHowNumber = [localModel.popupShowNumber intValue] + moreCount - 1;
        } else {
            popupSHowNumber = [localModel.popupShowNumber intValue] - 1;
        }
        
    } else {
        popupSHowNumber = [model.popupNumber intValue] - 1;
    }
    
    model.popupShowNumber = [NSString stringWithFormat:@"%d",(popupSHowNumber > 0 ? popupSHowNumber : 0)];

    NSDictionary *jumpDic = [model yy_modelToJSONObject];
    if (!jumpDic) {
        return;
    }
    [jumpDic writeToFile:filepath atomically:YES];
}


#pragma mark  查找本地数据
- (OSSVAdvsEventsModel *)findLocalCurrentAdvModel:(OSSVAdvsEventsModel *)model {
    
    NSArray *localModelArray = [self readLocalAdvEventModels];
    OSSVAdvsEventsModel *currentLockModel = nil;
    NSInteger i = 0;
    while (i < localModelArray.count) {
        OSSVAdvsEventsModel *obj = localModelArray[i];
        if ([model.imageURL isEqualToString:obj.imageURL]) {
            currentLockModel = obj;
            i = localModelArray.count;
        }
        i++;
    }
    return currentLockModel;
}

//读本地保存的数据
- (NSArray *)readLocalAdvEventModels {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:[OSSVAdvsViewsManager homeAdvFolerPath] error:nil];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    int i = 0;
    while (i < files.count) {
        NSString *fileName = files[i];
        
        NSString *filepath = [NSString stringWithFormat:@"%@/%@",[OSSVAdvsViewsManager homeAdvFolerPath],fileName];
        NSDictionary *jumpDic = [NSDictionary dictionaryWithContentsOfFile:filepath];
        
        OSSVAdvsEventsModel *model = [OSSVAdvsEventsModel yy_modelWithDictionary:jumpDic];
        if (model) {
            [tempArray addObject:model];
        }
       i++;
    }

    return tempArray;
}


#pragma mark - 广告状态
- (void)setIsAcrossHome:(BOOL)isAcrossHome {
    _isAcrossHome = isAcrossHome;
    _isNotShowAdv = !isAcrossHome;
}

- (void)setIsEndSheetAdv:(BOOL)isEnd {
    _isEndSheetAdv = isEnd;
}

- (void)showAdv:(BOOL)isShow startOpen:(BOOL)start {
    _isNotShowAdv = !isShow;
    if (start && !_isNotShowAdv) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_HomeAdv object:@"1"];
    }
}

#pragma mark - 显示广告
- (void)showAdvEventModel:(OSSVAdvsEventsModel *)model{
    
    if (self.isUpdateApp) {
        _isNotShowAdv = YES;
        return;
    }
    
    if (self.isLaunchAdv) {
        _isNotShowAdv = YES;
        NSLog(@"------ no no no no no: 启动广告");
        return;
    }
    
    if (self.isNotShowAdv || _isEndSheetAdv) {
        NSLog(@"------ no no no no no");
        if (!_isDidShowHomeBanner) {
            // 显示首页底部banner
            [self handleHomeBottomBanner];
        }
        return;
    }
    if (model.advType == AdverTypeLaunch) {
        return;
    }
    
    if ([model.popupType isEqualToString:@"1"]) {//活动卡片广告
        [self handelActivityCard:model];
    } else {//普通广告
        [self handleCommonAdv:model];
    }
    
}

- (void)removeHomeAdv {
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    for (UIView *windowSubView in window.subviews) {
        if ([windowSubView isKindOfClass:[OSSVHomesActivtyAdvView class]]) {
            [windowSubView removeFromSuperview];
            break;
        }
    }
}

#pragma mark 活动
- (void)handelActivityCard:(OSSVAdvsEventsModel *)model {
    
    self.currentAdvView = nil;
    self.currentModel = model;
    
    if (model.advType == AdverTypeHomeActity) {
        
        self.currentModel = model;
        self.currentAdvView = [self advType:model.advType imageUrl:model.imageURL];
        
        if (!self.currentAdvView) {
            if (STLToString(model.imageURL).length > 0) {
                
                OSSVHomesActivtyAdvView *homeAdv = [self createHomeActivityAdv];
                homeAdv.advEventModel = self.currentModel;
                homeAdv.advDoActionBlock = ^(OSSVAdvsEventsModel *advEventModel,BOOL close) {

                    [self removeAdvsView:advEventModel close:close];
                };
                self.currentAdvView = homeAdv;
                [self.advsArray addObject:homeAdv];
                
                [self downloadImageWithUrl:model.imageURL advType:AdverTypeHomeActity];
            }
        } else {
            
            if (self.currentAdvView.loadedImage) {
                [self showAdvImageUrl:self.currentAdvView.advEventModel.imageURL advType:self.currentAdvView.advEventModel.advType];
            } else {
                [self downloadImageWithUrl:self.currentAdvView.advEventModel.imageURL advType:self.currentAdvView.advEventModel.advType];
            }
        }
    }
    
}

#pragma mark 普通广告
- (void)handleCommonAdv:(OSSVAdvsEventsModel *)model {
    
    // 等于0可以无限显示
    if (![model.popupNumber isEqualToString:@"0"]) {
        //先判断本地的
        OSSVAdvsEventsModel *localModel = [self findLocalCurrentAdvModel:model];
        if (localModel) {
            
            // 如果后台修改了弹出数，并且大于以前的
            if ([model.popupNumber integerValue] <= [localModel.popupNumber integerValue] && localModel.popupShowNumber) {
                if ([localModel.popupShowNumber intValue] <= 0) {//结束
                    _isNotShowAdv = YES;
                    _isEndSheetAdv = YES;
                    return;
                }
            }
        }
    }
    
    self.currentAdvView = nil;
    self.currentModel = model;
    
    if (model.advType == AdverTypeHomeActity) {
        
        self.currentModel = model;
        self.currentAdvView = [self advType:model.advType imageUrl:model.imageURL];
        if (!self.currentAdvView) {
            if (STLToString(model.imageURL).length > 0) {
                
                OSSVHomesActivtyAdvView *homeAdv = [self createHomeActivityAdv];
                homeAdv.advEventModel = self.currentModel;
                homeAdv.advDoActionBlock = ^(OSSVAdvsEventsModel *OSSVAdvsEventsModel,BOOL close) {
                    [self removeAdvsView:OSSVAdvsEventsModel close:close];
                };
                self.currentAdvView = homeAdv;
                [self.advsArray addObject:homeAdv];
                
                [self downloadImageWithUrl:model.imageURL advType:AdverTypeHomeActity];
            }
        } else {
            
            if (self.currentAdvView.loadedImage) {
                [self showAdvImageUrl:self.currentAdvView.advEventModel.imageURL advType:self.currentAdvView.advEventModel.advType];
            } else {
                [self downloadImageWithUrl:self.currentAdvView.advEventModel.imageURL advType:AdverTypeHomeActity];
            }
        }
    }else if (model.advType == AdverTypeHomeBanner){
        if (!_isDidShowHomeBanner) {
            // 显示首页底部banner
            [self handleHomeBottomBanner];
        }
    }
}

#pragma mark ---- 显示首页底部banner
- (void)handleHomeBottomBanner{
    BOOL isSelectedCloseBanner = [[NSUserDefaults standardUserDefaults] boolForKey:kHomeDisplayBanner];
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppFirtOpenBehindInstall"];
    BOOL isFirstDay = [self judgeCurrentDayViewedWithDate:date];
    NSDictionary *homeAdvDic = [OSSVAccountsManager sharedManager].homeBanner;
    if ([homeAdvDic isKindOfClass:[NSDictionary class]]) {
        OSSVAdvsEventsModel *homeAdvEventModel = [OSSVAdvsEventsModel yy_modelWithDictionary:homeAdvDic];
        if (STLJudgeNSDictionary(homeAdvEventModel.info)) {
            homeAdvEventModel.actionType = [[homeAdvDic objectForKey:@"page_type"] integerValue];
            NSInteger firtDayView = [[homeAdvEventModel.info objectForKey:@"first_day_view"] integerValue];
            
            NSString *bannerID = [homeAdvDic objectForKey:@"id"];
            NSString *oldBannerId = [[NSUserDefaults standardUserDefaults] objectForKey:kHomeDisplayBannerID];
            
            BOOL isShow = (firtDayView == 1 && !isSelectedCloseBanner && isFirstDay) || (firtDayView == 0 && !isSelectedCloseBanner);
            if (isShow || ![bannerID isEqualToString:oldBannerId]) {

                if (self.currentAdvView && !self.currentAdvView.isHidden) {
                    return;
                }

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    if (_bannerView) {
                        [_bannerView removeFromSuperview];
                        _bannerView = nil;
                    }
                    self.bannerView = [[OSSVHomesBottomAdvsView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - kTabHeight -(9 + 36), SCREEN_WIDTH, 36)];
                    STLBaseCtrl *baseVC = (STLBaseCtrl *)[OSSVAdvsEventsManager gainTopViewController];
                    if ([baseVC isKindOfClass:[OSSWMHomeVC class ]]) {
                        [baseVC.view addSubview:self.bannerView];
                    }
                    self.bannerView.advEventModel = homeAdvEventModel;
                    [self.bannerView show];
                    @weakify(self);
                    _bannerView.advDoActionBlock = ^(OSSVAdvsEventsModel *OSSVAdvsEventsModel,BOOL close) {
                        @strongify(self);
                        [self removeHomeBanner:OSSVAdvsEventsModel close:close];
                    };
                });
            }
        }
    }
}

// 判断当天与某一天是否相同的时间
- (BOOL)judgeCurrentDayViewedWithDate:(NSDate *)defaultDate{
    return [[NSCalendar currentCalendar] isDate:defaultDate inSameDayAsDate:[NSDate date]];
}

#pragma mark 是否有已显示的弹窗
- (OSSVHomesActivtyAdvView *)advType:(AdverType)advType imageUrl:(NSString *)imageUrl {
    
    OSSVHomesActivtyAdvView *advView = nil;
    NSInteger i = 0;
    while (i < self.advsArray.count) {
        OSSVBasesAdvView *obj = self.advsArray[i];
        if (obj.advEventModel.advType == advType  && [STLToString(imageUrl) isEqualToString:obj.advEventModel.imageURL]) {
            advView = (OSSVHomesActivtyAdvView *)obj;
            i = self.advsArray.count;
        }
        i++;
    }
    return advView;
}

#pragma mark - 首页广告弹窗----事件跳转
- (void)removeAdvsView:(OSSVAdvsEventsModel *)advEventModel close:(BOOL)close {
    if (advEventModel) {
        for (OSSVBasesAdvView *obj in self.advsArray) {
            obj.hidden = YES;
            if (obj.superview) {
                [obj removeFromSuperview];
            }
        }
        [self.advsArray removeAllObjects];
        
        NSString *pageName = [UIViewController currentTopViewControllerPageName];
        NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                     @"attr_node_1":@"home_pop_up",
                                     @"attr_node_2":@"",
                                     @"attr_node_3":@"",
                                     @"position_number":@(0),
                                     @"venue_position":@(0),
                                     @"action_type":@([advEventModel advActionType]),
                                     @"url":[advEventModel advActionUrl],
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDic];
        
        [OSSVAdvsEventsManager advEventTarget:[OSSVAdvsEventsManager gainTopViewController] withEventModel:advEventModel];
        
        //数据GA埋点曝光 广告点击
                            
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
                        //          kFIRParameterPromotionID: $promotionId,
                        //          kFIRParameterPromotionName:$promotionName,
                        //          kFIRParameterCreativeName: $creativeName,
                        //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                        //          @"screen_group":@"Home"
                            } mutableCopy];

                            // Add items
                            promoParams[kFIRParameterItems] = @[item];
                            
                            [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
    }
    
    if (close) {
        [self showAdvEventModel:advEventModel];
    }
}

#pragma mark -- 首页banner弹窗 事件跳转
- (void)removeHomeBanner:(OSSVAdvsEventsModel *)advEventModel close:(BOOL)close {
    if (close) {
        // 关闭按钮
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHomeDisplayBanner];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        // 非关闭按钮
        [OSSVAdvsEventsManager advEventTarget:[OSSVAdvsEventsManager gainTopViewController] withEventModel:advEventModel];
    }
}


#pragma mark - 网络图片加载
//异步线程加载网络下载图片 ——> 回到主线程更新UI
-(void)downloadImageWithUrl:(NSString *)imageDownloadURLStr advType:(AdverType)type{
    
    //先找版本图片
    
    
//    //以便在block中使用
//    __block UIImage *image = [[UIImage alloc] init];
//    //图片下载链接
//    NSURL *imageDownloadURL = [NSURL URLWithString:imageDownloadURLStr];
//
//    //将图片下载在异步线程进行
//    //创建异步线程执行队列
//    dispatch_queue_t asynchronousQueue = dispatch_queue_create("imageDownloadQueue", NULL);
//    //创建异步线程
//    dispatch_async(asynchronousQueue, ^{
//        //网络下载图片  NSData格式
//        NSError *error;
//        NSData *imageData = [NSData dataWithContentsOfURL:imageDownloadURL options:NSDataReadingMappedIfSafe error:&error];
//        if (imageData) {
//            image = [UIImage imageWithData:imageData];
//            //显示GIF图片
//            YYImage *gifImag = [YYImage imageWithData:imageData];
//        }
//        //回到主线程更新UI
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self showAdvImag:image imageUrl:imageDownloadURLStr advType:type];
//        });
//    });
    
    YYAnimatedImageView *tempImgView = [[YYAnimatedImageView alloc] init];
    
    @weakify(self)
    [tempImgView yy_setImageWithURL:[NSURL URLWithString:imageDownloadURLStr]
                                  placeholder:nil
                                      options:YYWebImageOptionShowNetworkActivity
                                     progress:nil
                                    transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                        return image;
                                    }
                                   completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                       @strongify(self)
                                       
                                       if (!error) {
                                           [self showAdvImageUrl:imageDownloadURLStr advType:type];
                                       }
                                   }];
    
}

- (void)showAdvImageUrl:(NSString *)imageDownloadURLStr  advType:(AdverType)type{

    OSSVHomesActivtyAdvView *showAdv = [self advType:type imageUrl:imageDownloadURLStr];
    
    STLBaseCtrl *baseVC = (STLBaseCtrl *)[OSSVAdvsEventsManager gainTopViewController];
    if ([baseVC isKindOfClass:[OSSWMHomeVC class ]]) {
        
        @weakify(self)
        [showAdv.bgImgView yy_setImageWithURL:[NSURL URLWithString:imageDownloadURLStr]
                                  placeholder:[UIImage imageNamed:@"placeholder_pdf"]
                                      options:YYWebImageOptionShowNetworkActivity
                                     progress:nil
                                    transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                        return image;
                                    }
                                   completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                       @strongify(self)
                                       if (!error) {
                                           [self showResultAdv:showAdv];
                                       }

                                   }];
    }
}

- (void)showResultAdv:(OSSVHomesActivtyAdvView *)advView {
    
    //判断当前是首页
    STLBaseCtrl *baseVC = (STLBaseCtrl *)[OSSVAdvsEventsManager gainTopViewController];
    if ([baseVC isKindOfClass:[OSSWMHomeVC class ]] && !_isNotShowAdv && !_isEndSheetAdv) {
        
        _isNotShowAdv = YES;
        _isEndSheetAdv = YES;
        
        [self saveEventModel:advView.advEventModel];
        [WINDOW addSubview:advView];
    }
    ////如果有通知弹窗提示，将它移到最上面
    [STLPushManager jundgePushViewToTop];
}


- (OSSVHomesActivtyAdvView *)createHomeActivityAdv {
    OSSVHomesActivtyAdvView *homeActivityAdvView = [[OSSVHomesActivtyAdvView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    return homeActivityAdvView;
}

#pragma mark -
#pragma mark - 更新状态

- (void)updateAppState:(NSDictionary *)dic {
    
    if ([dic isKindOfClass:[NSDictionary class]]) {
        if ([dic[kStatusCode] integerValue] == kStatusCode_200) {
            
            NSDictionary *resultDic = dic[kResult];
            if ([resultDic isKindOfClass:[NSDictionary class]]) {
                                
                if ([resultDic[@"status"] integerValue] == 1) {
                    NSDictionary *dataDic = resultDic[@"data"];
                    
                    if ([dataDic isKindOfClass:[NSDictionary class]]) {
                        NSString *url = dataDic[@"url"];
                        if (![OSSVNSStringTool isEmptyString:url]) {
                            self.isUpdateApp = YES;
                            self.updateContent = STLToString(dataDic[@"content"]);
                            self.is_force = [dataDic[@"is_force"] boolValue];
                            self.trackUrl = url;
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_UpdateApp object:nil];
                        }
                    }
                }
            }
        }
    }
}

- (void)goUpdateApp {
    
    NSURL *url = [NSURL URLWithString:self.trackUrl];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    
    UIWindow *keyWin = [UIApplication sharedApplication].keyWindow;
    [UIView animateWithDuration:1.0f animations:^{
        keyWin.alpha = 0;
    } completion:^(BOOL finished) {
        exit(0);
    }];
}
@end
