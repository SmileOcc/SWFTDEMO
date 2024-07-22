//
//  ZFPorpularSearchManager.h
//  ZZZZZ
//
//  Created by YW on 2019/7/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFPorpularSearchManager : NSObject
///首页与分类主页导航默认搜索词数据源（5秒更新一次，每次随机取一个词）
@property (nonatomic, strong) NSArray *homePorpularSearchArray;
///搜索页面搜索词数据源（5秒更新一次，每次随机取一个词）
@property (nonatomic, strong) NSArray *porpularSearchArray;

+ (instancetype)sharedManager;

/**
 获取随机搜索热词(首页或分类主页导航)

 @return 热词
 */
- (NSString *)getRandomPorpularSearchKey;
/**
 获取随机搜索热词
 
 @return 热词
 */
- (NSString *)getRandomPorpularSearchKeyWithArray:(NSArray *)porpularArray;

@end

