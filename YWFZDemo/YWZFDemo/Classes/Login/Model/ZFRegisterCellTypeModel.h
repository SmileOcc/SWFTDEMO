//
//  ZFRegisterCellTypeModel.h
//  ZZZZZ
//
//  Created by YW on 30/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RegisterCellType){
    RegisterCellTypeEmail = 0,
    RegisterCellTypeName  = 1
};

@interface ZFRegisterCellTypeModel : NSObject

@property (nonatomic, assign) RegisterCellType   type;
@property (nonatomic, assign) CGFloat            cellHeight;

- (instancetype)initWithType:(RegisterCellType)type cellHeight:(CGFloat)cellHeight;
@end
