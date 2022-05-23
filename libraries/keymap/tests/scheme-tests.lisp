;;;; SPDX-FileCopyrightText: Atlas Engineer LLC
;;;; SPDX-License-Identifier: BSD-3-Clause

(in-package :keymap/tests)

(prove:plan nil)

(keymap-test "Make scheme"
  (let* ((scheme (keymap:define-scheme "test"
                   scheme:cua '("C-c" copy
                                "C-v" paste)))
         (keymap (keymap:make-keymap "test-cua-map")))
    (keymap:define-key keymap "C-c" 'copy)
    (keymap:define-key keymap "C-v" 'paste)
    (prove:is (fset:convert 'fset:map (keymap:keymap->map (gethash scheme:cua scheme)))
              (fset:convert 'fset:map (keymap:keymap->map keymap))
              :test #'fset:equal?)
    (prove:is (keymap:name (gethash scheme:cua scheme))
              (keymap:name keymap))))

(keymap-test "Make scheme with LIST"
  (let* ((scheme (keymap:define-scheme "test"
                     scheme:cua (list "C-c" 'copy
                                      "C-v" 'paste)))
         (keymap (keymap:make-keymap "test-cua-map")))
    (keymap:define-key keymap
      "C-c" 'copy
      "C-v" 'paste)
    (prove:is (fset:convert 'fset:map (keymap:keymap->map (gethash scheme:cua scheme)))
              (fset:convert 'fset:map (keymap:keymap->map keymap))
              :test #'fset:equal?)))

(keymap-test "Make scheme with multiple names"
  (let* ((scheme (keymap:define-scheme "test"
                     scheme:cua (list "C-c" 'copy
                                      "C-v" 'paste)
                   scheme:emacs (list "M-w" 'copy
                                      "M-y" 'paste)))
         (cua-keymap (keymap:make-keymap "test-cua-map"))
         (emacs-keymap (keymap:make-keymap "test-emacs-map")))
    (keymap:define-key cua-keymap
      "C-c" 'copy
      "C-v" 'paste)
    (keymap:define-key emacs-keymap
      "M-w" 'copy
      "M-y" 'paste)
    (prove:is (fset:convert 'fset:map (keymap:keymap->map (gethash scheme:cua scheme)))
              (fset:convert 'fset:map (keymap:keymap->map cua-keymap))
              :test #'fset:equal?)
    (prove:is (fset:convert 'fset:map (keymap:keymap->map (gethash scheme:emacs scheme)))
              (fset:convert 'fset:map (keymap:keymap->map emacs-keymap))
              :test #'fset:equal?)))

(keymap-test "Test inheritance"
  (let* ((scheme (keymap:define-scheme "test"
                     scheme:cua (list "C-c" 'copy
                                      "C-v" 'paste)
                   scheme:emacs (list "M-w" 'copy
                                      "M-y" 'paste)))
         (cua-keymap (keymap:make-keymap "test-cua-map"))
         (emacs-keymap (keymap:make-keymap "test-emacs-map")))
    (keymap:define-key cua-keymap
      "C-c" 'copy
      "C-v" 'paste)
    (keymap:define-key emacs-keymap
      "M-w" 'copy
      "M-y" 'paste)
    (prove:is (list (gethash scheme:cua scheme))
              (keymap:parents (gethash scheme:emacs scheme)))))

(keymap-test "Get keymap"
  (let* ((scheme (keymap:define-scheme "test"
                   scheme:cua (list "C-c" 'copy
                                    "C-v" 'paste)
                   scheme:emacs (list "M-w" 'copy
                                      "M-y" 'paste))))
    (prove:ok (keymap:get-keymap scheme:emacs scheme))
    (prove:ok (keymap:get-keymap scheme:cua scheme))
    (prove:isnt (keymap:get-keymap scheme:cua scheme)
                (keymap:get-keymap scheme:emacs scheme))
    (prove:is (keymap:get-keymap scheme:cua scheme)
              (keymap:get-keymap scheme:vi-normal scheme))))

;; (keymap-test "Make scheme with type errors" ; TODO: How do we test macro-expansion-time error?
;;   (prove:is-error (keymap:define-scheme
;;                       scheme:cua (list "C-" 'copy))
;;                   'type-error))

(prove:finalize)
