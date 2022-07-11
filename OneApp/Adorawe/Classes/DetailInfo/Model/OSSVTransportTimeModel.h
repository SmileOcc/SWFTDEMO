//
//  OSSVTransportTimeModel.h
// XStarlinkProject
//
//  Created by Kevin on 2021/3/26.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVTransportTimeListModel.h"

@interface OSSVTransportTimeModel : NSObject

@property (nonatomic, copy) NSString  *titleSting;
@property (nonatomic, copy) NSString  *contentSting;
@property (nonatomic, strong) NSArray<OSSVTransportTimeListModel *> *childrenContenArray;
@end

