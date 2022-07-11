//
//  OSSVMyRulerVC.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "OSSVMysSizesCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^saveBtnBlock)(sizeCellType type, NSString *value);

typedef void(^disBtnBlock)(void);

@interface OSSVMyRulerVC : STLBaseCtrl

@property (nonatomic, copy) saveBtnBlock saveBtnblock;
@property (nonatomic, copy) disBtnBlock disBtnblock;
@property (nonatomic, assign) sizeCellType type;
@property (nonatomic, strong) OSSVSizesModel *sizeModel;

@end

NS_ASSUME_NONNULL_END
