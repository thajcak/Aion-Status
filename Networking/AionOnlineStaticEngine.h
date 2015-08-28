//
//  AionOnlineStaticEngine.h
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/29/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "MKNetworkEngine.h"

@interface AionOnlineStaticEngine : MKNetworkEngine

typedef  void (^returnedImageBlock)(UIImage *characterImage);

@end
