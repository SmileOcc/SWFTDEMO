//
//  OSSVTrackeDetaileModel.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/27.
//  Copyright © 2020 starlink. All rights reserved.
// ---物流拆分详细-----

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVTrackeDetaileModel : NSObject

@property (nonatomic, copy) NSString *trackStatus; //物流状态
@property (nonatomic, copy) NSString *trackText; // 物流描述
@property (nonatomic, copy) NSString *originTime; //创建时间
@property (nonatomic, copy) NSString *address;   //地址
@property (nonatomic, copy) NSString *trackStatusLang; //物流状态的描述
@end

NS_ASSUME_NONNULL_END
