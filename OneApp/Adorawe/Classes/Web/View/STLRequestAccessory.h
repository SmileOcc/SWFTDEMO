//
//  STLRequestAccessory.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STLRequestAccessory : NSObject<STLBaseRequestAccessory>

@property (nonatomic,copy) NSString *title;

- (instancetype)initWithApperOnView:(UIView *)view;
- (instancetype)initWithApperOnView:(UIView *)view isEnable:(BOOL)enable;

@end
