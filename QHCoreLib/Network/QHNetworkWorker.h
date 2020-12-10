//
//  QHNetworkWorker.h
//  QQHouse
//
//  Created by changtang on 16/12/22.
//
//

#import <Foundation/Foundation.h>
#import <QHCoreLib/QHBase.h>
#import <QHCoreLib/QHNetworkRequest.h>
#import <QHCoreLib/QHNetworkResponse.h>

NS_ASSUME_NONNULL_BEGIN

QH_EXTERN NSString * const QHNetworkWorkerDidStartNotification;
QH_EXTERN NSString * const QHNetworkWorkerDidFinishNotification;

@class QHNetworkWorker;

typedef void(^QHNetworkWorkerCompletionHandler)(QHNetworkWorker *worker, QHNetworkResponse *response, NSError *error);

@interface QHNetworkWorker : NSObject

+ (void)cancelAll;

+ (void)setTrustCerts:(NSArray<NSString *> *)certFiles;

+ (void)setAllowArbitraryHttps;

+ (void)setWorkerFactory:(QHNetworkWorker * _Nullable (^)(QHNetworkRequest *))factory;

+ (QHNetworkWorker *)workerFromRequest:(QHNetworkRequest *)request;

- (instancetype)init NS_UNAVAILABLE;    // use factory method `workerFromRequest:`

@property (nonatomic, strong, readonly) QHNetworkRequest *request;

// main queue if it is nil
@property (nonatomic, strong) dispatch_queue_t completionQueue;

- (void)setUploadProgressHandler:(void(^ _Nullable)(NSProgress *progress))uploadProgressHandler;
- (void)setDownloadProgressHandler:(void(^ _Nullable)(NSProgress *progress))downloadProgressHandler;
- (void)setStreamDataHandler:(void(^ _Nullable)(NSData *data))streamDataHandler;

- (void)startWithCompletionHandler:(QHNetworkWorkerCompletionHandler)completionHandler;

@property (nonatomic, readonly) BOOL isLoading;

- (void)cancel;

@property (nonatomic, readonly) BOOL isCancelled;

@end

NS_ASSUME_NONNULL_END
