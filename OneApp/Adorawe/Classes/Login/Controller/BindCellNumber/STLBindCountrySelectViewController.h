//
//  STLBindCountrySelectViewController.h
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLBindCountryModel.h"
#import "STLBIndCountryGroup.h"


NS_ASSUME_NONNULL_BEGIN
typedef void(^DidSelected)(STLBindCountryModel *);

@interface STLBindCountrySelectViewController : STLBaseCtrl
@property (nonatomic, copy) DidSelected countryBlock;

@property (strong,nonatomic) NSArray<STLBIndCountryGroup *> *keyArr;
@end

NS_ASSUME_NONNULL_END
