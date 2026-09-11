#lang racket/base



#|
	Programmer:  Bryan Jacob Bell
	Begun:       Wed May  6 21:54:08 EDT 2026
	Modified:    Sat Aug  8 22:09:44 EDT 2026
	File:        io.rkt
	Syntax:      Racket
	Description: re-use i/o functions
|#



(require (only-in racket/bool
                  false?
                  symbol=?)

         (only-in racket/list
                  empty
                  empty?
                  first
                  rest)

         racket/local

         (only-in racket/string
                  string-trim))



(provide io_directory_make
         io_directory_read
         io_directory_tree

         io_file_read
         io_file_write

         io_stdout_print
         io_stdout_list

         io_type
         io_type_is?)



(define io_directory_make
  (λ (path)
    (with-handlers ([exn:fail:filesystem? (λ (exn) #f)])
      (make-directory path))))



(define io_directory_read
  (λ (path #:to_string? [to_string? #f] #:append? [append? #f])
    (with-handlers ([exn:fail:filesystem? (λ (exn) #f)])
      (local [(define contents
                      (if append?
                          (directory-list path #:build? #t)
                          (directory-list path)))]
        (if to_string?
            (map path->string contents)
            contents)))))



(define io_directory_tree
  ;	File
  ;		(struct file filename records)
  ;		(file String (listof Any))
  ;		a module of arbitrary data
  ;
  ;	Directory
  ;		(struct directory dirname contents)
  ;		(directory String (listof File|FileSystemTree))
  ;		a named collection of Files and Directories
  ;
  ;	FileSystemTree
  ;		- empty
  ;		- (cons Directory FileSystemTree)
  ;		a collection of Directories
  (λ (path #:to_string? [to_string? #f])
    (local [(define fn_for_file
              (λ (file)
                (if to_string?
                    (path->string file)
                    file)))

            (define fn_for_directory
              (λ (directory)
                (cond [(empty? directory) empty]
                      [(io_type_is? (first directory) 'file)
                       (cons (fn_for_file (first directory))
                             (fn_for_directory (rest directory)))]
                      [else
                        (append (if to_string?
                                    (list (path->string (first directory)))
                                    (list (first directory)))
                                (fn_for_file_system_tree (directory-list (first directory) #:build? #t))
                                (fn_for_directory (rest directory)))])))

            (define fn_for_file_system_tree
              (λ (file_system_tree)
                (cond [(empty? file_system_tree) empty]
                      [else
                        (if (io_type_is? (first file_system_tree) 'file)
                            (cons (fn_for_file (first file_system_tree))
                                  (fn_for_file_system_tree (rest file_system_tree)))
                            (append (if to_string?
                                        (list (path->string (first file_system_tree)))
                                        (list (first file_system_tree)))
                                    (fn_for_directory (directory-list (first file_system_tree) #:build? #t))
                                    (fn_for_file_system_tree (rest file_system_tree))))])))]
      (append (if to_string?
                  (list (path->string path))
                  (list path))
              (fn_for_file_system_tree (directory-list path #:build? #t))))))



(define io_file_read
  (λ (path #:header? [header? #f] #:trim? [trim? #f])
    (local [(define reader
              (λ (in)
                (local [(define line (read-line in))]
                  (if (eof-object? line)
                      empty
                      (cons (if trim?
                                (string-trim line)
                                line)
                        (reader in))))))

            (define records
              (with-handlers ([exn:fail:filesystem? (λ (exn) #f)])
                (call-with-input-file path
                  (λ (in) (reader in)))))]
      (if header?
          (list-tail records 1)
          records))))



(define io_file_write
  (λ (path records)
    (with-handlers ([exn:fail:filesystem? (λ (exn) #f)])
      (call-with-output-file path
        (λ (out)
          (for-each (λ (r) (displayln r out)) records))
        #:exists 'error))))



(define io_record_chomp
  ; TODO
  ; perl-style function to remove a given input record separator from each record
  (λ (records input_record_separator)
    #f))



(define io_stdout_print
  (λ (datum)
    (displayln datum)))



(define io_stdout_list
  (λ (data)
    (for-each displayln data)))



(define io_type
  (λ (path)
    (local [(define type (file-or-directory-type path #t))]
      (cond [(false? type) #f]
            [(or (symbol=? type 'link) (symbol=? type 'directory-link)) #f]
            [else
              type]))))



(define io_type_is?
  (λ (path type)
    (local [(define actual_type (file-or-directory-type path #t))]
      (cond [(false? actual_type) #f]
            [(symbol=? type actual_type) #t]
            [else
              #f]))))
