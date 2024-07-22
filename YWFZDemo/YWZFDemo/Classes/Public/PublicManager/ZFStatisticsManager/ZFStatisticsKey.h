//
//  StatisticsKey.h
//  ZZZZZ
//
//  Created by YW on 2018/3/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#ifndef StatisticsKey_h
#define StatisticsKey_h
#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, ZF_Statistics_type)
{
    //--------------------------首页统计----------------------
    ZF_Home_Tabbar_type = 2018,                 //首页Tabbar点击事件
    ZF_Home_Search_type,                        //首页搜索统计事件
    ZF_Home_Cars_type,                          //首页购物车按钮统计事件
    
    //--------------------------社区统计----------------------
    ZF_Community_Tabbar_type,                   //社区Tabbar点击事件
    ZF_CommunityTabbar_ImagePicker_type,       // 社区tabbar点击加号➕选择相册图片发帖
    
    //--------------------------个人页面统计----------------------
    ZF_Account_Tabbar_type,                     //个人用户Tabbar点击事件
    ZF_Account_Search_type,                     //我的Tabbar页面搜索按钮统计事件
    ZF_Account_Cars_type,                       //我的Tabbar页面购物车按钮统计事件
    ZF_Account_Order_type,                      //个人用户订单统计
    ZF_Account_Wishlist_type,                   //个人用户收藏夹统计
    ZF_Account_Coupon_type,                     //个人用户优惠券统计
    ZF_Account_Z_Points_type,                   //个人用户积分统计
    ZF_Account_HistoryView_type,                //个人用户浏览历史统计
    
    //--------------------------分类页面统计----------------------
    ZF_Category_Tabbar_type,                    //分类Tabbar点击事件
    ZF_Category_Search_type,                    //分类Tabbar页面搜索按钮统计事件
    ZF_Category_SearchImage_type,               //分类搜索图片统计事件
    ZF_Category_Cars_type,                      //分类Tabbar页面购物车按钮统计事件
    ZF_CategoryList_Cars_type,                  //分类列表购物车按钮统计事件
    ZF_CategoryVirtual_Cars_type,               //虚拟分类列表购物车按钮统计事件
    
    //--------------------------收藏页面统计----------------------
    ZF_Collection_Tabbar_type,                  //收藏Tabbar点击事件
    ZF_Favorites_Search_type,                   //收藏Tabbar页面搜索按钮统计事件
    ZF_Favorites_Cars_type,                     //收藏Tabbar页面购物车按钮统计事件
    
    //--------------------------其他统计----------------------
    ZF_BoletoFinished_Cars_type,                // <--这个类型暂时没有统计事件, 只是用来占位-->
    ZF_NativeBanner_Cars_type,                  // <--这个类型暂时没有统计事件, 只是用来占位-->
    
    
    ZF_HandpickGoodsList_Cars_type,             //精选商品列表购物车按钮统计事件
    ZF_FullReductionList_Cars_type,             //满减商品列表购物车按钮统计事件
};


#endif /* StatisticsKey_h */
