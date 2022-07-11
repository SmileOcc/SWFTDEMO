//
//  OSSVAccountsMenuItemsModel.h
// XStarlinkProject
//
//  Created by odd on 2020/8/3.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVAccountsMenuItemsModel : NSObject

@property (nonatomic, strong) NSString   *  itemImage;
@property (nonatomic, strong) NSString   *  itemTitle;
@property (nonatomic, strong) NSString   *  itemCount;
@property (nonatomic, assign) NSInteger    index;
@property (nonatomic, assign) NSInteger  type;

@end

NS_ASSUME_NONNULL_END
