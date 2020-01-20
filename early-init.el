;;; -*- lexical-binding: t; buffer-read-only: t -*-
(defvar the--gc-cons-threshold gc-cons-threshold)
(defvar the--gc-cons-percentage gc-cons-percentage)
(defvar the--file-name-handler-alist file-name-handler-alist)

(setq-default gc-cons-threshold 402653184
       gc-cons-percentage 0.6
       inhibit-compacting-font-caches t
       message-log-max 16384
       file-name-handler-alist nil)

(add-hook 'after-init-hook
   (lambda ()
     (setq gc-cons-threshold the--gc-cons-threshold
	   gc-cons-percentage the--gc-cons-percentage
	   file-name-handler-alist the--file-name-handler-alist)))

;; Use a hook so the message doesn't get clobbered by other messages.
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (message "Emacs ready in %s with %d garbage collections."
		     (format "%.2f seconds"
			     (float-time
			      (time-subtract after-init-time before-init-time)))
		     gcs-done)))

(setq inhibit-startup-screen t)

(if (fboundp 'tool-bar-mode)   (tool-bar-mode   -1))
(if (fboundp 'menu-bar-mode)   (menu-bar-mode   -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

(setq default-frame-alist '((font . "PragmataPro Liga-14")
		     (fullscreen . fullboth)
		     (horizontal-scroll-bars)
		     (vertical-scroll-bars)))

(when (featurep 'ns)
  (push '(ns-transparent-titlebar . t) default-frame-alist))

(setq frame-inhibit-implied-resize t)

(require 'bytecomp)
(byte-recompile-file (concat user-emacs-directory "pragmata.el") nil 0 t)

(setq package-enable-at-startup nil)

;;; Set up package management
;;;; use-package
(eval-when-compile
  (require 'use-package))

;; Tell `use-package' to always load features lazily unless told
;; otherwise. It's nicer to have this kind of thing be deterministic:
;; if `:demand' is present, the loading is eager; otherwise, the
;; loading is lazy. See
;; https://github.com/jwiegley/use-package#notes-about-lazy-loading.
(setq use-package-always-defer t)

;; We care about load time in our config, so have use-package report packages
;; that are dragging down our startup.
(setq use-package-verbose t)

(use-package no-littering :demand t)

;; We can't tangle without org!
(require 'org)

(defun the-reload-and-tangle-init-org ()
    "Tangle and reload THE config."
    (interactive)
    (when (string= buffer-file-name (file-truename (concat user-emacs-directory "init.org")))
      (org-babel-tangle)
      (byte-compile-file (concat user-emacs-directory "init.el"))
      (load (concat user-emacs-directory "init"))))   

(add-to-list 'safe-local-variable-values
      '(after-save-hook . the-reload-and-tangle-init-org))

;; Open the configuration
(find-file (concat user-emacs-directory "init.org"))
;; tangle it
(org-babel-tangle)
;; load it
(load-file (concat user-emacs-directory "init.el"))
;; finally byte-compile it
(byte-compile-file (concat user-emacs-directory "init.el"))

(provide 'early-init)
