//
//  ZFSkinViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/5/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSkinViewModel.h"
#import "UIImage+ZFExtended.h"
#import "YWLocalHostManager.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import <YYWebImage/YYWebImage.h>
#import "NSStringUtils.h"

NSString * const kFolderName                 = @"Skin";// 存储的路径文件夹名
NSString * const kHomeNavBgImageName         = @"navbgImg";
NSString * const kSubNavBgImageName          = @"subnavbgimage";
NSString * const kAccountHeadImageName       = @"accountheadimage";
NSString * const kNavSearchImageName         = @"navsearchimg";
NSString * const kNavBagImageName            = @"navbagimg";
NSString * const kNavLogoImageName           = @"navlogoimg";
NSString * const kTabbarBgImageName          = @"tabbarbgimg";
NSString * const kTabbarHomeImageName        = @"tabbarhomeimg";
NSString * const kTabbarHomeOnImageName      = @"tabbarhomeonimg";
NSString * const kTabbarCommunityImageName   = @"tabbarcommunityimg";
NSString * const kTabbarCommunityOnImageName = @"tabbarcommunityonimg";
NSString * const kTabbarPersonImageName      = @"tabbarpersonimg";
NSString * const kTabbarPersonOnImageName    = @"tabbarpersiononimg";
#define kScreenWidth_SCALE                   (KScreenWidth / 414.0)

@implementation ZFSkinViewModel

