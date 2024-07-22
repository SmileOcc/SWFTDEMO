//
//  ZFAlbumManager.h
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHFetchResult.h>
#import <Photos/PHCollection.h>
#import <Photos/PHImageManager.h>
#import <Photos/PHAsset.h>
#import <Photos/PHFetchOptions.h>

// 废弃不用
@interface ZFAlbumManager : NSObject

+ (instancetype)sharedManager;


@end

