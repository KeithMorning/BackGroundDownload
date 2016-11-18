//
//  Gloabl.m
//  KSDownloadBackground
//
//  Created by keith xi on 9/20/16.
//  Copyright © 2016 keith. All rights reserved.
//

#import "Gloabl.h"

static dispatch_block_t g_block;

@implementation Gloabl

+ (void)setblock:(dispatch_block_t)block{
    g_block = block;
}


+ (dispatch_block_t)get_g_block{
    return g_block;
}

@end