+ (void)requestSkinData:(void (^)(ZFSkinModel *))completeHandler {
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_skin);
    [AccountManager sharedManager].currentHomeSkinModel = nil;
    [AccountManager sharedManager].needChangeAppSkin = NO;
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        // 解析数据
        NSDictionary *resultDict = [responseObject ds_dictionaryForKey:@"result"];
        NSInteger resultCode     = [resultDict ds_integerForKey:@"returnCode"];
        if (resultCode != 0) return;
        NSArray *returnInfoArr  = [resultDict ds_arrayForKey:@"returnInfo"];
        if (returnInfoArr.count == 0) return;
        
        NSString *countryId = [resultDict ds_stringForKey:@"countryId"];
        dispatch_queue_t queue = [self downloadQueue];
        dispatch_group_t group = [self downloadGroup];
        
        // 匹配到第一个国家就直接优先下载
        ZFSkinModel *currentCountrySkinModel = nil;
        // 其他国家需要换肤的模型
        NSMutableArray<ZFSkinModel *> *otherCountrySkinModelArray = [NSMutableArray array];
        // 所有国家需要换肤的模型
        NSArray<ZFSkinModel *> *allCountrySkinModelArray = [NSArray yy_modelArrayWithClass:[ZFSkinModel class] json:returnInfoArr];
        // 皮肤url集合
        NSMutableSet<NSString *> *allCountrySkinUrlSet = [[NSMutableSet alloc] init];
        // 
        NSMutableArray *allCountryLoakSinkModelArray = [NSMutableArray array];
        
        // 去重处理操作
        for (ZFSkinModel *skinModel in allCountrySkinModelArray) {
            [allCountrySkinUrlSet addObject:ZFToString(skinModel.bgImg)];
            [allCountrySkinUrlSet addObject:ZFToString(skinModel.navBgImageUrl)];
            [allCountrySkinUrlSet addObject:ZFToString(skinModel.accountHeadImageUrl)];
            [allCountrySkinUrlSet addObject:ZFToString(skinModel.bottomImg)];
            [allCountrySkinUrlSet addObject:ZFToString(skinModel.searchIcon)];
            [allCountrySkinUrlSet addObject:ZFToString(skinModel.cartIcon)];
            [allCountrySkinUrlSet addObject:ZFToString(skinModel.homeLogoIcon)];

            [allCountrySkinUrlSet addObject:ZFToString(skinModel.zomeIcon)];
            [allCountrySkinUrlSet addObject:ZFToString(skinModel.zomeIconOn)];
            [allCountrySkinUrlSet addObject:ZFToString(skinModel.categoryIcon)];
            [allCountrySkinUrlSet addObject:ZFToString(skinModel.categoryIconOn)];
            [allCountrySkinUrlSet addObject:ZFToString(skinModel.personalIcon)];
            [allCountrySkinUrlSet addObject:ZFToString(skinModel.personalIconOn)];
            [allCountrySkinUrlSet addObject:ZFToString(skinModel.communityIcon)];
            [allCountrySkinUrlSet addObject:ZFToString(skinModel.communityIconOn)];
        }
        // 创建皮肤下载标识模型
        [allCountrySkinUrlSet enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            if (!ZFIsEmptyString(obj)) {
                ZFLoadSkinModel *loadSkinModel = [[ZFLoadSkinModel alloc] init];
                loadSkinModel.imageUrl = obj;
                [allCountryLoakSinkModelArray addObject:loadSkinModel];
            }
        }];
        
        [AccountManager sharedManager].loadSinkModelArray = [[NSMutableArray alloc] initWithArray:allCountryLoakSinkModelArray];
        
        for (ZFSkinModel *skinModel in allCountrySkinModelArray) {
            skinModel.countryId = countryId; // 把最外层的国家ID放到每个模型里面
            
            // 需要换肤的国家语言,
            BOOL isShowCurrentLang = [skinModel.lange isEqualToString:[ZFLocalizationString shareLocalizable].nomarLocalizable];
            if (!currentCountrySkinModel && skinModel.isShow && isShowCurrentLang) {
                
                // 需要换肤的国家id, countries为空串或者不存在表示所有国家都支持换肤
                BOOL isShowCurrentCountry = NO;
                if (ZFIsEmptyString(skinModel.countries)) {
                    isShowCurrentCountry = YES;
                } else { //这里的数组切割很大, 可能比较耗时
                    NSArray *countrieIdArr = [skinModel.countries componentsSeparatedByString:@","];
                    if ([countrieIdArr containsObject:countryId]) {
                        isShowCurrentCountry = YES;
                    }
                }
                if (isShowCurrentCountry) {
                    currentCountrySkinModel = skinModel;
                    [self saveModelImages:skinModel
                            downloadQueue:queue
                            downloadGroup:group];
                } else {
                    [otherCountrySkinModelArray addObject:skinModel];
                }
            } else {
                [otherCountrySkinModelArray addObject:skinModel];
            }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (currentCountrySkinModel && completeHandler) {
                YWLog(@"notify：当前换肤任务都完成了");
                completeHandler(currentCountrySkinModel);
            }
            
            YWLog(@"等当前所有的换肤图片都下载完成后再延迟下载其他所有国家换肤数据");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    for (ZFSkinModel *otherSkinModel in otherCountrySkinModelArray) {
                        [self saveModelImages:otherSkinModel
                                downloadQueue:nil
                                downloadGroup:nil];
                    }
                    // 保存当前请求回来的所有换肤国家数据, 便于下次进来是否需要更新下载的图片
                    NSString *skinPath = [self skinModelPath];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager removeItemAtPath:skinPath error:nil];
                    NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:allCountrySkinModelArray];
                    [modelData writeToFile:skinPath atomically:YES];
                });
            });
        });
    } failure:nil];
}

#pragma mark - 数据操作
// 数据模型存储路径
+ (NSString *)skinModelPath {
    return [self createPathWithFileName:@"SkinModel"];
}

