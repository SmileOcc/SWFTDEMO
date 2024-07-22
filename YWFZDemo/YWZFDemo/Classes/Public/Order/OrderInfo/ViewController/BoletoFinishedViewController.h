//
//  BoletoFinishedViewController.h
//  ZZZZZ
//
//  Created by YW on 15/8/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"

typedef void (^BoContiueBlock) (void);

typedef void (^BoOrderListBlock) (void);

@interface BoletoFinishedViewController : ZFBaseViewController

@property (nonatomic, copy) NSString   *order_number;

@property (nonatomic, copy) NSString   *order_id;

@property (nonatomic, copy) BoContiueBlock   boContiueBlock;

@property (nonatomic, copy) BoOrderListBlock   boOrderListBlock;

@end
