#lang racket/base

(require "../../lib/io.rkt"
         racket/list
         racket/symbol)

(define FILES
        (filter (lambda (path) (symbol=? 'file (file-or-directory-type path)))
          (io_directory_tree "krn")))

(define (move-filename path)
  (local [(define file (io_file_read path #:trim? #t))

          (define (move records_old records_new)
            (cond [(empty? records_old) (error "reached empty instead of filename" path)]
                  [(regexp-match? #px"^!!!filename" (first records_old))
                   (cons (first records_old)
                         (reverse records_new))]
                  [else
                    (move (rest records_old)
                          (cons (first records_old) records_new))]))]
    (move file empty)))

(define (iterator paths)
  (cond [(empty? paths) (void)]
        [else
          (local [(define records_new (move-filename (first paths)))]
            (io_file_write (string-replace (path->string (first paths)) "tele" "temp-tele")
                           records_new))]))

(iterator FILES)