// 下载模型相关的所有图片
+ (void)saveModelImages:(ZFSkinModel *)model
          downloadQueue:(dispatch_queue_t)queue
          downloadGroup:(dispatch_group_t)group {
    
    // 首页自定义导航栏顶部图片
    [self loadImageWithQueue:queue
                       group:group
                    imageURL:model.bgImg
                       model:model
                        name:kHomeNavBgImageName];
    
    // 所有子页面系统导航栏顶部图片
    [self loadImageWithQueue:queue
                       group:group
                    imageURL:model.navBgImageUrl
                       model:model
                        name:kSubNavBgImageName];
    
    // 我的页面顶部图片
    [self loadImageWithQueue:queue
                       group:group
                    imageURL:model.accountHeadImageUrl
                       model:model
                        name:kAccountHeadImageName];
    
    // tabbar 背景图片
    [self loadImageWithQueue:queue
                       group:group
                    imageURL:model.bottomImg
                       model:model
                        name:kTabbarBgImageName];
    // 搜索图片
    [self loadImageWithQueue:queue
                       group:group
                    imageURL:model.searchIcon
                       model:model
                        name:kNavSearchImageName];
    // 购物车图片
    [self loadImageWithQueue:queue
                       group:group
                    imageURL:model.cartIcon
                       model:model
                        name:kNavBagImageName];
    // Logo图片
    [self loadImageWithQueue:queue
                       group:group
                    imageURL:model.homeLogoIcon
                       model:model
                        name:kNavLogoImageName];
    // tabbar 首页
    [self loadImageWithQueue:queue
                       group:group
                    imageURL:model.zomeIcon
                       model:model
                        name:kTabbarHomeImageName];
    [self loadImageWithQueue:queue
                       group:group
                    imageURL:model.zomeIconOn
                       model:model
                        name:kTabbarHomeOnImageName];
    // tabbar 社区
    [self loadImageWithQueue:queue
                       group:group
                    imageURL:model.communityIcon
                       model:model
                        name:kTabbarCommunityImageName];
    [self loadImageWithQueue:queue
                       group:group
                    imageURL:model.communityIconOn
                       model:model
                        name:kTabbarCommunityOnImageName];
    // tabbar 个人中心
    [self loadImageWithQueue:queue
                       group:group
                    imageURL:model.personalIcon
                       model:model
                        name:kTabbarPersonImageName];
    [self loadImageWithQueue:queue
                       group:group
                    imageURL:model.personalIconOn
                       model:model
                        name:kTabbarPersonOnImageName];
}

/**
 判断当前图片链接是否在下载
 */
+ (BOOL)currentImageUrlIsLoading:(NSString *)imageUrl {
    if ([AccountManager sharedManager].loadSinkModelArray && !ZFIsEmptyString(imageUrl)) {
        __block BOOL isLoading = NO;
        [[AccountManager sharedManager].loadSinkModelArray enumerateObjectsUsingBlock:^(ZFLoadSkinModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.imageUrl isEqualToString:imageUrl]) {
                if (obj.loading) {
                    isLoading = YES;
                } else {
                    isLoading = NO;
                }
                obj.loading = YES;
                *stop = YES;
            }
        }];
        
        return isLoading;
    }
    return NO;
}

+ (void)loadImageWithQueue:(dispatch_queue_t)queue
                     group:(dispatch_group_t)group
                  imageURL:(NSString *)imageURL
                     model:(ZFSkinModel *)skinModel
                      name:(NSString *)name {
    if (ZFIsEmptyString(imageURL)) return;
    
    BOOL isLoading = [ZFSkinViewModel currentImageUrlIsLoading:imageURL];
    if (isLoading) {
        YWLog(@"当前需要的换肤: %@ 正在下载",imageURL);
        return;
    }
    
    NSString *suffix   = [[imageURL componentsSeparatedByString:@"."] lastObject];
    NSString *fileName = [NSStringUtils ZFNSStringMD5:imageURL];
    fileName = [NSString stringWithFormat:@"%@.%@",fileName,suffix];
    
    NSString *filePath = [self path];
    filePath           = [filePath stringByAppendingPathComponent:fileName];
    BOOL isNeedSaved   = NO;  // 是否需要存储
    BOOL isUpdate      = NO;  // 是否强制更新,获取远程数据
    
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    // 是否已经保存有
    if (image == nil) {
        isNeedSaved = YES;
    } else if ([self isNeedToUpdate:skinModel]) {
        // 是否需要重新保存
        isNeedSaved = YES;
        isUpdate = YES;
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        [defaultManager removeItemAtPath:filePath error:nil];
    }
    
    YWLog(@"\n皮肤缓存文件路径： %@   国家id: %ld   已存在：%i imgUrl: %@,  fileName: %@ \n",filePath,skinModel.ID,!isNeedSaved,imageURL,fileName);
    
    if (!isNeedSaved) {
        YWLog(@"不需要重新下载图片");
        return;
    }
    
    if (group && queue) {
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            YWLog(@"dispatch_group下载当前需要的换肤");
            [self downloadImage:imageURL fileName:fileName update:isUpdate block:^{
                dispatch_group_leave(group);
            }];
        });
    } else {
        if (![NSThread isMainThread]) {
            YWLog(@"在其他队列子线程下载非当前需要的换肤");
            [self downloadImage:imageURL fileName:fileName update:isUpdate block:^{
            }];
        }
    }
}

