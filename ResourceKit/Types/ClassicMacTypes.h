//
// MIT License
//
// Copyright (c) 2016 Tom Hancocks
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//


#pragma mark - Macintosh Rectangle / Geometry

#include <stdint.h>

struct _MacintoshRectangle
{
    int16_t x1;
    int16_t y1;
    int16_t x2;
    int16_t y2;
};

typedef struct _MacintoshRectangle RKMacRect;

static inline RKMacRect RKMacRectMake(int16_t y1, int16_t x1, int16_t y2, int16_t x2)
{
    return (struct _MacintoshRectangle) {
        .x1 = x1,
        .y1 = y1,
        .x2 = x2,
        .y2 = y2
    };
}

static inline int16_t RKMacRectGetWidth(RKMacRect r)
{
    return r.x2 - r.x1;
}

static inline int16_t RKMacRectGetHeight(RKMacRect r)
{
    return r.y2 - r.y1;
}
