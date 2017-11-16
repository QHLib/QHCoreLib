//
//  QHListCommonDataTestController.m
//  QHCoreLibDemo
//
//  Created by changtang on 2017/9/8.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHListCommonDataTestController.h"

@interface QHListCommonTestData : QHListCommonData
@end

@interface QHListCommonDataTestController () <QHListDataLoaderDelegate>

@property (nonatomic, strong) QHListCommonTestData *listData;

@end

@implementation QHListCommonDataTestController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.listData = [QHListCommonTestData new];
    [self.listData setListData:@[ @"000" ]];
    self.listData.delegate = self;

    [self.listData load];
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
    [self.listData loadNext];
}

#pragma mark -

- (void)listDataLoaderSucceed:(id<QHListDataLoader>)listDataLoader
                         list:(NSArray *)list
                     userInfo:(NSDictionary *)userInfo
{
    QHLogDebug(@"list data loader succeed");
    QHLogDebug(@"request type: %d", (int)listDataLoader.requestType);
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

@implementation QHListCommonTestData

- (BOOL)p_isLoading
{
    return NO;
}

- (void)p_doLoadFirst
{
    QHLogDebug(@"do load first");

    QHDispatchDelayMain(0.5, ^{
        //        [self p_loadFailed:QH_ERROR(@"", 0, @"", nil) userInfo:nil];
        NSArray *list = @[ @"aaa", @"aaa", @"aaa" ];
        [self setListData:list];
        [self p_loadSucceed:list userInfo:nil];
    });
}

- (void)p_doLoadNext
{
    QHLogDebug(@"do load next");

    QHDispatchDelayMain(0.5, ^{
        NSArray *list = @[ @"aaa", @"aaa", @"aaa" ];
        [self appendListData:list];
        [self p_loadSucceed:list userInfo:nil];
    });
}

- (void)p_doCancel
{

}

@end
