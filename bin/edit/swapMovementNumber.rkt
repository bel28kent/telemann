#lang racket/base

(require racket/bool
         racket/list
         racket/local
         racket/string
         "../../lib/io.rkt")

(provide FILES
         get-directory
         get-old-key)

(define FILES
  (filter (lambda (path) (symbol=? 'file (file-or-directory-type path)))
    (io_directory_tree "krn")))

(define (get-directory path_string)
  (first
    (regexp-match #px"^krn/(.+/){1,2}" path_string)))

(define (get-old-key path_string)
  (string-replace (first (regexp-match #px"tele(-.+){6}" path_string))
                  ".krn"
                  ""))

(define (new-key old-key)
  (local [(define fields (string-split old-key "-"))]
    (string-append (list-ref fields 0)
                   "-"
                   (list-ref fields 1)
                   "-"
                   (list-ref fields 2)
                   "-"
                   (list-ref fields 3)
                   "-"
                   (list-ref fields 5)
                   "-"
                   (list-ref fields 4)
                   "-"
                   (list-ref fields 6))))

(define (make-keys paths)
  (cond [(empty? paths) (void)]
        [else
          (local [(define path        (first paths))
                  (define path_string (path->string path))
                  (define directory   (get-directory path_string))
                  (define new_key     (new-key (get-old-key path_string)))
                  (define file        (io_file_read path #:trim? #t))]
            (begin (io_file_write (string-append directory "temp-" new_key ".krn")
                                  (foldr (lambda (f r)
                                                 (if (regexp-match? #px"^!!!filename:" f)
                                                     (cons (string-append "!!!filename: " new_key) r)
                                                     (cons f r)))
                                         empty
                                         file))
                   (make-keys (rest paths))))]))

(make-keys FILES)
