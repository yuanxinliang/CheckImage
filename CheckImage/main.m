//
//  main.m
//  CheckImage
//
//  Created by XL Yuen on 2020/1/9.
//  Copyright © 2020 XL Yuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchBundleResource.h"
#import "Header.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *path = SourcePath;
        [[SearchBundleResource new] beginSearchWithPath:path];
    }
    return 0;
}
