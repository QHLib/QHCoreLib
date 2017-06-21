//
//  QHNetworkRequest.m
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import "QHNetworkRequest.h"


NS_ASSUME_NONNULL_BEGIN

@implementation QHNetworkRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.priority = QHNetworkRequestPriorityDeafult;
        self.resourceType = QHNetworkResourceHTTP;
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
