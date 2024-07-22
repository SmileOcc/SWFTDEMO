//
//  ZFUserInfoTypeModel.h
//  ZZZZZ
//
//  Created by YW on 2020/1/9.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFUserInfoHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFUserInfoTypeModel : NSObject

@property (nonatomic, assign) ZFUserInfoEditType    editType;
@property (nonatomic, copy) NSString                *typeName;
@property (nonatomic, copy) NSString                *content;
//@property (nonatomic, copy) NSString                *placeHolder;


/**必填项*/
@property (nonatomic, assign) BOOL                  isRequiredField;
@property (nonatomic, assign) BOOL                  isShowArrow;


@end

NS_ASSUME_NONNULL_END
