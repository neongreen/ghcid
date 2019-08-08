;;; ghcid.el --- ghcid + Stack support

;; Copyright (C) 2017 Matthew Wraith

;; Author: Matthew Wraith <wraithm@gmail.com>
;; Version: 0.1
;; Keywords: haskell
;; URL: https://github.com/ndmitchell/ghcid/blob/master/plugins/emacs/

;; Copyright Matthew Wraith 2017.
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are
;; met:
;;
;;     * Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;     * Redistributions in binary form must reproduce the above
;;       copyright notice, this list of conditions and the following
;;       disclaimer in the documentation and/or other materials provided
;;       with the distribution.
;;
;;     * Neither the name of Neil Mitchell nor the names of other
;;       contributors may be used to endorse or promote products derived
;;       from this software without specific prior written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;; OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;;; Commentary:

;; Really basic ghcid+stack support in emacs with compilation-mode.
;;
;; Use M-x ghcid to launch.

;;; Code:

;; Set ghcid-target to change the stack target
(setq ghcid-target "")

(setq ghcid-height 15)
(defun ghcid-stack-cmd (target)
      (format "stack ghci %s --test --bench --ghci-options=-fno-code" target))

(setq ghcid-buf-name "*ghcid*")

(define-minor-mode ghcid-mode
  "A minor mode for ghcid terminals"
  :lighter " Ghcid"
  (nlinum-mode -1)
  (linum-mode -1)
  (compilation-minor-mode))

(defun new-ghcid-term ()
  (interactive)
  (kill-ghcid)
  (let ((ghcid-buf (get-buffer-create ghcid-buf-name)))
    (display-buffer
     ghcid-buf
     '((display-buffer-at-bottom
        display-buffer-pop-up-window
        display-buffer-reuse-window)
       (window-height . 18)))
    (select-window (get-buffer-window ghcid-buf))
    (make-term "ghcid" "/bin/bash")
    (term-mode)
    (term-char-mode)
    (term-set-escape-char ?\C-x)
    (setq-local term-buffer-maximum-size ghcid-height)
    (setq-local scroll-up-aggressively 1)
    (ghcid-mode)))

(defun kill-ghcid ()
  (let* ((ghcid-buf (get-buffer ghcid-buf-name))
         (ghcid-proc (get-buffer-process ghcid-buf)))
    (when (processp ghcid-proc)
      (progn
        (set-process-query-on-exit-flag ghcid-proc nil)
        (kill-process ghcid-proc)))))

(defun add-stars (s) (format "*%s*" s))

;; TODO Pass in compilation command like compilation-mode
(defun ghcid-command (h)
    (format "ghcid -c \"%s\" -h %s\n" (ghcid-stack-cmd ghcid-target) h))

;; TODO Close stuff if it fails
(defun ghcid ()
  "Run ghcid"
  (interactive)
  (let ((cur (selected-window)))
    (new-ghcid-term)
    (comint-send-string ghcid-buf-name (ghcid-command ghcid-height))
    (select-window cur)))

;; Assumes that only one window is open
(defun ghcid-stop ()
  "Stop ghcid"
  (interactive)
  (let* ((ghcid-buf (get-buffer ghcid-buf-name))
         (ghcid-window (get-buffer-window ghcid-buf)))
    (when ghcid-buf
      (progn
        (kill-ghcid)
        (select-window ghcid-window)
        (kill-buffer-and-window)))))

(provide 'ghcid)
