#lang racket/base

#|
# Programmer:  Bryan Jacob Bell
# Begun:       Tue Oct 29 12:28:57 PDT 2024
# Modified:    Tue Nov 12 14:13:15 PST 2024
# File:        makeKeys.rkt
# Syntax:      Racket
# Description: make keys for telemann files
|#

(require racket/list
         racket/local
         racket/string
         script-functions)

(define file (read-file "../metadata/reference_records.tsv" #t))
(define splits (map (λ (s) (split s "\t")) file))

; make-key
; (listof (listof String)) -> (listof String)
; concatenate "tele-", TWV-genre (7), TWV-work (8), OTL (10), OMD (11), OMV (12), AIN (17)

(define (make-key split)
  (string-append "tele-"
                 (list-ref split 7)
                 "-"
                 (handle-single-digit (list-ref split 8))
                 "-"
                 (substring (list-ref split 10) 0 3)
                 "-"
                 (handle-spaces (substring (list-ref split 11) 0 3))
                 "-"
                 (handle-single-digit (list-ref split 12))
                 "-"
                 (instrument-name (list-ref split 17))))

; handle-single-digit
; String -> String
; if a length one, add "0"

(define (handle-single-digit s)
  (if (= (string-length s) 1)
      (string-append "0" s)
      s))

; handle-spaces
; String -> String
; replace spaces in string with "_"

(define (handle-spaces s)
  (local [(define (handle-spaces los)
            (cond [(empty? los) ""]
                  [(string=? (first los) " ") (string-append "_" (handle-spaces (rest los)))]
                  [else
                    (string-append (first los) (handle-spaces (rest los)))]))]
    (handle-spaces (string-split s ""))))

; instrument-name
; String -> String
; produce string name

(define (instrument-name s)
  (cond [(or (string=? s "Violin")
             (string=? s "Oboe"))        s]
        [(string=? s "Viola da gamba")   "Viol"]
        [(string=? s "Transverse flute") "Flute"]
        [(string=? s "Flauto dolce")     "Flauto"]
        [else
          "ViolinOrFlute"]))

(for-each displayln (map make-key splits))
