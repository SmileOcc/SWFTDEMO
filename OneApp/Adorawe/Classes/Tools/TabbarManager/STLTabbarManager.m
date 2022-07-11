//
//  STLTabbarManager.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLTabbarManager.h"
#import <sys/utsname.h>
#import "NSString+File.h"
#import "AFImageDownloader.h"

@interface STLTabbarManager ()

@property (strong, nonatomic) STLTabbarViewModel *viewModel;

@end

@implementation STLTabbarManager

+ (instancetype)sharedInstance
{
    static STLTabbarManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[STLTabbarManager alloc] init];
    });
    return instance;
}

- (void)setUp {
    self.type = [self getDeviceType];
    self.model = [[STLTabbarModel alloc] init];
    
    [self.viewModel loadOnlineIconCompletion:^(id obj) {
        if([obj isKindOfClass:STLTabbarModel.class]) {
            
                STLTabbarModel *model = (STLTabbarModel *)obj;

                if (model.isCache) {
                    self.model = model;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_LoadFinishTabbarIcon object:self userInfo:@{@"model":model}];
                } else {
                    [self cacheAllImage:model];
                }
            }
        }
     failure:^(id obj) {
         
     }];
}

- (STLDeviceImageType)getDeviceType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];

    [OSSVAccountsManager sharedManager].iosplatform = platform;
    
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"]) {
        if (kIS_IPHONEX) {
            return STLDeviceImageTypeIphoneX;
            
        } else if (IPHONE_6P_5_5) {
            return STLDeviceImageType3X;
            
        } else {
            return STLDeviceImageType2X;
        }
    }
    
    if([platform isEqualToString:@"iPhone10,6"] || [platform isEqualToString:@"iPhone10,3"])
    {
        return STLDeviceImageTypeIphoneX;
    } else if ([platform isEqualToString:@"iPhone7,1"]
             ||[platform isEqualToString:@"iPhone8,2"]
             ||[platform isEqualToString:@"iPhone9,2"]
             ||[platform isEqualToString:@"iPhone10,2"]
             ||[platform isEqualToString:@"iPhone10,5"]) {
        return STLDeviceImageType3X;
    } else {
        return STLDeviceImageType2X;
    }
}

-(void)cacheAllImage:(STLTabbarModel *)model {
    dispatch_group_t group = dispatch_group_create();
    __block NSInteger index = 0;
    ///tabbar部分的缓存
    dispatch_group_enter(group);
    [self cacheTabbarIcon:model complation:^(BOOL status){
        if (status) {
            index++;
            DLog(@"tabbar下载成功");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TabbarDownLoadSuccess];
        } else {
            DLog(@"tabbar下载失败");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TabbarDownLoadSuccess];
        }
        dispatch_group_leave(group);
        DLog(@"status tabbar = %d", status);
    }];
    
    ///首页顶部部分的缓存
    dispatch_group_enter(group);
    [self cacheHomeHeaderIcon:model complation:^(BOOL status)
     {
        if (status)
        {
            index++;
            DLog(@"我的首页下载成功");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NaviBarDownLoadSuccess];
        }
        else
        {
            DLog(@"我的首页下载失败");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:NaviBarDownLoadSuccess];
        }
        dispatch_group_leave(group);
        DLog(@"status HomeHeaderIcon = %d", status);
    }];

    ///我的视图顶部style缓存
    dispatch_group_enter(group);
    [self cacheAccountHeaderIcon:model complation:^(BOOL status)
    {
        if (status)
        {
            index++;
            DLog(@"我的视图下载成功");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AccountDownLoadSuccess];
        }
        else
        {
            DLog(@"我的视图下载失败");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:AccountDownLoadSuccess];
        }
        dispatch_group_leave(group);
        DLog(@"status AccountHeaderIcon = %d", status);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (index == 3)
        {
            DLog(@"全部下载成功");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DownLoadSuccess];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DownLoadSuccess];
        }
    });
    
}
#pragma mark - private method

