//
//  HZMultiDownloader.m
//  HZMultiDownloaderDemo
//
//  Created by 刘华舟 on 16/3/30.
//  Copyright © 2016年 刘华舟. All rights reserved.
//

#import "HZMultiDownloader.h"

@interface HZMultiDownloader()<NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession* session;
@property (nonatomic, strong) NSURLSessionConfiguration* sessionConfig;
@property (nonatomic, strong) NSArray* urls;
@property (nonatomic, strong) NSArray* names;

@property (nonatomic, strong) NSMutableDictionary* urlToNameDict;

@property (nonatomic, strong) NSMutableArray* finishedArray;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) NSMutableArray* failedfArray;

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger totalCount;

@end

@implementation HZMultiDownloader

- (instancetype)init{
    if (self = [super init]) {
        self.timeoutInterval = 60.0f;
    }
    return self;
}


- (NSURLSession *)session
{
    if (_session == nil) {
        //创建网络会话
        self.session =  [NSURLSession sessionWithConfiguration:self.sessionConfig delegate:self delegateQueue:[NSOperationQueue new]];

    }
    return _session;
}

- (NSURLSessionConfiguration *)sessionConfig{
    if(_sessionConfig == nil){
        //参数设置类  简单的网络下载使用defaultSessionConfiguration即可
        _sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    return _sessionConfig;
}

- (void)startDownloadFilesWithURLS:(NSArray *)urls fileNames:(NSArray *)names
{
    self.urls = urls;
    
    self.count = 0;
    self.totalCount = urls.count;
    
    self.finishedArray = [NSMutableArray array];
    self.dataArray = [NSMutableArray array];
    self.failedfArray = [NSMutableArray array];
    
    self.urlToNameDict = [NSMutableDictionary dictionary];
    
    NSInteger index = 0;
    for (NSString* url in urls) {
        
        NSString* filename = @"";
        if (index < names.count) {
            filename = [names objectAtIndex:index];
        }
        //数据请求
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        [request setTimeoutInterval:self.timeoutInterval];
        if (self.httpReference != nil) {
            [request setValue:self.httpReference forHTTPHeaderField:@"reference"];
        }
        
        //创建下载任务
        NSURLSessionDownloadTask* task = [self.session downloadTaskWithRequest:request];

        //启动下载任务
        [task resume];
        
        index++;
    }

}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    self.count++;
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(multiDownloader:complitedURL:data:error:)]) {
            [self.failedfArray addObject:task.response.URL.absoluteString];
            [self.delegate multiDownloader:self complitedURL:task.response.URL.absoluteString data:nil error:error];
        }
    }
    
    if (self.count >= self.totalCount) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(multiDownloader:successURLS:successData:faildURLS:)]) {
            [self.delegate multiDownloader:self successURLS:self.finishedArray successData:self.dataArray faildURLS:self.failedfArray];
        }
    }
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    BOOL success = YES;
    NSString* filename = [self.urlToNameDict objectForKey:downloadTask.response.URL.absoluteString];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSData* data = [NSData dataWithContentsOfURL:location];
    
    if (self.locationToSave && self.locationToSave.length > 0) {
        //2.创建资源存储路径
        NSString *appendPath = [NSString stringWithFormat:@"/%@", filename];
        NSString *file = [self.locationToSave stringByAppendingString:appendPath];
        
        //3.将下载好的视频资源存储在路径下
        
        //将视频资源从原有路径移动到自己指定的路径
        success = [manager moveItemAtPath:location.path toPath:file error:nil];
    }
    
    
    
    if (success) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(multiDownloader:complitedURL:data:error:)]) {
            [self.finishedArray addObject:downloadTask.response.URL.absoluteString];
            [self.dataArray addObject:data];
            [self.delegate multiDownloader:self complitedURL:downloadTask.response.URL.absoluteString data:data error:nil];
        }
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(multiDownloader:complitedURL:data:error:)]) {
            [self.failedfArray addObject:downloadTask.response.URL.absoluteString];
            [self.delegate multiDownloader:self complitedURL:downloadTask.response.URL.absoluteString data:nil error:[NSError errorWithDomain:downloadTask.response.URL.host code:2 userInfo:nil]];
        }
    }
    
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(multiDownloader:downloadURL:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.delegate multiDownloader:self downloadURL:downloadTask.response.URL.absoluteString didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}


@end
