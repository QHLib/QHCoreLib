//
//  QHNetworkWorkerAFHTTPRequestOperation.h
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import "_QHNetworkWorker+subclass.h"


NS_ASSUME_NONNULL_BEGIN

@interface QHNetworkWorkerAFHTTPRequestOperation : QHNetworkWorker

+ (void)cancelAll;

+ (void)setTrustCerts:(NSArray<NSString *> *)certFiles;

@end

NS_ASSUME_NONNULL_END
