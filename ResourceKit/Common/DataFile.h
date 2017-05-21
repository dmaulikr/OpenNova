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

#ifndef ResourceKit_DataFile_h
#define ResourceKit_DataFile_h

#include <stdio.h>
#include <stdint.h>

/// An enumeration that denotes the endian types that may need to be used
/// whilst reading data from a file.
typedef enum _ResourceDataEndian {
    DataBigEndian,
    DataLittleEndian,
} DataEndian;


/// Returns the size/length of the specified file in bytes.
size_t FileGetLength(FILE *file);

/// Returns the current cursor position within the specified file.
fpos_t FileGetCursorPosition(FILE *file);

/// Set the current cursor position within the specified file. This
/// position is relative to the start of the file.
void FileSetCursorPosition(FILE *file, fpos_t position);

/// Advance the current cursor position within the specified file.
void FileAdvanceCursorPosition(FILE *file, fpos_t delta);


/// Test to see if the required number of bytes remain in the file for reading.
int FileCanReadData(FILE *file, size_t readAmount);


/// Read a single byte from the current position in the specified file.
/// This will automatically advance the cursor. Data will be read in an
/// endian agnostic fashion.
/// NOTE: The data endian is specified in this function for the sole reason
/// of ensuring the ReadByte, ReadWord and ReadLong signatures match.
uint8_t FileReadByte(FILE *file, DataEndian endian);

/// Read a single word (2 bytes) from the current position in the specified file.
/// This will automatically advance the cursor. Data will be read in an
/// endian agnostic fashion.
uint16_t FileReadWord(FILE *file, DataEndian endian);

/// Read a single long (4 bytes) from the current position in the specified file.
/// This will automatically advance the cursor. Data will be read in an
/// endian agnostic fashion.
uint32_t FileReadLong(FILE *file, DataEndian endian);


/// Read a contiguous run of bytes from the current position in the specified file.
/// This will automatically advance the cursor. Data will be read in an
/// endian agnostic fashion. The return value will need to be free'd by the caller.
uint8_t *FileReadData(FILE *file, size_t count);

/// Read bytes from the file into the specified array. This will automatically
/// advance the cursor. Data will be read in an endian agnostic fashion.
void FileGetBytes(FILE *file, size_t count, void *bytes);

#endif
