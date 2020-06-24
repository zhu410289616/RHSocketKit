//
//  RHDataInterceptor.m
//  Pods
//
//  Created by zhuruhong on 2019/9/26.
//

#import "RHDataInterceptor.h"
#import "RHSocketMacros.h"

@implementation RHDataInterceptor

@synthesize nextInterceptor = _nextInterceptor;

- (NSData *)interceptor:(NSData *)interceptData userInfo:(NSDictionary *)userInfo
{
    NSData *theData = interceptData;
    RHSocketLog(@"[Hook]: intercept data: %@, %@", theData, userInfo);
    if ([self.nextInterceptor respondsToSelector:@selector(interceptor:userInfo:)]) {
        theData = [self.nextInterceptor interceptor:theData userInfo:userInfo];
    }
    return theData;
}

@end

#pragma mark -

static NSString* _RHSocketDataCacheDir;

static inline NSString* RHSocketDataCacheDir() {
    if(!_RHSocketDataCacheDir) {
        NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _RHSocketDataCacheDir = [cachesDir stringByAppendingPathComponent:@"RHSocketCache"];
    }
    return _RHSocketDataCacheDir;
}

@interface RHDataToFileInterceptor ()

@property (nonatomic, strong) NSFileHandle *fileHandle;

@end

@implementation RHDataToFileInterceptor

@synthesize nextInterceptor = _nextInterceptor;

- (void)dealloc
{
    [_fileHandle closeFile];
}

- (instancetype)init
{
    return [self initWithFileName:@"tmp"];
}

- (instancetype)initWithFileName:(NSString *)fileName
{
    [[NSFileManager defaultManager] createDirectoryAtPath:RHSocketDataCacheDir() withIntermediateDirectories:YES attributes:nil error:NULL];
    NSString *filePath = [RHSocketDataCacheDir() stringByAppendingPathComponent:fileName];
    return [self initWithFilePath:filePath];
}

- (instancetype)initWithFilePath:(NSString *)filePath
{
    if (self = [super init]) {
        _filePath = filePath;
        RHSocketLog(@"[Hook]: intercept data to file path: %@", filePath);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            [fileManager removeItemAtPath:filePath error:NULL];
        }
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [_fileHandle seekToEndOfFile];
    }
    return self;
}

- (NSData *)interceptor:(NSData *)interceptData userInfo:(NSDictionary *)userInfo
{
    NSData *theData = interceptData;
    [self.fileHandle writeData:theData];
    if ([self.nextInterceptor respondsToSelector:@selector(interceptor:userInfo:)]) {
        theData = [self.nextInterceptor interceptor:theData userInfo:userInfo];
    }
    return theData;
}
@end
