//
//  HCTest.h
//  URLDEMO
//
//  Created by odd on 7/13/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//判断表格数据空白页和分页的字段key
#define kTotalPageKey                               @"pageCount"
#define kCurrentPageKey                             @"curPage"
#define kListKey                                    @"list"

// 弱应用
#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif

UIColor* STLRandomColor(void);

NS_ASSUME_NONNULL_BEGIN

@interface HCTest : NSObject

@end

NS_ASSUME_NONNULL_END
