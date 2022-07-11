//
//  STLTabbarIconModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STLTabbarIconModel : NSObject

@property (nonatomic, copy)NSString *background_color;
@property (nonatomic, copy)NSString *backgroup_url_2x;
@property (nonatomic, copy)NSString *backgroup_url_3x;
@property (nonatomic, copy)NSString *text_color_normal;
@property (nonatomic, copy)NSString *text_color_selected;
@property (nonatomic, copy)NSString *backgroup_url_iphonex;

@property (nonatomic, copy)NSArray<NSString*> *imgs_url_2x;
@property (nonatomic, copy)NSArray<NSString*> *imgs_url_3x;
@property (nonatomic, copy)NSArray<NSString*> *imgs_url_selected_2x;
@property (nonatomic, copy)NSArray<NSString*> *imgs_url_selected_3x;

@end
