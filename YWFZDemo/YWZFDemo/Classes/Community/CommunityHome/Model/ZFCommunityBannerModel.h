//
//  ZFCommunityBannerModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFCommunityBannerModel : NSObject <NSCoding>
@property (nonatomic, copy) NSString * href_type; // href_type | String | 跳转类型(1=原生，2=H5)
@property (nonatomic, copy) NSString * href_location;// href_location | String | 跳转位置 当跳转方式为H5时此参数没用 当跳转方式为原生时： 1=分类页，2=搜索页，3=新品，4=产品页
@property (nonatomic, copy) NSString * key;// key | String | 当跳转方式为H5时key=url地址
@property (nonatomic, copy) NSString * title;// title | String | 标题名称
@property (nonatomic, copy) NSString * image;// image | String | 图片地址
@property (nonatomic, copy) NSString * cat_node;// 分类页级别
@end
