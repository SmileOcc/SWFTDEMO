//
//  OSSVSizeDidSelectProtoCol.h
//  Adorawe
//
//  Created by fan wang on 2021/11/4.
//  Copyright © 2021 starlink. All rights reserved.
//

#ifndef OSSVSizeDidSelectProtoCol_h
#define OSSVSizeDidSelectProtoCol_h

@protocol OSSVSizeDidSelectProtocol <NSObject>

- (void)updateSizeTipViewWithArray:(NSArray <OSSVSizeChartModel *> *)size_info itemModel:(OSSVAttributeItemModel *)itemModel;

@end


#endif /* OSSVSizeDidSelectProtoCol_h */
