//
//  HistoryDataCache.m
//  QRCodeScan
//
//  Created by wenyou on 2016/11/2.
//  Copyright © 2016年 wenyou. All rights reserved.
//

#import "HistoryDataCache.h"


@implementation HistoryDataCache {
    NSString *_cacheDirectoryPath;
    NSMutableArray *_cacheDatas;
}

+ (instancetype)sharedInstance {
    static HistoryDataCache *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _cacheDatas = [NSMutableArray new];
        
        // 缓存目录创建
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cdPath = [paths firstObject];
        _cacheDirectoryPath = [cdPath stringByAppendingPathComponent:@"LocalCache"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_cacheDirectoryPath]) {
            NSMutableArray *tmpArray = [self readCacheFile];
            if (tmpArray.count) {
                _cacheDatas = tmpArray;
            }
        } else {
            [[NSFileManager defaultManager] createDirectoryAtPath:_cacheDirectoryPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
    return self;
}

#pragma mark - public
- (void)addCacheValue:(NSString *)value {
    [_cacheDatas insertObject:value atIndex:0];
    [self writeCacheFile];
}

- (void)deleteCacheValueAtIndex:(NSUInteger)index {
    [_cacheDatas removeObjectAtIndex:index];
    [self writeCacheFile];
}

- (void)deleteAllCacheValue {
    [_cacheDatas removeAllObjects];
    [self removeCacheFile];
}

- (NSArray *)getCacheValues {
    return _cacheDatas;
}

#pragma makr - private
- (NSString *)fileName {
    return [NSString stringWithFormat:@"%@/%@", _cacheDirectoryPath, @"HistoryCacheData.data"];
}

- (NSMutableArray *)readCacheFile {
    NSString *filePath = [self fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) { // 文件是否存在
        NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
        if(data && data.length){
            NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            return [[NSMutableArray alloc] initWithArray:array];
        }
    }
    return [NSMutableArray new];
}

- (void)writeCacheFile {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        NSString *filePath = [weakSelf fileName];
        if (strongSelf->_cacheDatas.count) { // 是否有数据
            NSData *data = [NSJSONSerialization dataWithJSONObject:_cacheDatas options:NSJSONWritingPrettyPrinted error:nil];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) { // 文件是否存在
                [data writeToFile:filePath options:NSDataWritingAtomic error:nil];
            } else {
                [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
            }
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    });
}

- (void)removeCacheFile {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSFileManager defaultManager] removeItemAtPath:[weakSelf fileName] error:nil];
    });
}
@end
