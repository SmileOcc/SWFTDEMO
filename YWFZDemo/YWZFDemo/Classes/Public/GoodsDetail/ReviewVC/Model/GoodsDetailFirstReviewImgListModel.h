//
//  GoodsDetailFirstReviewImgListModel.h
//  ZZZZZ
//
//  Created by YW on 17/1/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoodsDetailFirstReviewImgListModel : NSObject

@property (nonatomic,copy) NSString *smallPic;
@property (nonatomic,copy) NSString *originPic;
@property (nonatomic,copy) NSString *bigPic;
@property (nonatomic,copy) NSString *wp_image; //webp_image

///用户购买的尺寸
@property (nonatomic, copy) NSString *attr_strs;

@end
