#lang racket/base

(require "../../lib/humdrum.rkt"
         "../../lib/io.rkt"
         racket/local
         racket/string)

(define PATH_POLY
  (append (io_directory_read "krn/metodiche"  #:append? #t)
          (io_directory_read "krn/essercizii" #:append? #t)))

(define (get_instrumentation instrumentation path)
  (cond [(string=? instrumentation "Flauto")        TANDEM_INSTRUMENT_FLAUTO]
        [(string=? instrumentation "Flute")         TANDEM_INSTRUMENT_FLUTE]
        [(string=? instrumentation "Oboe")          TANDEM_INSTRUMENT_OBOE]
        [(string=? instrumentation "Viol")          TANDEM_INSTRUMENT_VIOL]
        [(string=? instrumentation "Violin")        TANDEM_INSTRUMENT_VIOLIN]
        [(string=? instrumentation "ViolinOrFlute") TANDEM_INSTRUMENT_VOF]
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
        [(regexp-match? #px"G" key) TANDEM_KEY_LABELE_G_MAJOR]
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
  (cond [(string=? tempo "Ada") "!!!OMD: Adagio"]
        [(string=? tempo "Aff") "!!!OMD: Affettuoso"]
        [(string=? tempo "All") "!!!OMD: Allegro"]
        [(string=? tempo "And") "!!!OMD: Andante"]
        [(string=? tempo "Can") "!!!OMD: Cantabile"]
        [(string=? tempo "Con") "!!!OMD: Con tenerezza"]
        [(string=? tempo "Cor") "!!!OMD: Cortesemente"]
        [(string=? tempo "Cun") "!!!OMD: Cunando"]
        [(string=? tempo "Dol") "!!!OMD: Dolce"]
        [(string=? tempo "Gra") "!!!OMD: Grave"]
        [(string=? tempo "Lar") "!!!OMD: Largo"]
        [(string=? tempo "Mes") "!!!OMD: Mesto"]
        [(string=? tempo "Ond") "!!!OMD: Ondeggiando"]
        [(string=? tempo "Pre") "!!!OMD: Presto"]
        [(string=? tempo "Rec") "!!!OMD: Recitativo"]
        [(string=? tempo "Sic") "!!!OMD: Siciliana"]
        [(string=? tempo "Soa") "!!!OMD: Soave"]
        [(string=? tempo "Spi") "!!!OMD: Spirituoso"]
        [(string=? tempo "Tem") "!!!OMD: Tempo giusto"]
        [(string=? tempo "Viv") "!!!OMD: Vivace"]
        [else
          (error "could not identify tempo" path)]))

(define (tandem path)
  (local [(define path_string (path->string))

          (define path_fields      (string-split path_string "-"))
          (define key              (list-ref path_fields 2))
          (define tempo            (list-ref path_fields 5))
          (define instrumentation  (list-ref path_fields 6))

          (define file             (io_file_read path #:trim? #f))
          (define time_signature   (first (rest file)))
          (define met              (get_met (first (string-split time_signature TAB))))

          (define key_signature    (get_key_signature key path))
          (define key_label        (get_key_label     key path))]
    (append (string-append "**kern"                   TAB "**fb"                     TAB "**kern")
            (string-append TANDEM_INSTRUMENT_CONTINUO TAB TANDEM_INSTRUMENT_CONTINUO TAB (get_instrumentation instrumentation path))
            (string-append TANDEM_CLEF_BASS           TAB TANDEM_NULL                TAB (get_clef instrumentation))
            (string-append key_signature              TAB TANDEM_NULL                TAB key_signature)
            (string-append key_label                  TAB TANDEM_NULL                TAB key_label)
            (string-append time_signature
                           (if (not (false? met))
                               (string-append NEWLINE met)
                               ""))
            (string-append REFERENCE_RECORD_MOVEMENT_DESIGNATION SPACE (get_tempo tempo path))
            (rest (rest file)))))

(define (iterator paths)
  (cond [(empty? paths) (void)]
        [else
          (local [(define filename (call-with-input-file (first paths)
                                                         (lambda (path) (read-line path))))

                  (define temp_path ())

                  (define new_records (tandem (first paths)))]
            ())]))