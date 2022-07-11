//
//  STLThemeSpecialApi.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.

#import "OSSVBasesRequests.h"

@interface OSSVThemesSpecialsAip : OSSVBasesRequests

-(instancetype)initWithCustomeId:(NSString *)specialID;
-(instancetype)initWithCustomeId:(NSString *)specialID deepLinkId:(NSString *)deepLinkId;

@end
