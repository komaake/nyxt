;;;; SPDX-FileCopyrightText: Atlas Engineer LLC
;;;; SPDX-License-Identifier: BSD-3-Clause

#-asdf3.1 (error "Nyxt requires ASDF 3.1.2")
#+sbcl
(progn
  (sb-ext:assert-version->= 2 0 0)
  (require 'sb-bsd-sockets))

(uiop:define-package nyxt-asdf
  (:use :cl))
(in-package :nyxt-asdf)

;; (export-always 'nyxt-user-system)
;; (defclass nyxt-user-system (asdf:system) ()
;;   (:documentation "Specialized systems for Nyxt users."))
;; (import 'nyxt-user-system :asdf-user)

(defclass nyxt-renderer-system (asdf:system) ()
  (:documentation "Specialized systems for Nyxt with renderer dependency.
The renderer is configured from NYXT_RENDERER or `*nyxt-renderer*'."))

(export-always '*nyxt-renderer*)
(defvar *nyxt-renderer* (or (getenv "NYXT_RENDERER")
                            "gi-gtk"))

(defmethod asdf:component-depends-on ((o asdf:prepare-op) (c nyxt-renderer-system))
  `((asdf:load-op ,(format nil "nyxt/~a-application" *nyxt-renderer*))
    ,@(call-next-method)))

;; WARNING: We _must_ declare the translation host or else ASDF won't recognize
;; the pathnames as logical-pathnames, thus returning the system directory
;; instead.
(setf (logical-pathname-translations "NYXT") nil)

(defsystem "nyxt"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :version "3"                          ;  3-pre-release-2 / Development version
  :author "Atlas Engineer LLC"
  :homepage "https://nyxt.atlas.engineer"
  :description "Extensible web browser in Common Lisp"
  :license "BSD 3-Clause"
  :depends-on (alexandria
               bordeaux-threads
               calispel
               cl-base64
               cl-gopher
               cl-html-diff
               cl-json
               cl-ppcre
               cl-ppcre-unicode
               cl-prevalence
               cl-qrencode
               cl-tld
               closer-mop
               cl-containers
               dissect
               moptilities
               dexador
               enchant
               flexi-streams
               idna
               iolib
               iolib/os
               lass
               local-time
               lparallel
               log4cl
               montezuma
               ndebug
               nfiles
               njson/cl-json
               njson/aliases
               nhooks
               nkeymaps
               nsymbols/star
               #-sbcl
               osicat
               ospm
               parenscript
               py-configparser
               quri
               serapeum
               str
               phos
               plump
               clss
               spinneret
               slynk
               swank
               trivia
               trivial-clipboard
               trivial-features
               trivial-garbage
               trivial-package-local-nicknames
               trivial-types
               unix-opts
               ;; Local systems:
               nyxt/user-interface
               nyxt/text-buffer
               nyxt/analysis
               nyxt/download-manager
               nyxt/history-tree
               nyxt/password-manager
               nyxt/class-star
               nyxt/prompter
               nyxt/theme)
  :pathname #p"NYXT:source;"
  :components ((:file "utilities")
               (:file "types")
               (:file "package" :depends-on ("utilities" "types"))
               (:module "Utilities"
                :pathname ""
                :depends-on ("package")
                :components
                ((:file "time")
                 (:file "keyscheme")
                 (:file "conditions")
                 (:file "debug")
                 (:file "user-interface")))
               (:module "Core"
                :pathname ""
                :serial t
                :depends-on ("Utilities")
                :components
                ((:file "renderer")
                 (:file "global")
                 (:file "concurrency")
                 (:file "gpg")
                 (:file "user-files")
                 (:file "user-classes")
                 (:file "configuration")
                 (:file "parenscript-macro")
                 (:file "message")
                 (:file "command")
                 (:file "renderer-script")
                 (:file "urls")
                 (:file "inspector")
                 (:file "dom")
                 (:file "buffer")
                 (:file "window")
                 (:file "panel")
                 (:file "mode")
                 (:file "history")
                 (:file "auto-rules")
                 (:file "spinneret-tags")
                 (:file "search-engine")
                 (:file "browser")
                 (:file "foreign-interface")
                 (:file "clipboard")
                 (:file "input")
                 (:file "prompt-buffer")
                 (:file "command-commands")
                 (:file "debugger")
                 (:file "recent-buffers")
                 (:file "external-editor")))
               (:module "Core modes"
                :pathname "mode"
                :depends-on ("Core")
                :components
                ((:file "input-edit")
                 (:file "buffer-listing")
                 (:file "message")
                 (:file "passthrough")
                 (:file "history-tree")
                 (:file "list-history")
                 (:file "document" :depends-on ("passthrough"))
                 (:file "hint" :depends-on ("document"))
                 (:file "search-buffer" :depends-on ("hint"))
                 (:file "spell-check" :depends-on ("document"))
                 (:file "help" :depends-on ("document" "search-buffer"))
                 (:file "history" :depends-on ("history-tree" "list-history"))
                 (:file "certificate-exception" :depends-on ("history"))
                 (:file "keyscheme")
                 (:file "proxy")
                 (:file "process")
                 (:file "user-script")))
               (:file "describe" :depends-on ("Core modes"))
               (:module "Prompter modes"
                :pathname "mode"
                :depends-on ("describe" "Core modes")
                :components
                ((:file "prompt-buffer")
                 (:file "hint-prompt-buffer" :depends-on ("prompt-buffer"))
                 (:file "file-manager" :depends-on ("prompt-buffer"))
                 (:file "download" :depends-on ("file-manager"))))
               (:file "mode/base" :depends-on ("Core modes"))
               #+quicklisp
               (:file "lisp-system" :depends-on ("Core modes"))
               (:file "status" :depends-on ("Core"))
               (:module "Editor modes"
                :pathname "mode"
                :depends-on ("Core modes")
                :components
                ((:file "editor")
                 (:file "plaintext-editor")))
               (:module "Help"
                :pathname ""
                :depends-on ("Core modes" "Modes")
                :components
                ((:file "help")
                 (:file "about")
                 (:file "tutorial")
                 (:file "changelog")
                 (:file "migration")))
               (:file "configuration-commands" :depends-on ("Help"))
               (:file "start" :depends-on ("configuration-commands"))
               (:file "manual" :depends-on ("configuration-commands"))
               (:module "Modes"
                :pathname "mode"
                :depends-on ("Core modes")
                :components
                ((:file "annotate")
                 (:file "autofill")
                 (:file "blocker")
                 (:file "bookmark")
                 (:file "bookmark-frequent-visits" :depends-on ("bookmark"))
                 (:file "bookmarklets")
                 (:file "cruise-control" :depends-on ("repeat"))
                 (:file "emacs")
                 (:file "expedition")
                 (:file "force-https")
                 (:file "macro-edit")
                 (:file "no-image")
                 (:file "no-procrastinate" :depends-on ("blocker"))
                 (:file "no-script")
                 (:file "no-sound")
                 (:file "no-webgl")
                 (:file "os-package-manager")
                 (:file "password")
                 (:file "preview")
                 (:file "reading-line")
                 (:file "record-input-field")
                 (:file "reduce-bandwidth")
                 (:file "reduce-tracking")
                 (:file "repeat")
                 (:file "repl")
                 (:file "remembrance" :depends-on ("bookmark"))
                 (:file "small-web")
                 (:file "style" :depends-on ("bookmarklets"))
                 (:file "tts")
                 (:file "vi")
                 (:file "visual")
                 (:file "watch"))))
  :around-compile "NASDF:FAIL-ON-WARNINGS"
  :in-order-to ((test-op (test-op "nyxt/tests")
                         ;; We test if manual dumping works, since it may catch
                         ;; some subtle mistakes:
                         (compile-op "nyxt/documentation")
                         (test-op "nyxt/history-tree/tests")
                         (test-op "nyxt/class-star/tests")
                         (test-op "nyxt/prompter/tests"))))

(defsystem "nyxt/submodules"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-submodule-system)

(defsystem "nyxt/tests/compilation"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-compilation-test-system
  :depends-on (nyxt)
  :packages (:nyxt))

;; TODO: Test that Nyxt starts and that --help, --version work.
(defsystem "nyxt/tests"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-test-system
  :depends-on (nyxt nyxt/tests/compilation)
  :targets (:package :nyxt/tests)
  :serial t
  :components ((:file "tests/package")
               (:file "tests/offline/define-configuration")
               (:file "tests/offline/global-history")
               (:file "tests/offline/user-script-parsing")
               (:file "tests/offline/mode")
               (:file "tests/offline/mode/process")
               (:file "tests/online/urls")))

(defsystem "nyxt/benchmark"
  :defsystem-depends-on ("nasdf")
  :depends-on (alexandria
               nyxt
               trivial-benchmark)
  :pathname "tests/benchmarks"
  :components ((:file "../benchmark-package")
               (:file "prompter"))
  :perform (test-op (op c)
                    (let ((results
                            (funcall (read-from-string "alexandria:hash-table-alist")
                                     (funcall (read-from-string "benchmark:run-package-benchmarks")
                                              :package :nyxt/benchmark
                                              :verbose t))))
                      (symbol-call :nasdf :print-benchmark results))))

(defsystem "nyxt/clean-fasls"
  :depends-on (swank)
  :perform (compile-op (o c)
                       (load (merge-pathnames
                              "contrib/swank-asdf.lisp"
                              (symbol-value
                               (find-symbol* :*source-directory* :swank-loader))))
                       (symbol-call :swank :delete-system-fasls "nyxt")))

;; We use a temporary "version" file to generate the final nyxt.desktop with the
;; right version number.  Since "version" is a file target, third-party
;; packaging systems can choose to generate "version" in advance before calling
;; "make install-assets", so that they won't need to rely on submodules.
(defsystem "nyxt/version"
  :depends-on (nyxt)
  :output-files (compile-op (o c)
                            (values (list (system-relative-pathname c "version"))
                                    t))
  :perform (compile-op (o c)
                       (with-open-file (out (output-file o c)
                                            :direction :output
                                            :if-exists :supersede)
                         (princ (symbol-value (find-symbol* :+version+ :nyxt))
                                out))))

(defsystem "nyxt/documentation"         ; TODO: Only rebuild if input changed.
  :depends-on (nyxt)
  :output-files (compile-op (o c)
                            (values (list (system-relative-pathname c "manual.html"))
                                    t))
  :perform (compile-op (o c)
                       (with-open-file (out (output-file o c)
                                            :direction :output
                                            :if-exists :supersede)
                         (write-string (symbol-call :nyxt :manual-content)
                                       out))
                       (format *error-output* "Manual dumped to ~s.~&" (output-file o c))))

(defsystem "nyxt/gtk"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :depends-on (cl-cffi-gtk
               cl-webkit2
               nyxt)
  :pathname #p"NYXT:source;"
  :serial t
  :around-compile "NASDF:FAIL-ON-WARNINGS"
  :components ((:file "web-extensions")
               (:file "web-extensions-callbacks")
               (:file "renderer/gtk-clipboard")
               (:file "renderer/gtk")))

(defsystem "nyxt/gi-gtk"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :depends-on (bordeaux-threads
               cl-gobject-introspection
               nyxt/gtk)
  :pathname #p"NYXT:source;"
  :around-compile "NASDF:FAIL-ON-WARNINGS"
  :components ((:file "renderer/gi-gtk"))
  :in-order-to ((test-op (test-op "nyxt/gi-gtk/tests"))))

(defsystem "nyxt/gi-gtk/tests"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-test-system
  :depends-on (nyxt/gi-gtk)
  :targets (:package :nyxt/tests/renderer)
  :serial t
  :components ((:file "tests/renderer-package")
               (:file "tests/renderer-offline/set-url")
               (:file "tests/renderer-offline/execute-command-eval")
               (:file "tests/renderer-offline/remembrance")
               (:file "tests/renderer-online/set-url")))

(defsystem "nyxt/qt"
  :depends-on (cl-webengine
               nyxt
               trivial-main-thread)
  :pathname #p"NYXT:source;"
  :around-compile "NASDF:FAIL-ON-WARNINGS"
  :components ((:file "renderer/qt")))

;; We should not set the build-pathname in systems that have a component.
;; Indeed, when an external program (like Guix) builds components, it needs to
;; know the name of the output.  But ASDF/SYSTEM::COMPONENT-BUILD-PATHNAME is
;; non-exported so the only reliable way to know the build pathname is to use
;; the default.
;;
;; The workaround is to set a new dummy system of which the sole purpose is to
;; produce the desired binary.

(defsystem "nyxt/gtk-application"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :depends-on (nyxt/gtk)
  :build-operation "program-op"
  :build-pathname "nyxt"
  :entry-point "nyxt:entry-point")

(defsystem "nyxt/gi-gtk-application"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :depends-on (nyxt/gi-gtk)
  :build-operation "program-op"
  :build-pathname "nyxt"
  :entry-point "nyxt:entry-point")

(defsystem "nyxt/qt-application"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :depends-on (nyxt/qt)
  :build-operation "program-op"
  :build-pathname "nyxt-qt"
  :entry-point "nyxt:entry-point")

(defsystem "nyxt/application/tests"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-test-system
  :depends-on (nyxt)
  :targets (:package :nyxt/tests/executable)
  :components ((:file "tests/package")
               (:file "tests/executable/config")
               (:file "tests/executable/scripts"))
  :perform (test-op :around (op c)
                    (if (file-exists-p (system-relative-pathname :nyxt "nyxt"))
                        (call-next-method)
                        (warn "`nyxt' executable missing, skipping tests."))))

(defsystem "nyxt/install"
  :defsystem-depends-on ("nasdf")
  :class :nyxt-renderer-system
  :depends-on (alexandria
               nyxt/version
               str)
  :components ((:nasdf-desktop-file "assets/nyxt.desktop")
               (:nasdf-icon-directory "assets/")
               (:nasdf-binary-file "nyxt")
               (:nasdf-library-file "libraries/web-extensions/libnyxt.so"
                                   :if-does-not-exist nil)
               (:nasdf-source-directory "source")
               (:nasdf-source-directory "nasdf")
               (:nasdf-source-directory "libraries"
                :exclude-subpath ("web-extensions") ; Do not install this non-Lisp source.
                :exclude-types ("o" "c" "h" ; C code and artifacts.
                                    "fasl"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Library subsystems:

(defsystem "nyxt/download-manager"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :depends-on (calispel
               cl-ppcre
               dexador
               log4cl
               quri
               str)
  :pathname #p"NYXT:libraries;download-manager;"
  :components ((:file "package")
               (:file "engine")
               (:file "native")))

(defsystem "nyxt/analysis"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :depends-on (alexandria
               cl-ppcre
               serapeum
               str)
  :pathname #p"NYXT:libraries;analysis;"
  :components ((:file "package")
               (:file "composite-sequence")
               (:file "data")
               (:file "stem")
               (:file "tokenize")
               (:file "analysis")
               (:file "document-vector")
               (:file "text-rank")
               (:file "dbscan")
               (:file "section"))
  :in-order-to ((test-op (test-op "nyxt/analysis/tests"))))

(defsystem "nyxt/analysis/tests"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-test-system
  :depends-on (nyxt/analysis)
  :targets (:package :analysis/tests)
  :components ((:file "libraries/analysis/tests/tests")))

(defsystem "nyxt/user-interface"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :depends-on (spinneret)
  :pathname #p"NYXT:libraries;user-interface;"
  :components ((:file "package")
               (:file "user-interface")))

(defsystem "nyxt/text-buffer"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :depends-on (cluffer)
  :pathname #p"NYXT:libraries;text-buffer;"
  :components ((:file "package")
               (:file "text-buffer")))

(defsystem "nyxt/history-tree"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :depends-on (alexandria
               cl-custom-hash-table
               local-time
               nyxt/class-star
               trivial-package-local-nicknames)
  :pathname #p"NYXT:libraries;history-tree;"
  :components ((:file "package")
               (:file "history-tree"))
  :in-order-to ((test-op (test-op "nyxt/history-tree/tests"))))

(defsystem "nyxt/history-tree/tests"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-test-system
  :depends-on (nyxt/history-tree
               str)
  :targets (:package :history-tree/tests)
  :components ((:file "libraries/history-tree/tests/tests")))

(defsystem "nyxt/password-manager"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :depends-on (bordeaux-threads
               cl-ppcre
               nyxt/class-star
               serapeum
               str
               trivial-clipboard
               uiop)
  :pathname #p"NYXT:libraries;password-manager;"
  :components ((:file "package")
               (:file "password")
               (:file "password-keepassxc")
               (:file "password-security")
               ;; Keep password-store last so that it has higher priority.
               (:file "password-pass")))

(defsystem "nyxt/class-star"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :depends-on (alexandria
               hu.dwim.defclass-star
               moptilities)
  :pathname #p"NYXT:libraries;class-star;"
  :components ((:file "package")
               (:file "patch")
               (:file "class-star"))
  :in-order-to ((test-op (test-op "nyxt/class-star/tests"))))

(defsystem "nyxt/class-star/tests"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-test-system
  :depends-on (nyxt/class-star)
  :targets (:package :class-star/tests)
  :components ((:file "libraries/class-star/tests/tests")
               (:file "libraries/class-star/tests/global-settings")))

(defsystem "nyxt/prompter"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :depends-on (alexandria
               calispel
               cl-containers
               closer-mop
               lparallel
               moptilities
               nyxt/class-star
               serapeum
               str
               trivial-package-local-nicknames)
  :pathname #p"NYXT:libraries;prompter;"
  :components ((:file "package")
               (:file "filter-preprocessor")
               (:file "filter")
               (:file "prompter-source")
               (:file "prompter"))
  :in-order-to ((test-op (test-op "nyxt/prompter/tests"))))

(defsystem "nyxt/prompter/tests"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-test-system
  :depends-on (nyxt/prompter)
  :targets (:package :prompter/tests)
  :pathname #p"NYXT:libraries;prompter;tests;"
  :components ((:file "package")
               (:file "tests")
               (:file "fuzzy")
               (:file "submatches")))

(defsystem "nyxt/theme"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-system
  :depends-on (alexandria
               lass
               nyxt/class-star
               serapeum)
  :pathname #p"NYXT:libraries;theme;"
  :components ((:file "package")
               (:file "theme"))
  :in-order-to ((test-op (test-op "nyxt/theme/tests"))))

(defsystem "nyxt/theme/tests"
  :defsystem-depends-on ("nasdf")
  :class :nasdf-test-system
  :depends-on (nyxt/theme)
  :targets (:package :theme/tests)
  :components ((:file "libraries/theme/tests/tests")))
