//
//  ZFAccountTypeModel.h
//  ZZZZZ
//
//  Created by YW on 2018/5/3.
//  Copyright © 2018年 YW. All rights reserved.
//

/*
 * 备注： 用于管理个人中心TableView显示的cell Type 模型
 * type 为不同的cell显示类型。统一在ZFAccountViewController的dataArray配置管理。
 * rowheight cell显示的高度
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZFAccountTypeModelType) {
    ZFAccountTypeModelTypeTopInfo = 0,
    ZFAccountTypeModelTypeBanner,
    ///地址
    ZFAccountTypeModelTypeAddress,
    ///历史浏览记录
    ZFAccountTypeModelTypeHistory,
    ///联系我们
    ZFAccountTypeModelTypeMessageUs,
    ///帮助
    ZFAccountTypeModelTypeHelp,
    ///用户调查
    ZFAccountTypeModelTypeSurvey,
    ZFAccountTypeModelTypeProduct,
    ZFAccountTypeModelTypeTitle,
    ///历史浏览记录
    ZFAccountTypeModelyTypeRecently
};

@interface ZFAccountTypeModel : NSObject

@property (nonatomic, assign) ZFAccountTypeModelType            type;

@property (nonatomic, assign) CGFloat                           rowHeight;

@property (nonatomic, strong) Class                             openClass;

- (instancetype)initWithAccountTypeModel:(ZFAccountTypeModelType)type rowHeight:(CGFloat)rowHeight;

@end
