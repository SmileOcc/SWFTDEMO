//
//  ZFGoodsTagModel.h
//  ZZZZZ
//
//  Created by YW on 27/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFGoodsTagModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString   *tagTitle;
@property (nonatomic, copy) NSString   *tagColor;
@property (nonatomic, copy) NSString   *borderColor;
@property (nonatomic, assign) NSInteger   fontSize;

@end
