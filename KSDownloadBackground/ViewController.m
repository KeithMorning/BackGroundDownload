//
//  ViewController.m
//  KSDownloadBackground
//
//  Created by keith xi on 9/7/16.
//  Copyright © 2016 keith. All rights reserved.
//

#import "ViewController.h"
#import "Downloader.h"

@interface ViewController ()<downloadPregressDelegate>
@property (weak, nonatomic) IBOutlet UIProgressView *processView;
@property (weak, nonatomic) IBOutlet UILabel *fileTitle;
@property (weak, nonatomic) IBOutlet UILabel *numremain;
@property (weak, nonatomic) IBOutlet UILabel *remainsize;

@property (nonatomic,strong) NSMutableArray *downloadTasks;

@property (nonatomic,copy) NSURLSessionDownloadTask*(^createTaskFunc)();

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _downloadTasks = [NSMutableArray new];
    [Downloader defaultDownloader].delegate = self;
    self.createTaskFunc = [self createNewTask];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startDownload:(id)sender {
 
    //first way
//    NSURLSessionDownloadTask *sessionTask = self.downloadTasks.firstObject
//    if (sessionTask) {
//        [sessionTask resume];
//    }
    
    //second way
    NSURLSessionDownloadTask *sessionTask = self.createTaskFunc();
    if (sessionTask) {
        [sessionTask resume];
    }
    
}
- (IBAction)pauseDownload:(id)sender {

}
- (IBAction)loadTask:(id)sender {
    
    NSString *(^getFileNameFunc)() = [self getFileName];
    NSString *name = getFileNameFunc();
    while (name) {
        NSURL *url = [NSURL URLWithString:@"http://10.32.148.167:8080/pic"];
        NSLog(@"add task:%@",name);
        url = [url URLByAppendingPathComponent:name];
        NSURLSessionDownloadTask *task = [[Downloader defaultDownloader] downloadResource:url];
        [self.downloadTasks addObject:task];
        name = getFileNameFunc();
    }
}


- (void)updateProgress:(NSString *)name didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.fileTitle.text = name;
        self.remainsize.text = [NSString stringWithFormat:@"%0.f",(totalBytesExpectedToWrite - totalBytesWritten)/1024.0];
        self.numremain.text = [NSString stringWithFormat:@"%ld",self.downloadTasks.count];
        self.processView.progress = totalBytesWritten*1.0/totalBytesExpectedToWrite;
    });
}

- (void)finishDownload:(NSString *)name taskIdener:(NSInteger)tasksnum{
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSURLSessionDownloadTask *sessionTask = self.createTaskFunc();
        if (sessionTask) {
            [sessionTask resume];
        }
    });
}

//first way delegate
//- (void)finishDownload:(NSString *)name taskIdener:(NSInteger)tasksnum{
//    
//    
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        id removeobj;
//        for (NSURLSessionDownloadTask *task in self.downloadTasks) {
//            if (task.taskIdentifier == tasksnum) {
//                removeobj = task;
//                break;
//            }
//        }
//        
//        [self.downloadTasks removeObject:removeobj];
//        NSURLSessionDownloadTask *sessionTask = self.downloadTasks.firstObject;
//        if (sessionTask) {
//            [sessionTask resume];
//        }
//    });
//}

- (NSURLSessionDownloadTask*(^)())createNewTask{
    __block NSString *(^getFileNameFunc)() = [self getFileName];
    NSURLSessionDownloadTask*(^func)() = ^NSURLSessionDownloadTask *{
        NSString *name = getFileNameFunc();
        if (name) {
            NSURL *url = [NSURL URLWithString:@"http://10.32.148.167:8080/pic"];
            NSLog(@"add task:%@",name);
            url = [url URLByAppendingPathComponent:name];
            NSURLSessionDownloadTask *task = [[Downloader defaultDownloader] downloadResource:url];
            return task;
        }else{
            return nil;
        }
    };
    
    return func;
}

- (NSString *(^)())getFileName{
    __block int i = 0;
    NSString * (^func)() = ^NSString *{
        i++;
        if (i<161) {
            return [NSString stringWithFormat:@"File%d.jpg",i];
        }else{
            return nil;
        }
        
    };
    return func;
}

@end
