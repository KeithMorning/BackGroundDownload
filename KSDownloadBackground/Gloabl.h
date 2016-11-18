//
//  Gloabl.h
//  KSDownloadBackground
//
//  Created by keith xi on 9/20/16.
//  Copyright © 2016 keith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gloabl : NSObject

+ (void)setblock:(dispatch_block_t)block;
+ (dispatch_block_t)get_g_block;

@end
