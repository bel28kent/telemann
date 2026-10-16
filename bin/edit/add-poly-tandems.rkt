#lang racket/base

(require "../../lib/humdrum.rkt"
         "../../lib/io.rkt"
         (only-in racket/bool
                  false?)
         (only-in racket/list
                  empty?
                  first
                  second
                  third
                  rest)
         racket/local
         (only-in racket/string
                  string-replace
                  string-split))

(define PATH_POLY
  (append (io_directory_read "krn/metodiche"  #:append? #t)
          (io_directory_read "krn/essercizii" #:append? #t)))

(define (get_instrumentation instrumentation path)
  (cond [(regexp-match? #px"^Flauto"        instrumentation) TANDEM_INSTRUMENT_FLAUTO]
        [(regexp-match? #px"^Flute"         instrumentation) TANDEM_INSTRUMENT_FLUTE]
        [(regexp-match? #px"^Oboe"          instrumentation) TANDEM_INSTRUMENT_OBOE]
        [(regexp-match? #px"^Viol"          instrumentation) TANDEM_INSTRUMENT_VIOL]
        [(regexp-match? #px"^ViolinOrFlute" instrumentation) TANDEM_INSTRUMENT_VOF]
        [(regexp-match? #px"^Violin"        instrumentation) TANDEM_INSTRUMENT_VIOLIN]
        [else
          (error "could not identify instrumentation" path)]))

(define (get_clef instrumentation)
  (if (string=? instrumentation "Viol")
      TANDEM_CLEF_TENOR
      TANDEM_CLEF_TREBLE))

(define (get_key_signature key path)
  ; N.B. TWV uses German nomenclature
  (cond [(regexp-match? #px"A" key) TANDEM_KEY_SIGNATURE_3_SHARP]
        [(regexp-match? #px"B" key) TANDEM_KEY_SIGNATURE_2_FLAT]
        [(regexp-match? #px"C" key) TANDEM_KEY_SIGNATURE_EMPTY]
        [(regexp-match? #px"D" key) TANDEM_KEY_SIGNATURE_2_SHARP]
        [(regexp-match? #px"E" key) TANDEM_KEY_SIGNATURE_4_SHARP]
        [(regexp-match? #px"F" key) TANDEM_KEY_SIGNATURE_1_FLAT]
        [(regexp-match? #px"G" key) TANDEM_KEY_SIGNATURE_2_SHARP]
        [(regexp-match? #px"a" key) TANDEM_KEY_SIGNATURE_EMPTY]
        [(regexp-match? #px"c" key) TANDEM_KEY_SIGNATURE_3_FLAT]
        [(regexp-match? #px"d" key) TANDEM_KEY_SIGNATURE_1_FLAT]
        [(regexp-match? #px"e" key) TANDEM_KEY_SIGNATURE_1_SHARP]
        [(regexp-match? #px"g" key) TANDEM_KEY_SIGNATURE_2_FLAT]
        [(regexp-match? #px"h" key) TANDEM_KEY_SIGNATURE_2_SHARP]
        [else
          (error "could not identify key signature" path)]))

(define (get_key_label key path)
  ; N.B. TWV uses German nomenclature
  (cond [(regexp-match? #px"A" key) TANDEM_KEY_LABEL_A_MAJOR]
        [(regexp-match? #px"B" key) TANDEM_KEY_LABEL_BF_MAJOR]
        [(regexp-match? #px"C" key) TANDEM_KEY_LABEL_C_MAJOR]
        [(regexp-match? #px"D" key) TANDEM_KEY_LABEL_D_MAJOR]
        [(regexp-match? #px"E" key) TANDEM_KEY_LABEL_E_MAJOR]
        [(regexp-match? #px"F" key) TANDEM_KEY_LABEL_F_MAJOR]
        [(regexp-match? #px"G" key) TANDEM_KEY_LABEL_G_MAJOR]
        [(regexp-match? #px"a" key) TANDEM_KEY_LABEL_A_MINOR]
        [(regexp-match? #px"c" key) TANDEM_KEY_LABEL_C_MINOR]
        [(regexp-match? #px"d" key) TANDEM_KEY_LABEL_D_MINOR]
        [(regexp-match? #px"e" key) TANDEM_KEY_LABEL_E_MINOR]
        [(regexp-match? #px"g" key) TANDEM_KEY_LABEL_G_MINOR]
        [(regexp-match? #px"h" key) TANDEM_KEY_LABEL_B_MINOR]
        [else
          (error "could not identify key signature" path)]))

(define (get_met time_signature)
  (cond [(string=? time_signature "*M4/4") TANDEM_MET_COMMON_TIME]
        [(string=? time_signature "*M2/2") TANDEM_MET_CUT_TIME]
        [else
          #f]))

(define (get_tempo tempo path)
  (cond [(string=? tempo "Ada") "Adagio"]
        [(string=? tempo "Aff") "Affettuoso"]
        [(string=? tempo "All") "Allegro"]
        [(string=? tempo "And") "Andante"]
        [(string=? tempo "Can") "Cantabile"]
        [(string=? tempo "Con") "Con tenerezza"]
        [(string=? tempo "Cor") "Cortesemente"]
        [(string=? tempo "Cun") "Cunando"]
        [(string=? tempo "Dol") "Dolce"]
        [(string=? tempo "Gra") "Grave"]
        [(string=? tempo "Lar") "Largo"]
        [(string=? tempo "Mes") "Mesto"]
        [(string=? tempo "Ond") "Ondeggiando"]
        [(string=? tempo "Pre") "Presto"]
        [(string=? tempo "Rec") "Recitativo"]
        [(string=? tempo "Sic") "Siciliana"]
        [(string=? tempo "Soa") "Soave"]
        [(string=? tempo "Spi") "Spirituoso"]
        [(string=? tempo "Tem") "Tempo giusto"]
        [(string=? tempo "Viv") "Vivace"]
        [else
          (error "could not identify tempo" path)]))

(define (tandem path)
  (local [(define path_string          (path->string path))
          (define path_fields          (string-split path_string "-"))
          (define path_key             (list-ref     path_fields 2))
          (define path_tempo           (list-ref     path_fields 5))
          (define path_instrumentation (list-ref     path_fields 6))

          (define records_old          (io_file_read path #:trim? #f))

          (define filename             (first               records_old))
          (define exclusive            (second              records_old))
          (define instrumentation      (get_instrumentation path_instrumentation path))
          (define clef                 (get_clef            instrumentation))
          (define key_signature        (get_key_signature   path_key             path))
          (define key_label            (get_key_label       path_key             path))
          (define time_signature       (third               records_old))
          (define met                  (get_met
                                         (first
                                           (string-split time_signature TAB))))
          (define tempo                (get_tempo           path_tempo           path))]
    (append (list filename
                  exclusive
                  (string-append TANDEM_INSTRUMENT_CONTINUO TAB TANDEM_INSTRUMENT_CONTINUO TAB instrumentation)
                  (string-append TANDEM_CLEF_BASS           TAB TANDEM_NULL                TAB clef)
                  (string-append key_signature              TAB TANDEM_NULL                TAB key_signature)
                  (string-append key_label                  TAB TANDEM_NULL                TAB key_label)
                  (string-append time_signature
                                 (if (not (false? met))
                                     (string-append NEWLINE
                                                    (string-append met TAB TANDEM_NULL TAB met))
                                     ""))
                  (string-append REFERENCE_RECORD_MOVEMENT_DESIGNATION SPACE tempo))
            (list-tail records_old 3))))

(define (iterator paths)
  (cond [(empty? paths) (void)]
        [else
          (local [(define filename
                    (call-with-input-file (first paths)
                                          (lambda (path)
                                                  (read-line path))))

                  (define temp_path (string-replace (path->string (first paths))
                                                    "tele"
                                                    "temp-tele"))

                  (define records_new (tandem (first paths)))]
            (begin (io_file_write temp_path
                                  records_new)
                   (iterator (rest paths))))]))

(iterator PATH_POLY)