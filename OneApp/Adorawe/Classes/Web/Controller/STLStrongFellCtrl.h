//
//  STLStrongFellCtrl.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/11.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLBaseCtrl.h"

NS_ASSUME_NONNULL_BEGIN


typedef void(^closeBlock)(void);
@interface STLStrongFellCtrl : STLBaseCtrl

@property (nonatomic, strong) NSArray *imgsArr;
@property (nonatomic, strong) NSArray *imgsObjestArr;// 包含了图片的尺寸
@property (nonatomic, copy) closeBlock   closeblock;

@end

NS_ASSUME_NONNULL_END
