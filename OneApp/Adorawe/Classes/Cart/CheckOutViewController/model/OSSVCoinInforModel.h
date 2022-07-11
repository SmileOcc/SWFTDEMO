//
//  OSSVCoinInforModel.h
// XStarlinkProject
//
//  Created by Kevin on 2021/3/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVCoinInforModel : NSObject <YYModel>
@property (nonatomic, copy) NSString *coinSave;
@property (nonatomic, copy) NSString *coinText1;
@property (nonatomic, copy) NSString *coinText2;
@property (nonatomic, copy) NSString *usedCoins;
    
@end

NS_ASSUME_NONNULL_END
