//
//  OSSVAccountOrdersPageVC.h
// XStarlinkProject
//
//  Created by odd on 2020/12/9.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "WMPageController.h"
#import "OSSVAccounteMyeOrdersListeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVAccountOrdersPageVC : WMPageController

@property (nonatomic, copy) NSString   *choiceIndex;

@property (nonatomic, assign) BOOL     isConcelCodEnter;
@property (nonatomic, strong) OSSVAccounteMyeOrdersListeModel  *codOrderAddressModel;

@end

NS_ASSUME_NONNULL_END
