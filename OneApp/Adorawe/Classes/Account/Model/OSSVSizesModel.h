//
//  OSSVSizesModel.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STLSizeShapModel : NSObject

@property (nonatomic, copy) NSString *bmi_start;
@property (nonatomic, copy) NSString *bmi_end;
@property (nonatomic, copy) NSString *shape_title;
@property (nonatomic, copy) NSString *recommend_size;
@property (nonatomic, copy) NSString *shape_desc;

@end


@interface OSSVSizesModel : NSObject

@property (nonatomic, assign) NSInteger size_type;///1 cm  2 inch
@property (nonatomic, assign) NSInteger gender;/// 1 male  2 female
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *weight;
@property (nonatomic, strong) NSArray <STLSizeShapModel *> *shape_options;

// 自定义选中的option
@property (nonatomic, copy) NSString *option;

@end



NS_ASSUME_NONNULL_END
