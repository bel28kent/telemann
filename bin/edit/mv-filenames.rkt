#lang racket/base

(require "../../lib/io.rkt"
         (only-in racket/list
                  empty
                  empty?
                  first
                  last
                  rest)
         racket/local
         (only-in racket/bool symbol=?)
         (only-in racket/string string-replace))

(define FILES
        (filter (lambda (path) (symbol=? 'file (file-or-directory-type path)))
          (io_directory_tree "krn")))

(define (iterator paths)
  (cond [(empty? paths) (void)]
        [else
          (local [(define file (io_file_read (first paths) #:trim? #t))

                  (define temp_path (string-replace (path->string (first paths))
                                                    "tele"
                                                    "temp-tele"))]
            (begin (io_file_write temp_path
                                  (cons (last file)
                                        (filter (lambda (record)
                                                        (not (regexp-match? #px"filename" record)))
                                                file)))
                   (iterator (rest paths))))]))

(iterator FILES)