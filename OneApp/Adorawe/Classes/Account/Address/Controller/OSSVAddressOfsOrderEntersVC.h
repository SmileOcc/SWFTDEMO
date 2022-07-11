//
//  OSSVAddressOfsOrderEntersVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"

@class OSSVAddresseBookeModel;

typedef void (^ChooseAddressDefalutModelBlock)(OSSVAddresseBookeModel *model);
typedef void (^DirectReBackActionBlock)(OSSVAddresseBookeModel *modifyAddressModel);

@interface OSSVAddressOfsOrderEntersVC : STLBaseCtrl

@property (nonatomic, copy) ChooseAddressDefalutModelBlock chooseDefaultAddressBlock;
@property (nonatomic, copy) DirectReBackActionBlock directReBackActionBlock;
@property (nonatomic, copy) NSString *selectedAddressId;

@end
