//
//  ZFOrderAmountDetailModel.h
//  ZZZZZ
//
//  Created by YW on 21/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFOrderAmountDetailModel : NSObject

@property (nonatomic, copy) NSString   *name;
@property (nonatomic, copy) NSString   *value;
@property (nonatomic, copy) NSAttributedString *attriName;
@property (nonatomic, copy) NSAttributedString *attriValue;
///是否显示 tipsButton
@property (nonatomic, assign) BOOL isShowTipsButton;

@end
