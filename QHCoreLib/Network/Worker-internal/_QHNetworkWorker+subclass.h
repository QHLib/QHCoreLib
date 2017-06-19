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


typedef NS_ENUM(NSUInteger, QHNetworkWorkerState) {
    QHNetworkWorkerStateNone,
    QHNetworkWorkerStateLoading,
    QHNetworkWorkerStateCancelled,
    QHNetworkWorkerStateFinished,
};

@interface QHNetworkWorker ()

+ (NSOperationQueue *)sharedNetworkQueue;

- (instancetype)initWithRequest:(QHNetworkRequest *)request;

@property (nonatomic, strong, readwrite) QHNetworkRequest *request;


- (void)p_doStart;  // subclass imp

- (void)p_doCancel; // subclass imp

- (void)p_doCompletion:(QHNetworkWorker *)worker
              response:(QHNetworkResponse *)response
                 error:(NSError *)error;

@end

#import "_QHNetworkWorkerAFHTTPRequestOperation.h"

#endif /* _QHNetworkWorker_subclass_h */
