//
//  QHNetworkRequest.m
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import "QHNetworkRequest.h"


@implementation QHNetworkRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.urlRequest = nil;
        self.priority = QHNetworkRequestPriorityDeafult;
        self.resourceType = QHNetworkResourceHTTP;
    }
    return self;
}

@end