/**
 * 下载皮肤图片
 * update: YES 忽略缓存下载【远程】
 */
+ (void)downloadImage:(NSString *)imageURL fileName:(NSString *)fileName update:(BOOL)update block:(void (^)(void))completion {

    // 去除首尾空格和换行：
    imageURL = [imageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    YYWebImageOptions options = update ? YYWebImageOptionShowNetworkActivity | YYWebImageOptionIgnoreDiskCache : YYWebImageOptionShowNetworkActivity;
    [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:imageURL] options:options progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        
        
        if (image) {
            YWLog(@"--------皮肤下载来源： %lu",(unsigned long)from);

            NSData *imageData;
            if ([image isKindOfClass:[YYImage class]]) {
                YYImage *tempImage = (YYImage *)image;
                if (tempImage.animatedImageData) {// 是GIF图片
                    imageData = tempImage.animatedImageData;
                } else {
                    imageData = UIImagePNGRepresentation(image);
                }
            } else {
                imageData = UIImagePNGRepresentation(image);
            }

            NSString *filePath = [self createPathWithFileName:fileName];
            BOOL isSaved = [imageData writeToFile:filePath atomically:NO];
            YWLog(@"imageName:%@ \n=存储=%d=%@=%@", filePath,isSaved, url, [NSThread currentThread]);
        }
        if (completion) {
            completion();
        }
    }];
}

/**
 * 耗时下载保存图片
 */
+ (void)downloadImage:(NSString *)imageURL fileName:(NSString *)fileName {
        NSURL *url = [NSURL URLWithString:imageURL];
        NSData *imageData  = [[NSData alloc] initWithContentsOfURL:url];
        UIImage *targetImage = [UIImage imageWithData:imageData];
        if (targetImage != nil) {
            BOOL isSaved = [imageData writeToFile:[self createPathWithFileName:fileName] atomically:NO];
            YWLog(@"\n=存储=%d=%@=%@", isSaved, url, [NSThread currentThread]);
        }
}

// 数据保存的文件夹路径
+ (NSString *)path {
    NSString *userDocument = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *directryPath = [userDocument stringByAppendingPathComponent:kFolderName];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:directryPath] == NO) {
        [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return directryPath;
}

// 创建文件路径
+ (NSString *)createPathWithFileName:(NSString *)fileName {
    NSString *path = [self path];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath] == NO) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    //YWLog(@"换肤数据保存路径: %@", filePath);
    return filePath;
}

// 是否需要更新
+ (BOOL)isNeedToUpdate:(ZFSkinModel *)model {
    BOOL isNeed = NO;
    NSArray *modelArray = [AccountManager sharedManager].appSkinModelArray;
    for (ZFSkinModel *skinModel in modelArray) {
        if (model.ID == skinModel.ID
            && ![model.lastUpdateTime isEqualToString:skinModel.lastUpdateTime]) {
            isNeed = YES;
            break;
        }
    }
    return isNeed;
}

