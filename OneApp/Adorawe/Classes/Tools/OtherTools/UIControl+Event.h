//
//  UIControl+Event.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (Event)
@property(nonatomic,assign) NSTimeInterval acceptEventInterval;
@property(nonatomic) BOOL                  ignoreEvent;
@end
