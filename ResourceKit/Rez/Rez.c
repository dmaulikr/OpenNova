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

#include <errno.h>
#include <assert.h>
#include <stdlib.h>

#include "Rez.h"
#include "Allocations.h"

#pragma mark - Prototype Declarations

RezHeader *RezParseHeader(RezResourceFile *file);
RezDataRange *RezParseDataRanges(RezResourceFile *file);
RezResourceFile *RezParseResourceMap(RezResourceFile *file);
RezResourceType *RezParseResourceTypes(RezResourceFile *file);
RezResourceHeader *RezParseResourceHeaders(RezResourceFile *file);

void RezHeaderFree(RezHeader *header);
void RezDataRangeListFree(RezDataRange *node);
void RezResourceTypeListFree(RezResourceType *node);
void RezResourceHeaderListFree(RezResourceHeader *node);


#pragma mark - File Access

RezResourceFile *RezOpenFile(const char *restrict path)
{
    assert(path);

    RezResourceFile *file = New(sizeof(*file));
    file->path = NewString(path);
    file->currentEndian = DataLittleEndian;

    errno = 0;
    if ( (file->handle = fopen(file->path, "r")) == NULL ) {
        fprintf(stderr, "*** Failed to open rez file (code: %d): %s\n", errno, file->path);
        goto REZ_OPEN_FILE_ERROR;
    }

    if ( (file->header = RezParseHeader(file)) == NULL ) {
        fprintf(stderr, "*** Failed to read the header from the rez file: %s\n", file->path);
        goto REZ_OPEN_FILE_ERROR;
    }

    // Technically can't fail on this next one due to it being entirely possible for no
    // resources to exist in the file.
    file->dataRange = RezParseDataRanges(file);

    // Move on to parsing the resource map. This can technically fail early on.
    if ( (file = RezParseResourceMap(file)) == NULL ) {
        fprintf(stderr, "*** Failed to read the resource.map from the rez file: %s\n", file->path);
        goto REZ_OPEN_FILE_ERROR;
    }

    goto REZ_OPEN_FILE_DONE;

REZ_OPEN_FILE_ERROR:
    RezClosefile(file);
    file = NULL;

REZ_OPEN_FILE_DONE:
    return file;
}

void RezClosefile(RezResourceFile *file)
{
    if (file) {
        RezResourceHeaderListFree(file->resource);
        RezResourceTypeListFree(file->type);
        RezDataRangeListFree(file->dataRange);
        RezHeaderFree(file->header);
        fclose(file->handle);
        free((void *)file->path);
        free(file);
    }
}


#pragma mark - Rez Parsing

RezHeader *RezParseHeader(RezResourceFile *file)
{
    assert(file);

    RezHeader *header = New(sizeof(*(file->header)));
    header->fileLength = FileGetLength(file->handle);

    if ( FileReadLong(file->handle, file->currentEndian) != 'RGRB' ) {
        fprintf(stderr, "*** Failed to find the expected magic number.\n");
        goto REZ_HEADER_ERROR;
    }

    FileAdvanceCursorPosition(file->handle, sizeof(uint32_t) * 4);
    header->resourceCount = FileReadLong(file->handle, file->currentEndian);

    goto REZ_HEADER_DONE;

REZ_HEADER_ERROR:
    RezHeaderFree(header);
    header = NULL;

REZ_HEADER_DONE:
    return header;
}


RezDataRange *RezParseDataRanges(RezResourceFile *file)
{
    assert(file);

    RezDataRange *firstRange = NULL;
    RezDataRange *lastRange = NULL;

    for (uint32_t i = 0; i < file->header->resourceCount; ++i) {
        RezDataRange *range = New(sizeof(*range));
        range->offset = FileReadLong(file->handle, file->currentEndian);
        range->size = FileReadLong(file->handle, file->currentEndian);

        firstRange = firstRange ?: range;
        lastRange = lastRange ? (lastRange->next = range) : range;

        FileAdvanceCursorPosition(file->handle, sizeof(uint32_t));
    }

    return firstRange;
}

RezResourceFile *RezParseResourceMap(RezResourceFile *file)
{
    assert(file);

    char *resourceMapString = (char *)FileReadData(file->handle, 12);
    if ( strncmp(resourceMapString, "resource.map", 12) != 0 ) {
        fprintf(stderr, "*** Expected to find the resource.map section in rez file.\n");
        free(resourceMapString);
        return NULL;
    }
    free(resourceMapString);

    // Calculate some of the positions in the rez file.
    file->header->resourceOffset = FileGetCursorPosition(file->handle);
    file->header->resourceMapOffset = RezGetDataRangeAtIndex(file, (int32_t)file->header->resourceCount - 1)->offset;

    // We're now going to switch into a big endian format. All remaining data in the rez
    // file should now be in this format.
    file->currentEndian = DataBigEndian;

    // Get to the start of the resource map and skip the first long as it is unused.
    FileSetCursorPosition(file->handle, file->header->resourceMapOffset);
    FileAdvanceCursorPosition(file->handle, sizeof(uint32_t));

    file->header->typeCount = FileReadLong(file->handle, file->currentEndian);
    file->type = RezParseResourceTypes(file);
    file->resource = RezParseResourceHeaders(file);

    return file;
}

