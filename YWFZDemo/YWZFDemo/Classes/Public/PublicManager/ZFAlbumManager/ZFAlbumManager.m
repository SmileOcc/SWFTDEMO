//
//  ZFAlbumManager.m
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAlbumManager.h"

@implementation ZFAlbumManager

+ (instancetype)sharedManager {
    static ZFAlbumManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZFAlbumManager alloc] init];
    });
    
    return manager;
}

- (void)isAuth:(void (^)(BOOL isAuth))completion {
        //用户权限允许后回调
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            /// 用户开通了权限
            YWLog(@"------ 用户已开通权限");
            if (completion) {
                completion(YES);
            }
        }else{
            /// 用户没有开通权限
            YWLog(@"------ 用户没开通权限");
            if (completion) {
                completion(NO);
            }
        }
    }];
}


/**
 *  获得所有相簿中的缩略图
 */
- (void)getThumbnailImages
{
    // 获得所有的自定义相簿
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
  /***与上面结果一样
  PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
  PHFetchResult *smartAlbumsFetchResult1 = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:fetchOptions];
  ***/
    // 遍历所有的自定义相簿也可以遍历自己需要的相簿
    for (PHAssetCollection *assetCollection in assetCollections) {
        YWLog(@"-----1111 相册组名： %@",assetCollection.localizedTitle);

//        if ([assetCollection.localizedTitle isEqualToString:@"微博"]) {
//            [self enumerateAssetsInAssetCollection:assetCollection original:NO];
//        }
    }
    
    // 获得相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    [self enumerateAssetsInAssetCollection:cameraRoll original:NO];
}

/**
 *  遍历相簿中的所有图片
 *
 *  @param assetCollection 相簿
 *  @param original        是否要原图
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
    YWLog(@"-相簿名:%@", assetCollection.localizedTitle);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    for (PHAsset *asset in assets) {
        // 是否要原图
        CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
        
        // 从asset中获得图片
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            YWLog(@"%@,info%@", result,info);
        }];
    }
}

/**
 *  获得相机胶卷中的所有图片
 */
- (void)getImagesFromCameraRoll
{
    // 获得相机胶卷中的所有图片
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithOptions:nil];
    
    __block int count = 0;
    
    YWLog(@"---相机胶卷中的所有图片数： %lu",(unsigned long)assets.count)
    for (PHAsset *asset in assets) {
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            YWLog(@"相机胶卷 %@ - %d", result, count++);
        }];
    }
}

@end
