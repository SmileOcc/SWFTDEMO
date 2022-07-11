//
//  OSSVShippingMethCell.h
// XStarlinkProject
//
//  Created by fan wang on 2021/8/4.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVTableViewCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVShippingMethCell : UITableViewCell<OSSVTableViewCellProtocol>
@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) UILabel *priceLbl;
//划线价
@property (nonatomic, strong) UILabel *centerLinelbl;
@end

NS_ASSUME_NONNULL_END
