//
//  ZFStatistics.m
//  ZZZZZ
//
//  Created by YW on 2018/3/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFStatistics.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalytics.h"

@implementation ZFStatistics

+ (void)eventType:(ZF_Statistics_type)type
{
#pragma mark ----------------------------------首页统计-----------------------------
    if (type == ZF_Home_Tabbar_type) {
        //首页Tabbar点击事件
        [ZFAnalytics clickButtonWithCategory:@"Bottom Bar" actionName:@"Click_bottom tabbar_Home" label:@"Side Bar - Home"];
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Bottom Tabbar_Home" itemName:@"home" ContentType:@"Bottom-Tabbar" itemCategory:@"tabbar"];

        
    }  else if (type == ZF_Home_Search_type) {
        //首页搜索统计事件
        [ZFAnalytics clickButtonWithCategory:@"Home" actionName:@"Home - Search" label:@"impresion_search"];
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Seach" itemName:@"Seach" ContentType:@"Search" itemCategory:@"Search"];
        
        
    } else if (type == ZF_Home_Cars_type) {
        //首页购物车按钮统计事件
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Bag" itemName:@"home - bag" ContentType:@"Bag" itemCategory:@"Bag"];
        [ZFAnalytics clickButtonWithCategory:@"bag" actionName:@"Click_bag" label:@"Click_bag"];
        
        
#pragma mark ---------------------------------社区统计-----------------------------
    } else if (type == ZF_Community_Tabbar_type) {
         //社区Tabbar点击事件
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Bottom Tabbar_Z-Me" itemName:@"Z-Me" ContentType:@"Bottom-Tabbar" itemCategory:@"tabbar"];
        [ZFAnalytics clickButtonWithCategory:@"Home-Z-me" actionName:@"Home -Community-Click " label:@"ZF_Community"];
        [ZFAnalytics clickButtonWithCategory:@"Bottom Bar" actionName:@"Click_bottom tabbar_z_me" label:@"impression_z_me"];
    } else if (type == ZF_CommunityTabbar_ImagePicker_type) {
        // 社区tabbar点击加号➕选择相册图片发帖
        [ZFFireBaseAnalytics selectContentWithItemId:@"click_tabbar_【+】" itemName:@"tabbar_【+】" ContentType:@"tabbar_【+】" itemCategory:@"tabbar"];

        
#pragma mark ---------------------------------个人页面统计-----------------------------
    } else if (type == ZF_Account_Tabbar_type) {
        //个人用户Tabbar点击事件
        [ZFAnalytics clickButtonWithCategory:@"Bottom Bar" actionName:@"Click_bottom tabbar_Account" label:@"impression_account"];
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Bottom Tabbar_Account" itemName:@"Account" ContentType:@"Bottom-Tabbar" itemCategory:@"tabbar"];
        
        
    }  else if (type == ZF_Account_Search_type) {
        //我的Tabbar页面搜索按钮统计事件
        [ZFAnalytics clickButtonWithCategory:@"Mine" actionName:@"Mine - Search" label:@"impresion_search"];
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Seach" itemName:@"Seach" ContentType:@"Search" itemCategory:@"Search"];
        
        
    } else if (type == ZF_Account_Cars_type) {
        //我的Tabbar页面购物车按钮统计事件
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_bag" itemName:@"Account_bag" ContentType:@"Bag" itemCategory:@"Bag"];
        [ZFAnalytics clickButtonWithCategory:@"bag" actionName:@"Click_bag" label:@"Click_bag"];
        
        
    } else if (type == ZF_Account_Order_type) {
        //个人用户订单统计
        NSMutableArray *screenNames = [NSMutableArray array];
        NSMutableDictionary *banner = [NSMutableDictionary dictionary];
        banner[@"name"] = @"impression_account_all_orders";
        [screenNames addObject:banner];
        if (screenNames.count > 0) {
            [ZFAnalytics showAdvertisementWithBanners:screenNames position:nil screenName:@"account"];
        }
        
        NSString *GABannerId = @"account";
        NSString *GABannerName = @"impression_account_all_orders";
        NSString *position = @"1";
        [ZFAnalytics clickAdvertisementWithId:GABannerId name:GABannerName position:position];
    } else if (type == ZF_Account_Wishlist_type) {
        //个人用户收藏夹统计
        NSMutableArray *screenNames = [NSMutableArray array];
        NSMutableDictionary *banner = [NSMutableDictionary dictionary];
        banner[@"name"] = @"impression_account_wishlist";
        [screenNames addObject:banner];
        if (screenNames.count > 0) {
            [ZFAnalytics showAdvertisementWithBanners:screenNames position:nil screenName:@"account"];
        }
        
        NSString *GABannerId = @"account";
        NSString *GABannerName = @"impression_account_wishlist";
        NSString *position = @"1";
        [ZFAnalytics clickAdvertisementWithId:GABannerId name:GABannerName position:position];
    } else if (type == ZF_Account_Coupon_type) {
        //个人用户优惠券统计
        NSMutableArray *screenNames = [NSMutableArray array];
        NSMutableDictionary *banner = [NSMutableDictionary dictionary];
        banner[@"name"] = @"impression_account_coupon";
        [screenNames addObject:banner];
        if (screenNames.count > 0) {
            [ZFAnalytics showAdvertisementWithBanners:screenNames position:nil screenName:@"account"];
        }
        
        NSString *GABannerId = @"account";
        NSString *GABannerName = @"impression_account_coupon";
        NSString *position = @"1";
        [ZFAnalytics clickAdvertisementWithId:GABannerId name:GABannerName position:position];
        
        
    } else if (type == ZF_Account_Z_Points_type) {
        //个人用户积分统计
        NSMutableArray *screenNames = [NSMutableArray array];
        NSMutableDictionary *banner = [NSMutableDictionary dictionary];
        banner[@"name"] = @"impression_account_z_points";
        [screenNames addObject:banner];
        if (screenNames.count > 0) {
            [ZFAnalytics showAdvertisementWithBanners:screenNames position:nil screenName:@"account"];
        }
        
        NSString *GABannerId = @"account";
        NSString *GABannerName = @"impression_account_z_points";
        NSString *position = @"1";
        [ZFAnalytics clickAdvertisementWithId:GABannerId name:GABannerName position:position];
        
        
    } else if (type == ZF_Account_HistoryView_type) {
        [ZFFireBaseAnalytics selectContentWithItemId:@"click_history view" itemName:@"history view" ContentType:@"account" itemCategory:@"cell"];
        
        //个人用户浏览历史统计
        NSMutableArray *screenNames = [NSMutableArray array];
        NSMutableDictionary *banner = [NSMutableDictionary dictionary];
        banner[@"name"] = @"impression_account_history_products";
        [screenNames addObject:banner];
        if (screenNames.count > 0) {
            [ZFAnalytics showAdvertisementWithBanners:screenNames position:nil screenName:@"account"];
        }
        
        NSString *GABannerId = @"account";
        NSString *GABannerName = @"impression_account_history_products";
        NSString *position = @"1";
        [ZFAnalytics clickAdvertisementWithId:GABannerId name:GABannerName position:position];
        
        
#pragma mark ---------------------------------分类页面统计-----------------------------
    } else if (type == ZF_Category_Tabbar_type) {
        //分类Tabbar点击事件
        [ZFAnalytics clickButtonWithCategory:@"Bottom Bar" actionName:@"Click_bottom tabbar_Categories" label:@"Side Bar - Categories"];
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Bottom Tabbar_Categories" itemName:@"Categories" ContentType:@"Bottom-Tabbar" itemCategory:@"tabbar"];
        
        
    } else if (type == ZF_Category_SearchImage_type) {
        //分类搜索图片统计事件
        [ZFAnalytics clickButtonWithCategory:@"Category" actionName:@"Image - Search" label:@"impresion_search_Image"];
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_SeachImage" itemName:@"SeachImage" ContentType:@"SearchImage" itemCategory:@"SearchImage"];
        
        
    } else if (type == ZF_Category_Search_type) {
        //分类Tabbar页面搜索按钮统计事件
        [ZFAnalytics clickButtonWithCategory:@"Category" actionName:@"Cate - Search" label:@"impresion_search"];
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Seach" itemName:@"Seach" ContentType:@"Search" itemCategory:@"Search"];
        
        
    } else if (type == ZF_Category_Cars_type) {
        //分类Tabbar页面购物车按钮统计事件
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Bag" itemName:@"CategoryParent_bag" ContentType:@"Bag" itemCategory:@"Bag"];
        [ZFAnalytics clickButtonWithCategory:@"bag" actionName:@"Click_bag" label:@"Click_bag"];
        
        
    }  else if (type == ZF_CategoryList_Cars_type) {
        //分类列表购物车按钮统计事件
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_bag" itemName:@"categorylist_bag" ContentType:@"Bag" itemCategory:@"Bag"];
        [ZFAnalytics clickButtonWithCategory:@"bag" actionName:@"Click_bag" label:@"Click_bag"];
        
        
    } else if (type == ZF_CategoryVirtual_Cars_type) {
        //虚拟分类列表购物车按钮统计事件
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Bag" itemName:@"CategoryVirtual_bag" ContentType:@"Bag" itemCategory:@"Bag"];
        [ZFAnalytics clickButtonWithCategory:@"bag" actionName:@"Click_bag" label:@"Click_bag"];
        
        
#pragma mark ---------------------------------收藏页面统计-----------------------------
    } else if (type == ZF_Collection_Tabbar_type) {
        //收藏Tabbar点击事件
        [ZFAnalytics clickButtonWithCategory:@"Bottom Bar" actionName:@"Click_bottom tabbar_Favorites" label:@"impression_saved"];
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Bottom Tabbar_Favorites" itemName:@"Favorites" ContentType:@"Bottom-Tabbar" itemCategory:@"tabbar"];
        
        
    } else if (type == ZF_Favorites_Search_type) {
         //收藏Tabbar页面搜索按钮统计事件
        [ZFAnalytics clickButtonWithCategory:@"Collection" actionName:@"Collection - Search" label:@"impresion_search"];
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Seach" itemName:@"Seach" ContentType:@"Search" itemCategory:@"Search"];
        
        
    } else if (type == ZF_Favorites_Cars_type) {
        //收藏Tabbar页面购物车按钮统计事件
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_bag" itemName:@"Collection_bag" ContentType:@"Bag" itemCategory:@"Bag"];
        [ZFAnalytics clickButtonWithCategory:@"bag" actionName:@"Click_bag" label:@"Click_bag"];
        
        
#pragma mark ---------------------------------其他统计-----------------------------
    } else if (type == ZF_HandpickGoodsList_Cars_type) {
        //精选商品列表购物车按钮统计事件
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_bag" itemName:@"HandpickGoods_bag" ContentType:@"Bag" itemCategory:@"Bag"];
        [ZFAnalytics clickButtonWithCategory:@"bag" actionName:@"Click_bag" label:@"Click_bag"];
        
    } else if (type == ZF_FullReductionList_Cars_type) {
        //满减商品列表购物车按钮统计事件
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_bag" itemName:@"FullReduction_bag" ContentType:@"Bag" itemCategory:@"Bag"];
        [ZFAnalytics clickButtonWithCategory:@"bag" actionName:@"Click_bag" label:@"Click_bag"];
    }
    
}


@end
