//
//  OSSVColorSizeReusableView.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVDetailsBaseInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^sizeChatBlock)(void);

@interface OSSVColorSizeReusableView : UICollectionReusableView

@property (nonatomic, strong)NSString           *goods_id;
@property (nonatomic, assign)BOOL               isSelectSize;
@property (nonatomic, strong)OSSVSpecsModel *specsModel;
@property (nonatomic, copy)sizeChatBlock        sizeChatblock;

@end

NS_ASSUME_NONNULL_END
