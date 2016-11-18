//
//  Dwonloader.m
//  KSDownloadBackground
//
//  Created by keith xi on 9/20/16.
//  Copyright © 2016 keith. All rights reserved.
//



#import "Downloader.h"

@interface Downloader()<NSURLSessionDelegate,NSURLSessionDownloadDelegate>

@property (nonatomic,strong) NSMutableDictionary *completionHandlerDictionary;

@end

@implementation Downloader

+ (instancetype)defaultDownloader{
    static Downloader *downloader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [Downloader new];
    });
    
    return downloader;
}

- (NSURLSession *)backgroundURLSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifier = @"io.objc.backgroundTransferExample";
        _completionHandlerDictionary = [NSMutableDictionary new];
        NSOperationQueue *backqueue = [NSOperationQueue new];
        backqueue.maxConcurrentOperationCount = 1;
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        sessionConfig.HTTPMaximumConnectionsPerHost = 5;
        session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                delegate:self
                                           delegateQueue:backqueue];
    });
    
    return session;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"Background URL session %@ finished events.\n", session);
    
    if (session.configuration.identifier) {
        // 调用在 -application:handleEventsForBackgroundURLSession: 中保存的 handler
        [self callCompletionHandlerForSession:session.configuration.identifier];
    }
}

- (void)addCompletionHandler:(CompletionHandlerType)handler forSession:(NSString *)identifier
{
    if ([self.completionHandlerDictionary objectForKey:identifier]) {
        NSLog(@"Error: Got multiple handlers for a single session identifier.  This should not happen.\n");
    }
    
    [self.completionHandlerDictionary setObject:handler forKey:identifier];
}

- (void)callCompletionHandlerForSession: (NSString *)identifier
{
    CompletionHandlerType handler = [self.completionHandlerDictionary objectForKey: identifier];
    
    if (handler) {
        [self.completionHandlerDictionary removeObjectForKey: identifier];
        NSLog(@"Calling completion handler for session %@", identifier);
        
        handler();
    }
}

- (NSURLSessionDownloadTask *)downloadResource:(NSURL *)url{
    NSURLSessionDownloadTask *task = [[[Downloader defaultDownloader] backgroundURLSession] downloadTaskWithURL:url];
    return task;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSString *name = [downloadTask.originalRequest.URL lastPathComponent];
    NSLog(@"Download finish task %@",name);
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self downloadFilesPathfileName:name]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self downloadFilesPathfileName:name] error:nil];
    }
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[self downloadFilesDictoryfileName:name] error:&error];
    if (error) {
        NSLog(@"write file error:%@",error);
    }
    NSLog(@"save file to :%@",[self downloadFilesPathfileName:name]);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSString *name = [downloadTask.originalRequest.URL lastPathComponent];
    [self.delegate updateProgress:name didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
}

- (NSURL *)downloadFilesDictoryfileName:(NSString *)name{
    NSString *homestr = NSHomeDirectory();
    homestr = [homestr stringByAppendingPathComponent:@"Library"];
    homestr =  [homestr stringByAppendingPathComponent:name];
    NSURL *fileurl = [NSURL fileURLWithPath:homestr];
    return fileurl;
}

- (NSString *)downloadFilesPathfileName:(NSString *)name{
    NSString *homestr = NSHomeDirectory();
    homestr = [homestr stringByAppendingPathComponent:@"Library"];
    homestr =  [homestr stringByAppendingPathComponent:name];
    return homestr;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"task:%ld, error:%@",task.taskIdentifier,error);
    NSString *name = [task.originalRequest.URL lastPathComponent];
     [self.delegate finishDownload:name taskIdener:task.taskIdentifier];
}


@end