+ (void)isNeedToShow:(void(^)(BOOL need))completeHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *navBgImage           = [ZFSkinViewModel navigationBgImage];
        UIImage *searchImage          = [ZFSkinViewModel searchImage];
        UIImage *bagImage             = [ZFSkinViewModel bagImage];
        YYImage *logoImage            = [ZFSkinViewModel logoImage];
        
        UIImage *tabbarBgImage          = [ZFSkinViewModel tabbarBgImage];
        UIImage *tabbarHomeImage        = [ZFSkinViewModel tabbarHomeImage];
        UIImage *tabbarHomeOnImage      = [ZFSkinViewModel tabbarHomeOnImage];
        UIImage *tabbarCommunityImage   = [ZFSkinViewModel tabbarCommunityImage];
        UIImage *tabbarCommunityOnImage = [ZFSkinViewModel tabbarCommunityOnImage];
        UIImage *tabbarPersonImage      = [ZFSkinViewModel tabbarPersonImage];
        UIImage *tabbarPersonOnImage    = [ZFSkinViewModel tabbarPersonOnImage];
        
        ZFSkinModel *appHomeSkinModel = [AccountManager sharedManager].currentHomeSkinModel;
        BOOL isNav1    = navBgImage != nil && appHomeSkinModel.bgUseType == 2;
        BOOL isNav2    = [appHomeSkinModel.bgColor length] > 0 && appHomeSkinModel.bgUseType == 1;
        BOOL isTabbar1 = tabbarBgImage != nil && appHomeSkinModel.bottomUseType == 2;
        BOOL isTabbar2 = [appHomeSkinModel.bottomColor length] > 0 && appHomeSkinModel.bottomUseType == 1;
        
        BOOL isShow = (searchImage != nil
                       && bagImage != nil
                       && logoImage != nil
                       && tabbarHomeImage != nil
                       && tabbarHomeOnImage != nil
                       && tabbarCommunityImage != nil
                       && tabbarCommunityOnImage != nil
                       && tabbarPersonImage != nil
                       && tabbarPersonOnImage != nil);
        isShow = isShow && (isNav1 || isNav2) && (isTabbar1 || isTabbar2);
        if (completeHandler) {
            completeHandler(isShow);
        }
    });
}

#pragma mark getter 获取图片

// 导航logo
+ (YYImage *)logoImage {
    return (YYImage *)[ZFSkinViewModel fetchSaveFileImageWithKey:kNavLogoImageName];
}

// 我的页面顶部图片
+ (UIImage *)accountHeadImage {
    return [ZFSkinViewModel fetchSaveFileImageWithKey:kAccountHeadImageName];
}

// 所有子页面导航栏图片
+ (UIImage *)subNavigationBgImage {
    return [ZFSkinViewModel fetchSaveFileImageWithKey:kSubNavBgImageName];
}

// 首页自定义导航栏顶部图片
+ (UIImage *)navigationBgImage {
    return [ZFSkinViewModel fetchSaveFileImageWithKey:kHomeNavBgImageName];
}

// tabbar 背景图
+ (UIImage *)tabbarBgImage {
    return [ZFSkinViewModel fetchSaveFileImageWithKey:kTabbarBgImageName];
}

// 搜索图
+ (UIImage *)searchImage {
    return [ZFSkinViewModel fetchSaveFileImageWithKey:kNavSearchImageName];
}

// 购物车图
+ (UIImage *)bagImage {
    return [ZFSkinViewModel fetchSaveFileImageWithKey:kNavBagImageName];
}

// tabbar Home 常规图
+ (UIImage *)tabbarHomeImage {
    return [ZFSkinViewModel fetchSaveFileImageWithKey:kTabbarHomeImageName];
}

// tabbar Home 高亮图
+ (UIImage *)tabbarHomeOnImage {
    return [ZFSkinViewModel fetchSaveFileImageWithKey:kTabbarHomeOnImageName];
}

// tabbar 社区 常规图
+ (UIImage *)tabbarCommunityImage {
    return [ZFSkinViewModel fetchSaveFileImageWithKey:kTabbarCommunityImageName];
}

// tabbar 社区 高亮图
+ (UIImage *)tabbarCommunityOnImage {
    return [ZFSkinViewModel fetchSaveFileImageWithKey:kTabbarCommunityOnImageName];
}

// tabbar 个人中心 常规图
+ (UIImage *)tabbarPersonImage {
    return [ZFSkinViewModel fetchSaveFileImageWithKey:kTabbarPersonImageName];
}

// tabbar 个人中心 高亮图
+ (UIImage *)tabbarPersonOnImage {
    return [ZFSkinViewModel fetchSaveFileImageWithKey:kTabbarPersonOnImageName];
}

