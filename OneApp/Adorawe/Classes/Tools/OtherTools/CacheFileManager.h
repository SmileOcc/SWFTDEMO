//
//  CacheFileManager.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/15.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheFileManager : NSObject
+ (CGFloat)fileSizeAtPath:(NSString *)path;

+ (CGFloat)folderSizeAtPath:(NSString *)path;

+ (void)clearCache:(NSString *)path;

+ (void)clearDatabaseCache:(NSString *)path;
@end
