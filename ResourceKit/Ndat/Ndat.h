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

#ifndef ResourceKit_Ndat_h
#define ResourceKit_Ndat_h

#include "DataFile.h"

/// The Ndat Attributes denote information about the data of a particular resource.
/// This is information on how the data should be handled by the program reading
/// the data. The two important ones are included in the enum, but they seem to be
/// unused by Nova Data Files. Regardless we'll include them and put an error case
/// in for them so that if they are discovered to be used they can be implemented.
typedef enum _NdatAttributes {
    NdatAttributeReadOnly = 0x0080,
    NdatAttributeCompression = 0x0040,
} NdatAttributes;


struct _Ndat;
struct _NdatHeader;
struct _NdatType;
struct _NdatResource;


/// The basic Ndat header contains layout information for the ResourceFork. It
/// specifies where all of the data for the resources can be found and where the
/// resource map can be found.
typedef struct _NdatHeader {
    int32_t resourceDataOffset;
    int32_t resourceMapOffset;
    int32_t resourceDataSize;
    int32_t resourceMapSize;
} NdatHeader;

/// The Ndat type structure contains information about a particular resource type.
/// This includes information such as the number of resource instances that are
/// present in the file, the offset of those resources from the start of the resource
/// map and the type code of the resources.
typedef struct _NdatType {
    struct _NdatType *next;
    char code[5];
    uint16_t resourceCount;
    uint16_t resourceListOffset;
    struct _NdatResource *resources;
} NdatType;

/// The Ndat resource structure contains information about a particular resource
/// instance. It contains information such as the id, name and the offset of
/// the resource data.
typedef struct _NdatResource {
    struct _NdatResource *next;
    char name[256];
    int16_t id;
    uint8_t attributes;
    uint32_t dataOffset;
    uint32_t size;
} NdatResource;

/// The Ndat structure holds all key information about the format of the resource file
/// being represented. Instances of this structure should be passed around and used
/// as a reference/handle to the resource file.
typedef struct _Ndat {
    NdatHeader *header;
    FILE *handle;
    const char *path;
    NdatAttributes attributes;
    int16_t typeListOffset;
    int16_t nameListOffset;
    int16_t typeCount;
    NdatType *types;
} NdatResourceFile;


/// Open a new NdatResourceFile for the file at the specified path. This will return
/// NULL if there was a problem opening the file for any reason. Any errors will be printed
/// to stderr.
NdatResourceFile *NdatOpenFile(const char *restrict path);

/// Close the NdatResourceFile specified. This will also release and clean up any memory of types
/// a resources owned by this file. Files should only be closed once all resources have been finished
/// with.
void NdatCloseFile(NdatResourceFile *file);

NdatType *NdatGetResourceTypeAtIndex(NdatResourceFile *file, int32_t index);
NdatType *NdatGetResourceTypeForCode(NdatResourceFile *file, const char *code);
NdatResource *NdatGetResourceHeaderOfTypeAtIndex(NdatResourceFile *file, const char *typeCode, int32_t index);
NdatResource *NdatGetResourceHeaderOfTypeAtId(NdatResourceFile *file, const char *typeCode, int16_t id);
void NdatGetResourceDataOfTypeAndId(NdatResourceFile *file, const char *type, int16_t id, uint8_t **dst, size_t *size);

#endif /* Ndat_h */
