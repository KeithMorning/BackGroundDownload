//
//  Dwonloader.h
//  KSDownloadBackground
//
//  Created by keith xi on 9/20/16.
//  Copyright © 2016 keith. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompletionHandlerType)(void);

@protocol downloadPregressDelegate <NSObject>

-(void)updateProgress:(NSString *)name didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

- (void)finishDownload:(NSString *)name taskIdener:(NSInteger)tasksnum;

@end

@interface Downloader : NSObject


+ (instancetype)defaultDownloader;
- (NSURLSession *)backgroundURLSession;
- (void)addCompletionHandler:(CompletionHandlerType)handler forSession:(NSString *)identifier;

- (NSURLSessionDownloadTask *)downloadResource:(NSURL *)url;

@property (nonatomic,weak) id<downloadPregressDelegate> delegate;
@end
