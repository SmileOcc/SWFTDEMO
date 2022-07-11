//
//  OSSVDetailAdvertiseViewCell.h
// XStarlinkProject
//
//  Created by fan wang on 2021/5/10.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVDetailBaseCell.h"
#import "OSSVDetailsListModel.h"
#import "OSSVDetailsHeaderView.h"
NS_ASSUME_NONNULL_BEGIN

@interface OSSVDetailAdvertiseViewCell : OSSVDetailBaseCell
@property (nonatomic, weak) OSSVDetailsListModel     *model;
@end

NS_ASSUME_NONNULL_END
