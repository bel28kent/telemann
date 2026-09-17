#lang racket/base

(require (only-in racket/bool
                  symbol=?)
         racket/list
         racket/local
         "../../lib/io.rkt")

(define FILES
  (filter (lambda (path)
            (symbol=? 'file
                      (file-or-directory-type path)))
    (io_directory_tree "krn")))

(define (swap file)
  (cond [(empty? file) empty]
        [(and (regexp-match? #px"^={1}" (first file))
              (regexp-match? #px"!!LO:LB" (second file)))
         (cons (second file)
           (cons (first file)
             (swap (rest (rest file)))))]
        [else
          (cons (first file)
            (swap (rest file)))]))

(define (make-files paths)
  (cond [(empty? paths) (void)]
        [else
          (local [(define path (first paths))

                  (define write_path
                    (string-append (regexp-replace #px"\\.krn$" (path->string path) "")
                                   "-swap.krn"))]
            (begin (io_file_write write_path
                                  (swap (io_file_read path #:trim? #t)))
                   (make-files (rest paths))))]))

(make-files FILES)