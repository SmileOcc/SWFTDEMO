//
//  OSSVAddresseAutoeResultModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STLAddressHighlightItem;
@interface OSSVAddresseAutoeResultModel : NSObject

@property (nonatomic, copy) NSString      *desc;
@property (nonatomic, copy) NSString      *place_id;
@property (nonatomic, strong) NSArray <STLAddressHighlightItem *>  *highlight;
@end


@interface STLAddressHighlightItem : NSObject

@property (nonatomic, assign) NSInteger      length;
@property (nonatomic, assign) NSInteger      offset;

@end
