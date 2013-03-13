//
//  NSString+FNBase64Encoding.m
//  Fauna
//
//  Created by Matt Freels on 3/12/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "NSString+FNBase64Encoding.h"

@implementation NSString (FNBase64Encoding)

- (NSString *)base64Encoded {
  static uint8_t const kEncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

  NSData *inData = [NSData dataWithBytes:[self UTF8String]
                                  length:[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];

  NSInteger inLength = inData.length;
  NSInteger outLength = (inLength + 2) / 3 * 4;
  NSMutableData *outData = [NSMutableData dataWithLength:outLength];

  uint8_t *in = (uint8_t *)inData.bytes;
  uint8_t *out = (uint8_t *)outData.bytes;

  for (NSUInteger i = 0, j = 0; i < inLength;) {
    uint32_t octet_a = i < inLength ? in[i++] : 0;
    uint32_t octet_b = i < inLength ? in[i++] : 0;
    uint32_t octet_c = i < inLength ? in[i++] : 0;

    uint32_t triple = (octet_a << 0x10) + (octet_b << 0x08) + octet_c;

    out[j++] = kEncodingTable[(triple >> 3 * 6) & 0x3F];
    out[j++] = kEncodingTable[(triple >> 2 * 6) & 0x3F];
    out[j++] = kEncodingTable[(triple >> 1 * 6) & 0x3F];
    out[j++] = kEncodingTable[(triple >> 0 * 6) & 0x3F];
  }

  switch (inLength % 3) {
    case 1:
      out[outLength - 1] = '=';
      out[outLength - 2] = '=';
      break;
    case 2:
      out[outLength -1] = '=';
      break;
  }

  return [[NSString alloc] initWithData:outData encoding:NSASCIIStringEncoding];
}

@end
