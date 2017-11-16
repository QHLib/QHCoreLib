//
//  QHListDataLoaderTestController.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/8.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHListDataLoaderTestController.h"

@interface QHListDataTestLoader : QHListDataLoader

@end

@interface QHListDataLoaderTestController () <QHListDataLoaderDelegate>

@property (nonatomic, strong) QHListSimpleData *listData;

@property (nonatomic, strong) QHListDataTestLoader *listLoader;

@end

@implementation QHListDataLoaderTestController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.listData = [QHListSimpleData new];
    self.listData.delegate = self;

    self.listLoader = [QHListDataTestLoader new];
    self.listLoader.delegate = self;
    [self.listLoader load];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listData.numberOfItems;
}

- (NSString *)textForIndexPath:(NSIndexPath *)indexPath
{
    return $(@"%@, %@",
             [super textForIndexPath:indexPath],
             [self.listData listItemAtIndex:indexPath.row]);
}

- (void)add
{
    [self.listLoader loadNext];
}

#pragma mark -

- (void)listDataLoaderSucceed:(id<QHListDataLoader>)listDataLoader
                         list:(NSArray *)list
                     userInfo:(NSDictionary *)userInfo
{
    QHLogDebug(@"list data loader succeed");
    QHLogDebug(@"request type: %d", (int)listDataLoader.requestType);

    [self.listData appendListData:list];
}

- (void)listDataLoaderFailed:(id<QHListDataLoader>)listDataLoader
                       error:(NSError *)error
                    userInfo:(NSDictionary *)userInfo
{
    QHLogDebug(@"list data loader failed");
    QHLogDebug(@"request type: %d", (int)listDataLoader.requestType);
    QHLogDebug(@"error: %@", error);
}


@end

@implementation QHListDataTestLoader

- (BOOL)p_isLoading
{
    return NO;
}

- (void)p_doLoadFirst
{
    QHLogDebug(@"do load first");

    QHDispatchDelayMain(0.5, ^{
//        [self p_loadFailed:QH_ERROR(@"", 0, @"", nil) userInfo:nil];
        [self p_loadSucceed:@[ @"aaa", @"aaa", @"aaa" ] userInfo:nil];
    });
}

- (void)p_doLoadNext
{
    QHLogDebug(@"do load next");

    QHDispatchDelayMain(0.5, ^{
        [self p_loadSucceed:@[ @"bbb", @"bbb", @"bbb" ] userInfo:nil];
    });
}

- (void)p_doCancel
{

}

@end
