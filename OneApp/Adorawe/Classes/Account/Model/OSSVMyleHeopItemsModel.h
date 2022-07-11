//
//  OSSVMyleHeopItemsModel.h
// XStarlinkProject
//
//  Created by odd on 2021/1/16.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVMyleHeopItemsModel : NSObject

@property (nonatomic,assign) NSInteger  index;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *imageName;
@property (nonatomic,copy) NSString *tip;
@property (nonatomic,copy) NSString *url;

@property (nonatomic,strong) NSArray *datas;
@end

NS_ASSUME_NONNULL_END
