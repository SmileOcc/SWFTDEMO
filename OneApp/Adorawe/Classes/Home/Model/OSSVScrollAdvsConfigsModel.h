//
//  STLScrollBannerConfigModel.h
// XStarlinkProject
//
//  Created by fan wang on 2021/6/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVScrollAdvsConfigsModel: NSObject
/*
            "id": "1052",
             "name": "滑动banner背景图en",
             "image_url": "https://cdnimg.xxxxx.net/AR/image/Banner/20201201_1270/sj_women_1208_en.jpg",
             "width": "0",
             "height": "0",
             "banner_background_colour": "#FFFF00"
 */

@property (strong,nonatomic) NSString* configId;
@property (strong,nonatomic) NSString* name;
@property (strong,nonatomic) NSString* image_url;
@property (strong,nonatomic) NSString* width;
@property (strong,nonatomic) NSString* height;
@property (strong,nonatomic) NSString* banner_background_colour;

@end

NS_ASSUME_NONNULL_END
