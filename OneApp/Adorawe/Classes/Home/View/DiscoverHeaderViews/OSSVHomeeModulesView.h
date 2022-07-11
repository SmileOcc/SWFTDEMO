//
//  ModuleView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVAdvsEventsModel.h"

/*
 公共的基础 ModuleView 方便用方法和代理
 **/

typedef NS_ENUM(NSInteger, ModuleViewType){
    OneModuleType = 1,
    TwoModuleType = 2,
    ThreeModuleType = 3,
    FourModuleType = 4,
    FiveModuleType = 5,
    EightModuleType = 6,
    SixteenModuleType = 7,
    CountDownModuleType = 8,
};

// 通用的 小 placeholder 图片
UIKIT_EXTERN NSString *const kModulePlaceholderDefalutImageString;
// More palceholder 图片
UIKIT_EXTERN NSString *const kMouulePlaceholderMoreButtonImageString;


@protocol DiscoveryModuleViewDelegate <NSObject>
/**

 *  @param model 传入的 OSSVAdvsEventsModel
 *  @param index 点击的位置 index,  index == 0 代表更多； 其他就是位置从左到右
 */
- (void)tapModuleViewActionWithModel:(OSSVAdvsEventsModel *)model moduleType:(ModuleViewType)moduleType position:(NSInteger)position;

@end

@interface OSSVHomeeModulesView : UIView

@property (nonatomic, weak) id <DiscoveryModuleViewDelegate> delegate;
@property (nonatomic, strong) NSArray <OSSVAdvsEventsModel *> *modelArray; // 外部传递数据用
@property (nonatomic, strong) NSArray <OSSVAdvsEventsModel *> *tempModelArray; // 内部数据传递用

- (void)assginToImageDataWithButton:(UIButton *)button urlString:(NSString *)urlString size:(CGSize)size placeholderString:(NSString *)imageString; // 给button 加载图片

@end
