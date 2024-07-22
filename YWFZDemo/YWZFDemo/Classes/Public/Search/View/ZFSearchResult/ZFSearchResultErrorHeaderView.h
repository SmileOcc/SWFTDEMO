//
//  ZFSearchResultErrorHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2018/6/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 搜索结果容错推荐表头
 */
@interface ZFSearchResultErrorHeaderView : UICollectionReusableView

@property (nonatomic, copy) void (^clickKeywordHandle)(NSString *keyword);
- (void)configWithSearchword:(NSString *)searchword errorKeyword:(NSArray *)keywords;

@end
