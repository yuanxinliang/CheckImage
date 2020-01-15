//
//  SearchBundleResource.m
//  CheckImage
//
//  Created by XL Yuen on 2020/1/9.
//  Copyright © 2020 XL Yuen. All rights reserved.
//

#import "SearchBundleResource.h"
#import "Header.h"

#pragma mark - ImageInfo 图片信息类

@interface ImageInfo : NSObject

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) NSInteger size;

@end

@implementation ImageInfo

- (NSString *)description {
    NSString *sizeStr = nil;
    if (self.size >= 1024 * 1024) {
        sizeStr = [NSString stringWithFormat:@"%ldMB", self.size/(1024*1024)];
    } else if (self.size >= 1024) {
        sizeStr = [NSString stringWithFormat:@"%ldKB", self.size/(1024)];
    } else {
        sizeStr = [NSString stringWithFormat:@"%ldB", self.size];
    }
    return [NSString stringWithFormat:@"%@ - %@", self.fileName, sizeStr];
}

@end

#pragma mark - SearchBundleResource

@interface SearchBundleResource ()

@property (nonatomic, strong) NSMutableArray *imageArray;

@end

@implementation SearchBundleResource

/**
 * 主要思路：
 * 1、beginSearchWithPath 外部接口调用；
 * 2、showAllFileWithPath 先通过此方法递归调用遍历所有图片资料；
 * 3、filter              筛选图片资源，并图片路径保存到文件中。
 */

- (void)beginSearchWithPath:(NSString *)path {
    self.imageArray = [NSMutableArray array];
    [self showAllFileWithPath:path];
    [self filter];
}

- (void)showAllFileWithPath:(NSString *)path {
    
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
            NSString * subPath = nil;
            for (NSString * str in dirArray) {
                if ([[self ignoreFiles] containsObject:str]) {
                    return;
                }
                subPath  = [path stringByAppendingPathComponent:str];
                BOOL issubDir = NO;
                [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
                [self showAllFileWithPath:subPath];
            }
        } else {
            NSString *fileName = [[path componentsSeparatedByString:@"/"] lastObject];
            if ([fileName hasSuffix:@".png"]) {
                ImageInfo *info = [[ImageInfo alloc] init];
                info.fileName = fileName;
                info.path = path;
                
                NSDictionary *attr = [fileManger attributesOfItemAtPath:path error:nil];
                info.size = [attr[@"NSFileSize"] integerValue];
                [self.imageArray addObject:info];
            }
        }
    } else {
        NSLog(@"this path is not exist!");
    }
}

- (void)filter {
    
    NSInteger filterSize = MaxSize;
    
    [self.imageArray sortUsingComparator:^NSComparisonResult(ImageInfo *obj1, ImageInfo *obj2) {
        NSComparisonResult r1 = [obj1.path compare:obj2.path];
        return r1 == NSOrderedDescending;
    }];
    
    NSMutableString *text = [NSMutableString stringWithFormat:@"The image size is over %@: \n", [self sizeString:filterSize]];
    NSMutableArray *outImageArray = [NSMutableArray array];
    for (ImageInfo *info in self.imageArray) {
        if (info.size >= filterSize) {
            [outImageArray addObject:info];
            [text appendFormat:@"%@ -- %@ \n", info.path, [self sizeString:info.size]];
        }
    }
    [self writeToFileWithText:text];
    NSLog(@"success...");
}

#pragma mark - tools

// 图片大小格式化
- (NSString *)sizeString:(NSInteger)size {
    NSString *sizeStr = nil;
    if (size >= 1024 * 1024) {
        sizeStr = [NSString stringWithFormat:@"%ldMB", size/(1024*1024)];
    } else if (size >= 1024) {
        sizeStr = [NSString stringWithFormat:@"%ldKB", size/(1024)];
    } else {
        sizeStr = [NSString stringWithFormat:@"%ldB", size];
    }
    return sizeStr;
}

// 将字符串写入到文件中
- (void)writeToFileWithText:(NSString *)text {
    NSString *path = SaveLogPath;
    NSString *comp = [NSString stringWithFormat:@"%@.txt", [NSDate date]];
    NSString *writePath = [path stringByAppendingPathComponent:comp];
    [text writeToFile:writePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

// 忽略的图片资源文件
- (NSArray *)ignoreFiles {
    return @[@"IntegrateHKID.framework"];
}

@end
