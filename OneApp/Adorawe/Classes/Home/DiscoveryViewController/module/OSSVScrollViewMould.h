//
//  OSSVScrollViewMould.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.

#import "CustomerLayoutSectionModuleProtocol.h"

///滚动视图布局模型类型
typedef NS_ENUM(NSInteger) {
    ScrollerType_Scroller,      ///单纯的滚动视图
    ScrollerType_CountDown,     ///带秒杀视图的滚动视图
    ScrollerType_Cart           ///带秒杀视图的滚动视图
}ScrollerType;

@interface OSSVScrollViewMould : NSObject
<
    CustomerLayoutSectionModuleProtocol
>

-(instancetype)initWithType:(ScrollerType)type;

@end
