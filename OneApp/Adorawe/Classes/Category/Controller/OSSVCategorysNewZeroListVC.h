//
//  OSSVCategorysNewZeroListVC.h
// XStarlinkProject
//
//  Created by odd on 2020/9/15.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLBaseCtrl.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVCategorysNewZeroListVC : STLBaseCtrl

@property (nonatomic, copy) NSString     *specialId;
@property (nonatomic, copy) NSString     *type;
@property (nonatomic, copy) NSString     *titleName;
@property (nonatomic, assign) BOOL       isFromZeroYuan; //是否来源于0元专题

- (void)refreshCollectionview;
@end

NS_ASSUME_NONNULL_END
