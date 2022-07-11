//
//  CatagoriesChildModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategorysModel.h"
#import "OSSVCatagoryCountrysModel.h"
#import <Foundation/Foundation.h>

@interface OSSVCatagorysChildModel : NSObject

@property (nonatomic, copy) NSString *banner_is_show;
@property (nonatomic, copy) NSString *banner_url_type;
@property (nonatomic, copy) NSString *cat_id;
@property (nonatomic, copy) NSString *cat_name;
@property (nonatomic, copy) NSString *code;

@property (nonatomic, copy) NSString *img_addr;
@property (nonatomic, copy) NSString *is_ping;
@property (nonatomic, copy) NSString *recommend_img_addr;
@property (nonatomic, copy) NSString *seo_description;
@property (nonatomic, copy) NSString *seo_title;
@property (nonatomic, copy) NSString *static_page_name;
@property (nonatomic, copy) NSString *template_id;
@property (nonatomic, copy) NSString *weight;
@property (nonatomic, copy) NSString *link;


@property (nonatomic, assign) BOOL isViewAll;
@property (nonatomic, assign) BOOL isHeader;

@end
