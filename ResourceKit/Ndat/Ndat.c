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

#include "Ndat.h"
#include "Allocations.h"


#pragma mark - Prototype Declarations

NdatHeader *NdatParseHeader(NdatResourceFile *file);
int NdatParseResourceMap(NdatResourceFile *file);
NdatType *ParseNdatResourceType(NdatResourceFile *file);
NdatResource *ParseNdatResource(NdatResourceFile *file);



#pragma mark - File Access

NdatResourceFile *NdatOpenFile(const char *restrict path)
{
    assert(path);
    
    NdatResourceFile *file = New(sizeof(*file));
    file->path = NewString(path);
    
    errno = 0;
    if ( (file->handle = fopen(file->path, "r")) == NULL ) {
        fprintf(stderr, "*** Failed to open ndat file (code: %d): %s\n", errno, file->path);
        goto NDAT_OPEN_FILE_ERROR;
    }
    
    // Parse the header from the resource file.
    file->header = NdatParseHeader(file);
    
    if ( NdatParseResourceMap(file) == 0 ) {
        fprintf(stderr, "*** Failed to parse resource map for ndat file: %s\n", file->path);
        goto NDAT_OPEN_FILE_ERROR;
    }
    
    goto NDAT_OPEN_FILE_DONE;
    
NDAT_OPEN_FILE_ERROR:
    NdatCloseFile(file);
    file = NULL;
    
NDAT_OPEN_FILE_DONE:
    return file;
}

void NdatCloseFile(NdatResourceFile *file)
{
    if (file) {
        fclose(file->handle);
        free((void *)file->path);
        free(file);
    }
}


#pragma mark - Ndat Parsing

NdatHeader *NdatParseHeader(NdatResourceFile *file)
{
    assert(file);
    
    NdatHeader *header = New(sizeof(*header));
    
    // Read in the header. This header will specify where each of the sections of the
    // resource file are location. The file is split into two sections, resource data
    // and resource map.
    header->resourceDataOffset = FileReadLong(file->handle, DataBigEndian);
    header->resourceMapOffset = FileReadLong(file->handle, DataBigEndian);
    header->resourceDataSize = FileReadLong(file->handle, DataBigEndian);
    header->resourceMapSize = FileReadLong(file->handle, DataBigEndian);
    
    return header;
}

int NdatParseResourceMap(NdatResourceFile *file)
{
    assert(file);
    assert(file->header);
    
    // Move to the beginning of the resource map.
    FileSetCursorPosition(file->handle, file->header->resourceMapOffset);
    
    // We have some value to check first. These are all of the header values we read previously.
    // Let's double check them to ensure the resource file is valid.
    if (file->header->resourceDataOffset != FileReadLong(file->handle, DataBigEndian)) {
        fprintf(stderr, "*** Invalid Ndat file!! Resource Data Offset does not match\n");
        return 0;
    }
    
    if (file->header->resourceMapOffset != FileReadLong(file->handle, DataBigEndian)) {
        fprintf(stderr, "*** Invalid Ndat file!! Resource Map Offset does not match\n");
        return 0;
    }
    
    if (file->header->resourceDataSize != FileReadLong(file->handle, DataBigEndian)) {
        fprintf(stderr, "*** Invalid Ndat file!! Resource Data Size does not match\n");
        return 0;
    }
    
    if (file->header->resourceMapSize != FileReadLong(file->handle, DataBigEndian)) {
        fprintf(stderr, "*** Invalid Ndat file!! Resource Map Size does not match\n");
        return 0;
    }
    
    // The next value appears to be unused. Seems to be zero typically. Skip it.
    FileAdvanceCursorPosition(file->handle, sizeof(uint32_t) + sizeof(uint16_t));
    
    // The new value is an attributes mask. This will help determine how we should read
    // data.
    file->attributes = FileReadWord(file->handle, DataBigEndian);
    if (file->attributes & NdatAttributeCompression) {
        fprintf(stderr, "*** The Ndat file is compressed. This is not supported by ResourceKit.\n");
        return 0;
    }
    
    // Get the offsets to the type list and the name list.
    file->typeListOffset = FileReadWord(file->handle, DataBigEndian);
    file->nameListOffset = FileReadWord(file->handle, DataBigEndian);
    
    // Move to the beginning of the type list and determine how many types are included
    // in the resource file.
    FileSetCursorPosition(file->handle, file->header->resourceMapOffset + file->typeListOffset);
    file->typeCount = FileReadWord(file->handle, DataBigEndian) + 1;
    
    // Prepare to read each of the type structure.
    NdatType *previousType = NULL;
    for (int16_t i = 0; i < file->typeCount; ++i) {
        // Get the resource type structure and ensure it is added to the list of resource types.
        NdatType *type = ParseNdatResourceType(file);
        
        if (!file->types) {
            file->types = type;
        }
        else {
            previousType->next = type;
        }
        
        previousType = type;
    }
    
    return 1;
}

#pragma mark - Ndat Parsing Helpers

