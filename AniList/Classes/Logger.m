//
//  Logger.m
//  AniList
//
//  Created by Corey Roberts on 11/4/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "Logger.h"
#import <Crashlytics/Crashlytics.h>

@interface Logger()
@property (nonatomic, strong) NSFileHandle *logFile;
@end

@implementation Logger

- (id) init {
    self = [super init];
    if (self) {
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"debug.log"];
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        if (![fileManager fileExistsAtPath:filePath])
//            [fileManager createFileAtPath:filePath
//                                 contents:nil
//                               attributes:nil];
//        self.logFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
//        [self.logFile seekToEndOfFile];
    }
    
    return self;
}

- (void)log:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
//    [self.logFile writeData:[[message stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [self.logFile synchronizeFile];
    
    CLSLog(format, ap);
    
#ifdef DEBUG
    NSLog(@"%@", message);
#endif
}

+ (Logger *)sharedInstance {
    static dispatch_once_t pred;
    static Logger *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[Logger alloc] init];
    });
    return instance;
}

@end