RezResourceType *RezParseResourceTypes(RezResourceFile *file)
{
    assert(file);

    RezResourceType *firstType = NULL;
    RezResourceType *lastType = NULL;

    for (uint32_t i = 0; i < file->header->typeCount; ++i) {
        RezResourceType *type = New(sizeof(*type));

        FileGetBytes(file->handle, 4, type->code);
        type->firstResourceOffset = FileReadLong(file->handle, file->currentEndian);
        type->resourceCount = FileReadLong(file->handle, file->currentEndian);

        firstType = firstType ?: type;
        lastType = lastType ? (lastType->next = type) : type;
    }
    
    return firstType;
}

RezResourceHeader *RezParseResourceHeaders(RezResourceFile *file)
{
    assert(file);

    RezResourceHeader *firstResource = NULL;
    RezResourceHeader *lastResource = NULL;

    for (uint32_t i = 0; i < file->header->resourceCount - 1; ++i) {
        RezResourceHeader *resource = New(sizeof(*resource));

        uint32_t dataRangeIndex = FileReadLong(file->handle, file->currentEndian);
        RezDataRange *range = RezGetDataRangeAtIndex(file, dataRangeIndex - 1);

        FileGetBytes(file->handle, 4, resource->typeCode);
        resource->id = FileReadWord(file->handle, file->currentEndian);
        FileGetBytes(file->handle, 256, resource->name);

        resource->owner = file;
        resource->offset = range->offset;
        resource->size = range->size;

        firstResource = firstResource ?: resource;
        lastResource = lastResource ? (lastResource->next = resource) : resource;
    }
    
    return firstResource;
}


#pragma mark - Rez Memory Management

void RezHeaderFree(RezHeader *header)
{
    free(header);
}

void RezDataRangeListFree(RezDataRange *node)
{
    while (node) {
        void *next = node->next;
        free(node);
        node = next;
    }
}

void RezResourceTypeListFree(RezResourceType *node)
{
    while (node) {
        void *next = node->next;
        free(node);
        node = next;
    }
}

void RezResourceHeaderListFree(RezResourceHeader *node)
{
    while (node) {
        void *next = node->next;
        free(node);
        node = next;
    }
}


#pragma mark - Accessors & Lookup

RezDataRange *RezGetDataRangeAtIndex(RezResourceFile *file, int32_t index)
{
    assert(file);

    if (index >= file->header->resourceCount || index < 0) {
        return NULL;
    }

    RezDataRange *range = file->dataRange;
    while (index-- > 0 && range) {
        range = range->next;
    }
    return range;
}

RezResourceType *RezGetResourceTypeAtIndex(RezResourceFile *file, int32_t index)
{
    assert(file);

    if (index >= file->header->typeCount || index < 0) {
        return NULL;
    }

    RezResourceType *type = file->type;
    while (index-- > 0 && type) {
        type = type->next;
    }
    return type;
}

RezResourceType *RezGetResourceTypeForCode(RezResourceFile *file, const char *code)
{
    assert(file);
    assert(code);

    RezResourceType *type = file->type;
    while (type && strncmp(type->code, code, 4) != 0) {
        type = type->next;
    }
    return type;
}

RezResourceHeader *RezGetResourceHeaderAtIndex(RezResourceFile *file, int32_t index)
{
    assert(file);

    if (index >= file->header->resourceCount || index < 0) {
        return NULL;
    }

    RezResourceHeader *resource = file->resource;
    while (index-- > 0 && resource) {
        resource = resource->next;
    }
    return resource;
}

RezResourceHeader *RezGetResourceHeaderOfTypeAtIndex(RezResourceFile *file, const char *typeCode, int32_t index)
{
    assert(file);

    RezResourceType *type = RezGetResourceTypeForCode(file, typeCode);
    if (index >= type->resourceCount || index < 0) {
        return NULL;
    }

    RezResourceHeader *resource = file->resource;
    while (resource) {
        if ( strncmp(resource->typeCode, typeCode, 4) == 0 ) {
            if (index == 0) {
                break;
            }
            index--;
        }
        resource = resource->next;
    }
    return resource;
}

RezResourceHeader *RezGetResourceHeaderOfTypeAtId(RezResourceFile *file, const char *typeCode, int16_t id)
{
    assert(file);
    assert(typeCode);

    RezResourceHeader *resource = file->resource;
    while (resource) {
        if ( strncmp(resource->typeCode, typeCode, 4) == 0 && resource->id == id ) {
            break;
        }
        resource = resource->next;
    }
    return resource;
}

void RezGetResourceDataOfTypeAndId(RezResourceFile *file, const char *type, int16_t id, uint8_t **dst, size_t *size)
{
    assert(dst);
    assert(file);
    assert(size);

    RezResourceHeader *resource = RezGetResourceHeaderOfTypeAtId(file, type, id);
    *dst = calloc(resource->size, sizeof(**dst));
    *size = resource->size;

    FileSetCursorPosition(file->handle, resource->offset);
    FileGetBytes(file->handle, resource->size, *dst);
}