// 根据图片key名字获取保存在沙盒的文件名
+ (UIImage *)fetchSaveFileImageWithKey:(NSString *)imageKey {
    NSString *imgURL = nil;
    BOOL convertToBigSize = NO;
    BOOL forbidConvertSize = NO;//支持gif图片
    ZFSkinModel *currentSkinModel = [AccountManager sharedManager].currentHomeSkinModel;
    
    if ([imageKey isEqualToString:kAccountHeadImageName]) {
        imgURL = currentSkinModel.accountHeadImageUrl;
        convertToBigSize = YES;
        forbidConvertSize = YES;
        
    } else if ([imageKey isEqualToString:kSubNavBgImageName]) {
        imgURL = currentSkinModel.navBgImageUrl;
        convertToBigSize = YES;
        
    } else if ([imageKey isEqualToString:kHomeNavBgImageName]) {
        imgURL = currentSkinModel.bgImg;
        convertToBigSize = YES;
        forbidConvertSize = YES;//V5.0.0处理为支持gif图片
        
    } else if ([imageKey isEqualToString:kNavSearchImageName]) {
        imgURL = currentSkinModel.searchIcon;
        
    } else if ([imageKey isEqualToString:kNavBagImageName]) {
        imgURL = currentSkinModel.cartIcon;
        
    } else if ([imageKey isEqualToString:kNavLogoImageName]) {
        imgURL = currentSkinModel.homeLogoIcon;
        forbidConvertSize = YES;
        
    } else if ([imageKey isEqualToString:kTabbarBgImageName]) {
        imgURL = currentSkinModel.bottomImg;
        convertToBigSize = YES;
        
    } else if ([imageKey isEqualToString:kTabbarHomeImageName]) {
        imgURL = currentSkinModel.zomeIcon;
        
    } else if ([imageKey isEqualToString:kTabbarHomeOnImageName]) {
        imgURL = currentSkinModel.zomeIconOn;
        
    } else if ([imageKey isEqualToString:kTabbarCommunityImageName]) {
        imgURL = currentSkinModel.communityIcon;
        
    } else if ([imageKey isEqualToString:kTabbarCommunityOnImageName]) {
        imgURL = currentSkinModel.communityIconOn;
        
    } else if ([imageKey isEqualToString:kTabbarPersonImageName]) {
        imgURL = currentSkinModel.personalIcon;
        
    } else if ([imageKey isEqualToString:kTabbarPersonOnImageName]) {
        imgURL = currentSkinModel.personalIconOn;
    }
    
    NSString *suffix = [[imgURL componentsSeparatedByString:@"."] lastObject];
    NSString *fileName = [NSStringUtils ZFNSStringMD5:imgURL];
    fileName = [NSString stringWithFormat:@"%@.%@",fileName,suffix];
    
    NSString *path = [[ZFSkinViewModel path] stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (forbidConvertSize && data) { // 首页logo, 个人中心顶部背景图 单独处理
        return [YYImage imageWithData:data scale:3.0];
    }
    // 转换图片大小
    UIImage *originImage = [UIImage imageWithData:data scale:3.0];
    if (![originImage isKindOfClass:[UIImage class]]) return nil;
    
    if (convertToBigSize) {
        return [UIImage zf_drawImage:originImage size:CGSizeMake(KScreenWidth, KScreenWidth * originImage.size.height / originImage.size.width)];
    } else {
        return [UIImage zf_drawImage:originImage size:CGSizeMake(originImage.size.width * kScreenWidth_SCALE, originImage.size.height * kScreenWidth_SCALE)];;
    }
}


// 清除首页换肤缓存
+ (void)clearCacheFile {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [self path];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:folderPath error:NULL];
    NSEnumerator*e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        [fileManager removeItemAtPath:[folderPath stringByAppendingPathComponent:filename] error:NULL];
    }
}

+ (dispatch_queue_t)downloadQueue {
    static dispatch_once_t onceToken;
    static dispatch_queue_t queue = nil;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("download.image.com", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

+ (dispatch_group_t)downloadGroup {
    static dispatch_once_t onceToken;
    static dispatch_group_t group = nil;
    dispatch_once(&onceToken, ^{
        group = dispatch_group_create();
    });
    return group;
}

@end
