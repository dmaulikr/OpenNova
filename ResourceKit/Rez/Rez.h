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

#ifndef ResourceKit_Rez_h
#define ResourceKit_Rez_h

#include "DataFile.h"

// We have a bunch of forward declarations to make in order to be able to construct
// the structures required by the Rez format.
struct _RezDataRange;
struct _RezResourceFile;
struct _RezHeader;
struct _RezResourceType;
struct _RezResourceHeader;

/// The RezResourceFile structure hold key information about the format of the resource file
/// being represented as well as holding references to all internal types and resource
/// headers.
/// It also the reference that will be passed around by the user in order to access
/// the resources behind it.
typedef struct _RezResourceFile {

    /// The Rez format is in a weird hybrid state of both Little- and Big-Endian. This switch
    /// occurs shortly after processing initial header information. This field helps to expose
    /// the current expected endian state of data being read.
    DataEndian currentEndian;

    /// The path in the file system to the resource file.
    const char *path;

    /// The actual FILE handle that will be used to communicate and read data from the file.
    FILE *handle;

    /// The resource file headers, and additional calculated values that relate to them.
    struct _RezHeader *header;

    /// A list of data ranges representing the data of resources. This is a pointer to the first.
    struct _RezDataRange *dataRange;

    /// A list of types representing each of the resource types contained in the Rez file. This is
    /// a pointer to the first.
    struct _RezResourceType *type;

    /// A list of resources representing each of the resources (of all types) in the Rez file. This
    /// is a pointer to the first.
    struct _RezResourceHeader *resource;

} RezResourceFile;

/// The RezDataRange structure is a linked list node the contains information about the offset and
/// length of a run of data within a RezResourceFile.
typedef struct _RezDataRange {

    /// The next data range in the list. If this is NULL then the current instance is the terminal
    /// node.
    struct _RezDataRange *next;

    /// The offset of the data in the Rez file.
    fpos_t offset;

    /// The size of the data in the Rez file.
    size_t size;

} RezDataRange;

/// The RezHeader structure keeps track of the Rez file format headers, as well as other computed
/// values that relate to those header values.
typedef struct _RezHeader {

    /// The number of all resources in the Rez file.
    size_t resourceCount;

    /// The number of resource types in the Rez file.
    size_t typeCount;

    /// The starting offset of the resource map in the RezFile.
    fpos_t resourceMapOffset;

    /// The length of the Rez file.
    size_t fileLength;

    /// The start of all resource data
    fpos_t resourceOffset;

} RezHeader;

/// The RezResourceType structure is a linked list node that contains information about an individual type
/// of resource. It keeps the type code, resource count, first resource offset and such.
typedef struct _RezResourceType {

    /// The next resource type in the list. If this is NULL then the current instance is the terminal
    /// node.
    struct _RezResourceType *next;

    /// The type code of the resource. This code a FCC (four-char-code) and will always be 4 bytes long.
    char code[4];

    /// The offset of the first resource in the Rez file. This is an offset to the header data of the first
    /// resource. Not the data of the first resource.
    fpos_t firstResourceOffset;

    /// The number of resources of this type present in the Rez file.
    size_t resourceCount;

} RezResourceType;

/// The RezResourceHeader structure is a linked list node that contains information about an individual resource
/// instance in the Rez file. It keeps track of the FCC type code, id, name, owner, data offset and length.
typedef struct _RezResourceHeader {

    /// The next resource header in the list. If this is NULL then the current instance is the terminal
    /// node.
    struct _RezResourceHeader *next;

    /// The owning Rez file. This is used primarily for data access.
    struct _RezResourceFile *owner;

    /// The type code of the resource. This code a FCC (four-char-code) and will always be 4 bytes long.
    char typeCode[4];

    /// The name of the resource can be a maximum of 256 bytes due to it being a Pascal String. The field
    /// is 257 bytes long to ensure there is always a 0 byte as a terminator.
    char name[UINT8_MAX + 1];

    /// The id of the resource. The id range of resources is 32,767 to -32,767. Convention generally states that
    /// negative ids state the resource is "owned" by another resource. Typically resources start numbering at
    /// 128.
    int16_t id;

    /// The offset of the resource data in the owning Rez file.
    fpos_t offset;

    /// The length of the resource data in the owning Rez file.
    size_t size;

} RezResourceHeader;


/// Open a new RezResourceFile for the file at the specified path. This will return
/// NULL if there was a problem opening the file for any reason. Any errors will be printed
/// to stderr.
RezResourceFile *RezOpenFile(const char *restrict path);

/// Close the RezResourceFile specified. This will also release and clean up any memory of types
/// a resources owned by this file. Files should only be closed once all resources have been finished
/// with.
void RezClosefile(RezResourceFile *file);


/// Get the RezDataRange instance from the specified rez file for the specified index. NULL will be
/// returned if the index is out of bounds.
RezDataRange *RezGetDataRangeAtIndex(RezResourceFile *file, int32_t index);

/// Get the RezResourceType instance from the specified rez file for the specified index. NULL will be
/// returned if the index is out of bounds.
RezResourceType *RezGetResourceTypeAtIndex(RezResourceFile *file, int32_t index);

/// Get the RezResourceType instance from the specified rez file for the specified type code. NULL will be
/// returned if the type code is not present.
RezResourceType *RezGetResourceTypeForCode(RezResourceFile *file, const char *code);

/// Get the RezResourceHeader instance from the specified rez file for the specified index. NULL will be
/// returned if the index is out of bounds.
RezResourceHeader *RezGetResourceHeaderAtIndex(RezResourceFile *file, int32_t index);

/// Get the RezResourceHeader instance from the specified rez file for the specified index and type.
/// NULL will returned if the index is out of bounds.
RezResourceHeader *RezGetResourceHeaderOfTypeAtIndex(RezResourceFile *file, const char *type, int32_t index);

/// Get the RezResourceHeader instance from the specified rez file for the specified id and type.
/// NULL will returned if the id does not exist.
RezResourceHeader *RezGetResourceHeaderOfTypeAtId(RezResourceFile *file, const char *type, int16_t id);

/// Get the block of data from the specified rez file for the specified id and type.
/// NULL will be returned if the id does not exist. The caller is expected to provide a location for
/// the memory to read into.
void RezGetResourceDataOfTypeAndId(RezResourceFile *file, const char *type, int16_t id, uint8_t **dst, size_t *size);

#endif
