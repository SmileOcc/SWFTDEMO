//
//  GoodsDetailsModel.h
//  Yoshop
//
//  Created by huangxieyue on 16/6/2.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>
//@class GoodsDetailsListModel;

@interface GoodsDetailsModel : NSObject

@property (nonatomic,assign) NSInteger statusCode;
//@property (nonatomic,strong) GoodsDetailsListModel *result;
@property (nonatomic,strong) NSArray *result;
@property (nonatomic,copy) NSString *message;

@end
