//
//  OSSVTotalDetailCellModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBaseCellModelProtocol.h"

@interface OSSVTotalDetailCellModel : NSObject<OSSVBaseCellModelProtocol>

@property (nonatomic, assign) TotalDetailType   type;

@property (nonatomic, copy) NSString            *title;
@property (nonatomic, copy) NSAttributedString  *value;
///划线价
@property (nonatomic, copy) NSAttributedString  *centerLineValue;

@end
