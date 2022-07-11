//
//  OSSVCategorysModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVCategorysModel : NSObject

@property (nonatomic, strong) NSArray *guide;
@property (nonatomic, strong) NSArray *banner;
@property (nonatomic, strong) NSArray *category;
@property (nonatomic, copy) NSString    *cat_id;
@property (nonatomic, copy) NSString    *title;
@property (nonatomic, assign) BOOL    isSelected;

@property (nonatomic, copy) NSString  *link;

//1:左上角；2：右上角；,3：坐下角；,4：右下角
@property (nonatomic, assign) NSInteger cornersIndex;

@property (nonatomic, assign) NSInteger startSection;
@property (nonatomic, assign) NSInteger parnetSection;

@property (nonatomic, assign) CGFloat   startOffsetY;

@property (nonatomic, copy) NSString    *selfCategoryId;

@end