-(void)cacheTabbarIcon:(STLTabbarModel *)model complation:(void(^)(BOOL status))complation
{
    if (!model.body)
    {
        if (complation)
        {
            complation(NO);
        }
        return;
    }
    STLTabbarManager *manager = [STLTabbarManager sharedInstance];

    __block NSInteger totalSuccess = 0;
    dispatch_queue_t queue1 = dispatch_queue_create("dispatchGroupMethod1.queue1", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_t group1 = dispatch_group_create();
    NSString *tabbarBgImgUrl = @"";
    if (manager.type == STLDeviceImageType3X ){
        tabbarBgImgUrl = model.body.backgroup_url_3x?:@"";
        
    }else if (manager.type == STLDeviceImageTypeIphoneX) {
        tabbarBgImgUrl = model.body.backgroup_url_iphonex?:@"";
        
    }else{
        tabbarBgImgUrl = model.body.backgroup_url_2x?:@"";
    }
    
    dispatch_group_async(group1, queue1, ^{
        [self downloadCacheImage:tabbarBgImgUrl size:CGSizeZero dispatch:group1 complation:^(BOOL status) {
            if (status) {
                totalSuccess++;
            }
        }];
    });
  
    dispatch_group_async(group1, queue1, ^{
        for (NSInteger i = 0 ;i < model.body.imgs_url_3x.count; i ++) {
            NSString *normalUrl = @"";
            if (manager.type == STLDeviceImageTypeIphoneX || manager.type == STLDeviceImageType3X )
            {
                normalUrl = [model.body.imgs_url_3x objectAtIndex:i];
            }
            else
            {
                normalUrl = [model.body.imgs_url_2x objectAtIndex:i];
            }
            [self downloadCacheImage:normalUrl size:CGSizeZero dispatch:group1 complation:^(BOOL status) {
                if (status) {
                    totalSuccess++;
                }
            }];
        }
        
        for (NSInteger i = 0 ;i < model.body.imgs_url_3x.count; i ++)
        {
            NSString *selectedUrl = @"";
            if (manager.type == STLDeviceImageTypeIphoneX || manager.type == STLDeviceImageType3X )
            {
                selectedUrl = [model.body.imgs_url_selected_3x objectAtIndex:i];
            }
            else
            {
                selectedUrl = [model.body.imgs_url_selected_2x objectAtIndex:i];
            }
            [self downloadCacheImage:selectedUrl size:CGSizeZero dispatch:group1 complation:^(BOOL status) {
                if (status) {
                    totalSuccess++;
                }
            }];
        }
    });
    
    dispatch_group_notify(group1, dispatch_get_main_queue(), ^{
        if (totalSuccess == model.body.imgs_url_3x.count * 2 + 1) {
            ///totalSuccess从0开始
            ///当全部成功的数量等于需要更新的icon数量
            ///背景图1 + icon数量5
            if (complation)
            {
                complation(YES);
            }
        }
        else
        {
            if (complation)
            {
                complation(NO);
            }
        }
    });
}

-(void)cacheHomeHeaderIcon:(STLTabbarModel *)model complation:(void(^)(BOOL status))complation
{
    if (!model.title_bar) {
        if (complation) {
            complation(NO);
        }
        return;
    }
    STLTabbarManager *manager = [STLTabbarManager sharedInstance];
    NSString *titleUrl = @"";
    NSString *searchUrl = @"";
    NSString *naviBgUrl = @"";
    NSString *messageUrl = @"";
    
    if (manager.type == STLDeviceImageTypeIphoneX)
    {
        titleUrl = model.title_bar.logo_url_3x?:@"";
        searchUrl = model.title_bar.search_url_3x?:@"";
        naviBgUrl = model.title_bar.bg_img_url_iphonx?:@"";
        messageUrl = model.title_bar.message_url_3x?:@"";
    }
    else if (manager.type == STLDeviceImageType3X)
    {
        titleUrl = model.title_bar.logo_url_3x?:@"";
        searchUrl = model.title_bar.search_url_3x?:@"";
        naviBgUrl = model.title_bar.bg_img_url_3x?:@"";
        messageUrl = model.title_bar.message_url_3x?:@"";
    }
    else
    {
        titleUrl = model.title_bar.logo_url_2x?:@"";
        searchUrl = model.title_bar.search_url_2x?:@"";
        naviBgUrl = model.title_bar.bg_img_url_2x?:@"";
        messageUrl = model.title_bar.message_url_2x?:@"";
    }

    //不是缓存的情况，先把图片全部用YY缓存一遍
    __block NSInteger totalSuccess = 0;
    dispatch_queue_t queue1 = dispatch_queue_create("dispatchGroupMethod1.queue2", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_t group1 = dispatch_group_create();

    
    dispatch_group_async(group1, queue1, ^{
        [self downloadCacheImage:searchUrl size:CGSizeZero dispatch:group1 complation:^(BOOL status) {
            if (status) {
                totalSuccess++;
            }
        }];
    });
    
    dispatch_group_async(group1, queue1, ^{
        [self downloadCacheImage:naviBgUrl size:CGSizeZero dispatch:group1 complation:^(BOOL status) {
            if (status) {
                totalSuccess++;
            }
        }];
    });
 
    dispatch_group_async(group1, queue1, ^{
        [self downloadCacheImage:titleUrl size:CGSizeZero dispatch:group1 complation:^(BOOL status) {
            if (status) {
                totalSuccess++;
            }
        }];
    });
    
    dispatch_group_async(group1, queue1, ^{
        [self downloadCacheImage:messageUrl size:CGSizeZero dispatch:group1 complation:^(BOOL status) {
            if (status) {
                totalSuccess++;
            }
        }];
    });

    dispatch_group_notify(group1, dispatch_get_main_queue(), ^{
        if (totalSuccess == 4) {
            if (complation) {
                complation(YES);
            }
        }else{
            if (complation) {
                complation(NO);
            }
        }
    });
}

-(void)cacheAccountHeaderIcon:(STLTabbarModel *)model complation:(void(^)(BOOL status))complation
{
    if (!model.my_header)
    {
        if (complation)
        {
            complation(NO);
        }
        return;
    }
    STLTabbarManager *manager = [STLTabbarManager sharedInstance];
    NSString *defaultAvatarUrl = (manager.type == STLDeviceImageType3X ||manager.type ==  STLDeviceImageTypeIphoneX)?model.my_header.default_avatar_url_3x:model.my_header.default_avatar_url_2x;
    NSString *bgImgUrl = (manager.type ==  STLDeviceImageType3X ||manager.type ==  STLDeviceImageTypeIphoneX)?model.my_header.bg_img_url_3x:model.my_header.bg_img_url_2x;
    
    __block NSInteger downloadIndex = 0;
    dispatch_queue_t queue1 = dispatch_queue_create("dispatchGroupMethod1.queue3", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_t group1 = dispatch_group_create();
    if ([OSSVNSStringTool isEmptyString:[OSSVAccountsManager sharedManager].account.avatar])
    {
        dispatch_group_async(group1, queue1, ^{
            [self downloadCacheImage:defaultAvatarUrl size:CGSizeZero dispatch:group1 complation:^(BOOL status) {
                if (status) {
                    downloadIndex++;
                }
            }];
        });
    }
    
    dispatch_group_async(group1, queue1, ^{
        [self downloadCacheImage:bgImgUrl size:CGSizeZero dispatch:group1 complation:^(BOOL status) {
            if (status) {
                downloadIndex++;
            }
        }];
    });
    
    dispatch_group_notify(group1, dispatch_get_main_queue(), ^{
        NSInteger comparIndex = 1;
        if ([OSSVNSStringTool isEmptyString:[OSSVAccountsManager sharedManager].account.avatar])
        {
            comparIndex = 2;
        }
        if (downloadIndex == comparIndex)
        {
            if (complation)
            {
                complation(YES);
            }
        }
        else
        {
            if (complation)
            {
                complation(NO);
            }
        }
    });
}

-(void)downloadCacheImage:(NSString *)url size:(CGSize)size dispatch:(dispatch_group_t)group complation:(void(^)(BOOL status))complation
{
    YYImageCache *imageCache = [YYImageCache sharedCache];
    dispatch_group_enter(group);
    UIImage *image = [imageCache getImageForKey:url withType:YYImageCacheTypeDisk];
    if (image)
    {
        complation ? complation(YES) : nil;
        dispatch_group_leave(group);
    }
    else
    {
        NSURLRequest *requestSelect = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        AFImageDownloadReceipt *receiptSelectImage = [[AFImageDownloader defaultInstance] downloadImageForURLRequest:requestSelect
                                                                                                             success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
                                                                                                                 if (size.width != 0)
                                                                                                                 {
                                                                                                                     responseObject = [responseObject yy_imageByResizeToSize:size contentMode:UIViewContentModeScaleAspectFill];
                                                                                                                 }
                                                                                                                 [imageCache setImage:responseObject imageData:nil forKey:url withType:YYImageCacheTypeDisk];
                                                                                                                 complation ? complation(YES) : nil;
                                                                                                                 dispatch_group_leave(group);
                                                                                                             }
                                                                                                             failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                                                                                                 complation ? complation(NO) : nil;
                                                                                                                 dispatch_group_leave(group);
                                                                                                             }];
        [receiptSelectImage.task resume];
    }
}

#pragma mark - setter and getter

- (STLTabbarViewModel *)viewModel
{
    if (!_viewModel)
    {
        _viewModel = [[STLTabbarViewModel alloc] init];
    }
    return _viewModel;
}
@end
