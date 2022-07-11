//
//  OSSVSearchAssociateModel.h
// XStarlinkProject
//
//  Created by odd on 2020/10/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STLSearchAssociateCatModel;
@class STLSearchAssociateGoodsModel;

@interface OSSVSearchAssociateModel : NSObject

@property (nonatomic, strong) NSArray <STLSearchAssociateCatModel *> *cat;
@property (nonatomic, strong) NSArray <STLSearchAssociateGoodsModel *> *goods;
@property (nonatomic, strong) NSArray  *keywords;

@end


@interface STLSearchAssociateCatModel : NSObject

@property (nonatomic, copy) NSString *cat_id;
@property (nonatomic, copy) NSString *cat_name;

@end


@interface STLSearchAssociateGoodsModel : NSObject

@property (nonatomic, copy) NSString *goods_id;
@property (nonatomic, copy) NSString *goods_sn;
@property (nonatomic, copy) NSString *wid;
@property (nonatomic, copy) NSString *cat_id;
@property (nonatomic, copy) NSString *goods_title;

@end
