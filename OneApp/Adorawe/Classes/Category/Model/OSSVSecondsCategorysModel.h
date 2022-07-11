//
//  OSSVSecondsCategorysModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCatagoryCountrysModel.h"
#import "OSSVCatagorysChildModel.h"
#import "OSSVCategorysModel.h"
#import <Foundation/Foundation.h>

@interface OSSVSecondsCategorysModel : NSObject

@property (nonatomic, copy) NSString *cat_id;
@property (nonatomic, copy) NSString *cat_name;
@property (nonatomic, copy) NSString *have_child;
@property (nonatomic, copy) NSString *img_addr;
@property (nonatomic, copy) NSString *recommend_img_addr;
@property (nonatomic, copy) NSString *is_op_cat; //为1的时候 不展示ViewAll

@property (nonatomic, copy) NSString *banner_is_show;
@property (nonatomic, copy) NSString *banner_url_type;
@property (nonatomic, copy) NSArray *child;
@property (nonatomic, copy) NSString *code;

@property (nonatomic, copy) NSString *is_ping;
@property (nonatomic, copy) NSString *seo_description;
@property (nonatomic, copy) NSString *seo_title;
@property (nonatomic, copy) NSString *static_page_name;
@property (nonatomic, copy) NSString *template_id;
@property (nonatomic, copy) NSString *weight;
@property (nonatomic, copy) NSString *link;

@property (nonatomic, assign) NSInteger parnetSection;

@property (nonatomic, assign) BOOL isAllCorners;

//自定义
@property (nonatomic, copy) NSString *parentsCategoryName;
@property (nonatomic, copy) NSString *parentsCategoryID;


@end
