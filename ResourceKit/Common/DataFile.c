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

#include <assert.h>
#include <stdlib.h>

#include "DataFile.h"


#pragma mark - File Length & Position

size_t FileGetLength(FILE *file)
{
    assert(file);
    fpos_t orig = ftell(file);
    fseek(file, 0L, SEEK_END);
    size_t len = ftell(file);
    fseek(file, orig, SEEK_SET);
    return len;
}

fpos_t FileGetCursorPosition(FILE *file)
{
    assert(file);
    return (fpos_t)ftell(file);
}

void FileSetCursorPosition(FILE *file, fpos_t position)
{
    assert(file);
    assert(FileGetLength(file) > position);
    fseek(file, position, SEEK_SET);
}

void FileAdvanceCursorPosition(FILE *file, fpos_t delta)
{
    assert(file);
    assert(FileCanReadData(file, delta));
    fseek(file, delta, SEEK_CUR);
}


#pragma mark - Data Availability

int FileCanReadData(FILE *file, size_t readAmount)
{
    assert(file);
    assert(readAmount > 0);
    return (FileGetLength(file) >= FileGetCursorPosition(file) + readAmount);
}


#pragma mark - Data Primitives

uint8_t FileReadByte(FILE *file, DataEndian endian __unused)
{
    uint8_t value;

    assert(file);
    assert(FileCanReadData(file, sizeof(value)));

    fread(&value, sizeof(value), 1, file);

    return value;
}

uint16_t FileReadWord(FILE *file, DataEndian endian)
{
    uint16_t value;

    assert(file);
    assert(FileCanReadData(file, sizeof(value)));

    fread(&value, sizeof(value), 1, file);

    if (endian == DataBigEndian) {
        value = OSSwapHostToBigInt16(value);
    }
    else if (endian == DataLittleEndian) {
        value = OSSwapHostToLittleInt16(value);
    }

    return value;
}

uint32_t FileReadLong(FILE *file, DataEndian endian)
{
    uint32_t value;

    assert(file);
    assert(FileCanReadData(file, sizeof(value)));

    fread(&value, sizeof(value), 1, file);

    if (endian == DataBigEndian) {
        value = OSSwapHostToBigInt32(value);
    }
    else if (endian == DataLittleEndian) {
        value = OSSwapHostToLittleInt32(value);
    }

    return value;
}


#pragma mark - "Structured" Data

uint8_t *FileReadData(FILE *file, size_t count)
{
    assert(file);
    assert(FileCanReadData(file, count));

    uint8_t *data = calloc(count, sizeof(*data));
    fread(data, sizeof(*data), count, file);

    return data;
}

void FileGetBytes(FILE *file, size_t count, void *bytes)
{
    assert(file);
    assert(FileCanReadData(file, count));
    fread(bytes, sizeof(*bytes), count, file);
}
