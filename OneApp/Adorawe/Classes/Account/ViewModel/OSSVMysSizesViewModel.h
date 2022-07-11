//
//  OSSVMysSizesViewModel.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "BaseViewModel.h"
#import "OSSVMysSizesCell.h"
NS_ASSUME_NONNULL_BEGIN


typedef void(^cellDidClickBlock)(sizeCellType type, OSSVSizesModel *sizeModel);

typedef void(^changeDescBlock)(NSString *desc);
@interface OSSVMysSizesViewModel : BaseViewModel <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) cellDidClickBlock cellDidClick;
@property (nonatomic, copy) changeDescBlock changeDescblock;

- (NSString *)reuseIdentifier;

/// 保存尺码信息
- (void)saveRequestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;

@end

NS_ASSUME_NONNULL_END
