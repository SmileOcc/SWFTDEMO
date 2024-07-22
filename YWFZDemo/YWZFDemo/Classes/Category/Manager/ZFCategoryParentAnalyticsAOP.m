//
//  ZFCategoryParentAnalyticsAOP.m
//  ZZZZZ
//
//  Created by 602600 on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCategoryParentAnalyticsAOP.h"
#import "ZFAnalytics.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFCategoryParentBannerCell.h"
#import "ZFChildCateCollectionViewCell.h"
#import "YWCFunctionTool.h"
#import "ZFSuperCateViewCell.h"

@interface ZFCategoryParentAnalyticsAOP ()

@property (nonatomic, strong) NSMutableArray *categoryAnalyticsSet;

@end

@implementation ZFCategoryParentAnalyticsAOP

- (void)after_viewWillAppear:(BOOL)animated {
    //谷歌统计
    [ZFAnalytics screenViewQuantityWithScreenName:@"Category"];
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFCategoryTabContainer *tabContainer = nil;
    if ([cell isKindOfClass:[ZFCategoryParentBannerCell class]]) {
        ZFCategoryParentBannerCell *bannerCell = (ZFCategoryParentBannerCell *)cell;
        tabContainer = bannerCell.tabContainer;
    } else if ([cell isKindOfClass:[ZFChildCateCollectionViewCell class]]) {
        ZFChildCateCollectionViewCell *childCell = (ZFChildCateCollectionViewCell *)cell;
        tabContainer = childCell.tabContainer;
    }
    
    if (tabContainer && ![self.categoryAnalyticsSet containsObject:ZFToString(tabContainer.tabContainerId)]) {
        [self.categoryAnalyticsSet addObject:ZFToString(tabContainer.tabContainerId)];
        NSString *catIds = @"";
        NSString *catNames = @"";
        for (NSString *catId in tabContainer.categoryIds) {
            if (!ZFIsEmptyString(catId)) {
                catIds = [NSString stringWithFormat:@"%@%@,", catIds, catId];
            }
        }
        if (catIds.length > 0) {
            catIds = [catIds substringToIndex:catIds.length-1];
        }
        
        for (NSString *catName in tabContainer.categoryNames) {
            if (!ZFIsEmptyString(catName)) {
                catNames = [NSString stringWithFormat:@"%@%@,", catNames, catName];
            }
        }
        if (catNames.length > 0) {
            catNames = [catNames substringToIndex:catNames.length-1];
        }
        
        // 统计
        NSDictionary *appsflyerParams = @{@"af_content_type" : @"Vitural_Catentrance_impression",
                                          @"af_cat_id"       : ZFToString(catIds),
                                          @"af_cat_name"     : ZFToString(catNames),
                                          @"af_catentrance_type": ZFToString(tabContainer.actionType),
                                          @"af_cat_level"       : @"2",
                                          @"af_text"            : ZFToString(tabContainer.text),
        };
        
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_Catentrance_impression" withValues:appsflyerParams];
    }
}

- (void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    ZFCategoryTabContainer *tabContainer = nil;
    if ([cell isKindOfClass:[ZFCategoryParentBannerCell class]]) {
        ZFCategoryParentBannerCell *bannerCell = (ZFCategoryParentBannerCell *)cell;
        tabContainer = bannerCell.tabContainer;
    } else if ([cell isKindOfClass:[ZFChildCateCollectionViewCell class]]) {
        ZFChildCateCollectionViewCell *childCell = (ZFChildCateCollectionViewCell *)cell;
        tabContainer = childCell.tabContainer;
    }
    
    if (tabContainer) {
        NSString *catIds = @"";
        NSString *catNames = @"";
        for (NSString *catId in tabContainer.categoryIds) {
            if (!ZFIsEmptyString(catId)) {
                catIds = [NSString stringWithFormat:@"%@%@,", catIds, catId];
            }
        }
        if (catIds.length > 0) {
            catIds = [catIds substringToIndex:catIds.length-1];
        }
        
        for (NSString *catName in tabContainer.categoryNames) {
            if (!ZFIsEmptyString(catName)) {
                catNames = [NSString stringWithFormat:@"%@%@,", catNames, catName];
            }
        }
        if (catNames.length > 0) {
            catNames = [catNames substringToIndex:catNames.length-1];
        }
        
        // 统计
        NSDictionary *appsflyerParams = @{@"af_content_type"    : @"Vitural_Catentrance_click",
                                          @"af_cat_id"          : ZFToString(catIds),
                                          @"af_cat_name"        : ZFToString(catNames),
                                          @"af_catentrance_type": ZFToString(tabContainer.actionType),
                                          @"af_cat_level"       : @"2",
                                          @"af_text"            : ZFToString(tabContainer.text),
                                          @"af_first_entrance"  : @"category"
        };
        
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_Catentrance_click" withValues:appsflyerParams];
    }
}

- (void)after_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFSuperCateViewCell *cell = (ZFSuperCateViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    ZFCategoryTabNav *cateTabNav = cell.cateTabNav;
    if (cateTabNav) {
        // 统计
        NSDictionary *appsflyerParams = @{@"af_content_type"    : @"Vitural_Catentrance_click",
                                          @"af_cat_id"          : @"",
                                          @"af_cat_name"        : @"",
                                          @"af_cat_level"       : @"1",
                                          @"af_text"            : ZFToString(cateTabNav.text),
                                          @"af_first_entrance"  : @"category"
        };

        [ZFAppsflyerAnalytics zfTrackEvent:@"af_Catentrance_click" withValues:appsflyerParams];
    }
}

- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                             NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                             @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             NSStringFromSelector(@selector(tableView:didSelectRowAtIndexPath:)) : NSStringFromSelector(@selector(after_tableView:didSelectRowAtIndexPath:)),
                             NSStringFromSelector(@selector(viewWillAppear:)) : NSStringFromSelector(@selector(after_viewWillAppear:))
                             };
    return params;
}

- (NSMutableArray *)categoryAnalyticsSet {
    if (!_categoryAnalyticsSet) {
        _categoryAnalyticsSet = [NSMutableArray array];
    }
    return _categoryAnalyticsSet;
}

@end
