#include <stdio.h>
#include "minilisp.h"
#include "alloc.h"
#include "stream.h"
#include "compiler_new.h"
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>

Cell* _file_cell;

Cell* posixfs_open(Cell* cpath) {
  char* path;
  _file_cell = alloc_nil();

  if (!cpath || cpath->tag!=TAG_STR) {
    printf("[posixfs] open error: non-string path given\r\n");
    return _file_cell;
  }

  path = cpath->ar.addr;
  
  if (!strncmp(path,"/sd/",4)) {
    char* filename = NULL;

    if (strlen(path)>4) {
      filename = path+4;
    }

    if (!filename || !filename[0]) filename = ".";

    //printf("filename: %s\r\n",filename);
    
    if (filename) {
      struct stat src_stat;
      DIR* dirp;
      int f;
      off_t len;
      
      if (stat(filename, &src_stat)) {
        _file_cell = alloc_string_copy("<file not found>");
        return _file_cell;
      }
      len = src_stat.st_size;

      if ((dirp = opendir(filename))) {
        struct dirent *dp;
        Cell* nl = alloc_string_copy("\n");
        _file_cell = alloc_string_copy("");
        
        do {
          if ((dp = readdir(dirp)) != NULL) {
            printf("dp: |%s|\r\n",dp->d_name);
            _file_cell = alloc_concat(_file_cell,alloc_concat(alloc_string_copy(dp->d_name),nl));
          }
        } while (dp != NULL);
        return _file_cell;
      }

      f = open(filename, O_RDONLY);
      if (f>-1) {
        Cell* res;
        
        printf("[posixfs] trying to read file of len %ld...\r\n",len);
        res = alloc_num_bytes(len);
        read(f, res->ar.addr, len);
        close(f);
        // TODO: close?
        _file_cell = res;
        return res;
      } else {
        // TODO should return error
        printf("[posixfs] could not open file :(\r\n");
        _file_cell = alloc_string_copy("<error: couldn't open file.>"); // FIXME hack
        return _file_cell;
      }
      _file_cell = alloc_string_copy("<error: file not found.>");
      return _file_cell;
    } else {
      // TODO dir
    }
  }

  return _file_cell;
}

Cell* posixfs_read(Cell* stream) {
  return _file_cell;
}

Cell* posixfs_write(Cell* stream_cell, Cell* arg) {
  if (!stream_cell || stream_cell->tag != TAG_STREAM) {
    printf("[posixfs] write error: non-stream argument given\n");
    return alloc_nil();
  }

  if (!arg || (arg->tag != TAG_BYTES && arg->tag != TAG_STR)) {
    printf("[posixfs] write error: non-bytes/string argument given\n");
    return alloc_nil();
  }

  Stream* stream = stream_cell->ar.addr;
  Cell* cpath = stream->path;
  if (!cpath || cpath->tag!=TAG_STR) {
    printf("[posixfs] write error: non-string path in stream\n");
    return alloc_nil();
  }

  char* path = cpath->ar.addr;
  printf("[posixfs] writing to %s\n", path);

  if (!strncmp(path,"/sd/",4)) {
    char* filename = NULL;
    int f;

    if (strlen(path)>4) {
      filename = path+4;
    }

    if (!filename || !filename[0]) filename = ".";

    f = open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    printf("[posixfs] opened %s\n", filename);
    if (f > -1) {
      void *buf = arg->ar.addr;
      ssize_t size = arg->dr.size;
      ssize_t ret = write(f, buf, size);
      close(f);

      if (ret == size) {
        printf("[posixfs] wrote %zi bytes to %s\n", size, filename);
        return alloc_int(size);
      } else {
        printf("[posixfs] write error: couldn't write to file: %s\n", filename);
        return alloc_nil();
      }
    } else {
      printf("[posixfs] write error: could not open file: %s\n", filename);
      return alloc_nil();
    }
  }

  return alloc_nil();
}

Cell* posixfs_mmap(Cell* arg) {
  return alloc_nil();
}

void mount_posixfs() {
  fs_mount_builtin("/sd", posixfs_open, posixfs_read, posixfs_write, 0, posixfs_mmap);
}

