//
//  ZFCollectionViewCellProtocol.h
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFOrderPayResultModel.h"

NS_ASSUME_NONNULL_BEGIN

//回调虚基类
@protocol ZFCollectionViewCellDelegate <NSObject>

@end

@protocol ZFCollectionViewCellProtocol <NSObject>

//数据模型
@property (nonatomic, strong) ZFOrderPayResultModel *model;
//cell点击回调
@property (nonatomic, weak) id<ZFCollectionViewCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