NdatType *ParseNdatResourceType(NdatResourceFile *file)
{
    // We're now going to jump to the start of the type list and begin parsing the information from
    // that.
    uint32_t typeListOffset = file->header->resourceMapOffset + file->typeListOffset;
    
    // Each type has the following information associated with it.
    //
    //  1. Type Code
    //  2. Resource Count
    //  3. Resource List Offset - offset from the start of the resource list
    //
    assert(file);
    
    NdatType *type = New(sizeof(*type));
    FileGetBytes(file->handle, 4, (void *)type->code);
    type->resourceCount = FileReadWord(file->handle, DataBigEndian) + 1;
    type->resourceListOffset = FileReadWord(file->handle, DataBigEndian);
    
    // Save the current offset and then seek to the appropriate place in the resource list,
    // so that we can determine each resource instance.
    fpos_t mapOffset = FileGetCursorPosition(file->handle);
    FileSetCursorPosition(file->handle, typeListOffset + type->resourceListOffset);
    
    NdatResource *previousResource = NULL;
    for (int16_t j = 0; j < type->resourceCount; ++j) {
        
        NdatResource *resource = ParseNdatResource(file);
        
        if (!type->resources) {
            type->resources = resource;
        }
        else {
            previousResource->next = resource;
        }
        previousResource = resource;
    }
    
    // Restore the resource map offset.
    FileSetCursorPosition(file->handle, mapOffset);
    
    return type;
}

NdatResource *ParseNdatResource(NdatResourceFile *file)
{
    uint32_t nameListOffset = file->header->resourceMapOffset + file->nameListOffset;
    
    assert(file);
    
    NdatResource *resource = calloc(1, sizeof(*resource));
    resource->id = FileReadWord(file->handle, DataBigEndian);
    
    int16_t nameOffset = FileReadWord(file->handle, DataBigEndian);
    if (nameOffset >= 0) {
        fpos_t currentOffset = FileGetCursorPosition(file->handle);
        FileSetCursorPosition(file->handle, nameListOffset + nameOffset);
        uint8_t length = FileReadByte(file->handle, DataBigEndian);
        FileGetBytes(file->handle, length, (void *)resource->name);
        FileSetCursorPosition(file->handle, currentOffset);
    }
    
    resource->attributes = FileReadByte(file->handle, DataBigEndian);
    uint32_t v1 = (FileReadWord(file->handle, DataBigEndian) << 8) & 0xFFFF00;
    uint32_t v2 = FileReadByte(file->handle, DataBigEndian);
    resource->dataOffset = v1 | v2;
    
    // Calculate the actual location in the file.
    uint32_t trueOffset = file->header->resourceDataOffset + resource->dataOffset;
    fpos_t currentOffset = FileGetCursorPosition(file->handle);
    FileSetCursorPosition(file->handle, trueOffset);
    resource->size = FileReadLong(file->handle, DataBigEndian);
    FileSetCursorPosition(file->handle, currentOffset);
    
    FileAdvanceCursorPosition(file->handle, sizeof(uint32_t));
    
    return resource;
}


#pragma mark - Accessors & Lookup

NdatType *NdatGetResourceTypeAtIndex(NdatResourceFile *file, int32_t index)
{
    assert(file);
    
    if (index >= file->typeCount|| index < 0) {
        return NULL;
    }
    
    NdatType *type = file->types;
    while (index-- > 0 && type) {
        type = type->next;
    }
    return type;
}

NdatType *NdatGetResourceTypeForCode(NdatResourceFile *file, const char *code)
{
    assert(file);
    assert(code);
    
    NdatType *type = file->types;
    while (type && strncmp(type->code, code, 4) != 0) {
        type = type->next;
    }
    return type;
}

NdatResource *NdatGetResourceHeaderOfTypeAtIndex(NdatResourceFile *file, const char *typeCode, int32_t index)
{
    assert(file);
    
    NdatType *type = NdatGetResourceTypeForCode(file, typeCode);
    if (index >= type->resourceCount || index < 0) {
        return NULL;
    }
    
    NdatResource *resource = type->resources;
    while (resource) {
        if (index-- == 0) {
            break;
        }
        resource = resource->next;
    }
    return resource;
}

NdatResource *NdatGetResourceHeaderOfTypeAtId(NdatResourceFile *file, const char *typeCode, int16_t id)
{
    assert(file);
    assert(typeCode);
    
    NdatType *type = NdatGetResourceTypeForCode(file, typeCode);
    NdatResource *resource = type->resources;
    while (resource) {
        if (resource->id == id) {
            break;
        }
        resource = resource->next;
    }
    
    return resource;
}

void NdatGetResourceDataOfTypeAndId(NdatResourceFile *file, const char *type, int16_t id, uint8_t **dst, size_t *size)
{
    assert(dst);
    assert(file);
    assert(size);
    
    NdatResource *resource = NdatGetResourceHeaderOfTypeAtId(file, type, id);
    *dst = calloc(resource->size, sizeof(**dst));
    *size = resource->size;
    
    FileSetCursorPosition(file->handle, file->header->resourceDataOffset + resource->dataOffset + sizeof(int32_t));
    FileGetBytes(file->handle, resource->size, *dst);
}
