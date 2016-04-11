//
//  HZMultiDownloader.h
//  HZMultiDownloaderDemo
//
//  Created by 刘华舟 on 16/3/30.
//  Copyright © 2016年 刘华舟. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HZMultiDownloader;

@protocol HZMultiDownloaderDelegate <NSObject>

//完成总下载
- (void)multiDownloader:(HZMultiDownloader *)downloader successURLS:(NSArray *)urls successData:(NSArray *)datas faildURLS:(NSArray *)urls;

//完成某个下载 
- (void)multiDownloader:(HZMultiDownloader *)downloader complitedURL:(NSString *)url data:(NSData *)data error:(NSError *)error;

//某一下载进度
- (void)multiDownloader:(HZMultiDownloader *)downloader
            downloadURL:(NSString *)url
           didWriteData:(int64_t)bytesWritten
      totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

@end

@interface HZMultiDownloader : NSObject

@property (nonatomic, weak) id<HZMultiDownloaderDelegate> delegate;

@property (nonatomic,strong) NSString* locationToSave;
@property (nonatomic,assign) NSTimeInterval timeoutInterval;
@property (nonatomic, strong) NSString* httpReference;

//下载多url文件
- (void)startDownloadFilesWithURLS:(NSArray *)urls fileNames:(NSArray *)names;

@end
