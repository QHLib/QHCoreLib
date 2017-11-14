//
//  _QHNetworkWorker+subclass.h
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#ifndef _QHNetworkWorker_subclass_h
#define _QHNetworkWorker_subclass_h

#import <QHCoreLib/QHNetworkWorker.h>


NS_ASSUME_NONNULL_BEGIN

@interface QHNetworkWorker ()

- (instancetype)initWithRequest:(QHNetworkRequest *)request;

@property (nonatomic, strong, readwrite) QHNetworkRequest *request;


- (void)p_doStart;  // subclass imp

- (void)p_doCancel; // subclass imp

- (void)p_doCompletion:(QHNetworkWorker *)worker
              response:(QHNetworkResponse * _Nullable)response
                 error:(NSError * _Nullable)error;

@end

NS_ASSUME_NONNULL_END

#import "_QHNetworkWorkerAFHTTPRequestOperation.h"

#endif /* _QHNetworkWorker_subclass_h */
