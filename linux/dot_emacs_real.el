;; -*- Mode: Emacs-Lisp -*-


;; Note -- if using KDE, turn off "Apply colors to non-KDE applications" in
;; the control panel, under "Look & Feel/Colors".  Otherwise, colors
;; get messed up on startup, and applying colors is slow over multiple
;; frames


;; Howto keep the compilation window from automatically going away:
;; (setq compilation-finish-function nil)


;; Howto disable commands:
;;(put 'overwrite-mode 'disabled t)


;; DEBUGGING: write keystrokes to ~/.dribble
;;(open-dribble-file "~/.dribble")


;; DEBUGGING: write terminal output to ~/.termscript
;;(open-termscript "~/.termscript")



;;
;; **********************************************************************
;; **                                                                  **
;; ** additional directories to look for .el / .elc files              **
;; **                                                                  **
;; **********************************************************************
;;

(when (file-directory-p "/usr/share/emacs/site-lisp") (add-to-list 'load-path "/usr/share/emacs/site-lisp"))
(when (file-directory-p "/usr/local/share/emacs/site-lisp") (add-to-list 'load-path "/usr/local/share/emacs/site-lisp"))
(when (file-directory-p "/usr/local/share/elisp") (add-to-list 'load-path "/usr/local/share/elisp"))
(when (file-directory-p "~/.elisp") (add-to-list 'load-path "~/.elisp"))
(when (file-directory-p "~/.elisp/apel") (add-to-list 'load-path "~/.elisp/apel"))
(when (file-directory-p "~/.elisp/dictionary") (add-to-list 'load-path "~/.elisp/dictionary"))
(when (file-directory-p "~/.elisp/gnuplot") (add-to-list 'load-path "~/.elisp/gnuplot"))
(when (file-directory-p "~/.elisp/themes") (add-to-list 'load-path "~/.elisp/themes"))
(when (file-directory-p "~/.elisp/yasnippet") (add-to-list 'load-path "~/.elisp/yasnippet"))



;;
;; **********************************************************************
;; **                                                                  **
;; ** Persistent visual bookmarks -- keep near the top                 **
;; **                                                                  **
;; **********************************************************************
;;

;; Use this block for non-persistent bookmarks across emacs sessions
;;;(defvar have-bm 'nil)
;;;(if (locate-library "bm")
;;;    (progn
;;;      (setq have-bm t)
;;;      (byte-compile-if-newer "~/.elisp/bm")
;;;      (autoload 'bm-toggle   "bm" "Toggle bookmark in current buffer." t)
;;;      (autoload 'bm-next     "bm" "Goto bookmark."                     t)
;;;      (autoload 'bm-previous "bm" "Goto previous bookmark."            t)
;;;      )
;;;  (message "package bm not available")
;;;  )

;; Use this block for persistent bookmarks across emacs sessions
(defvar have-bm 'nil)
(if (locate-library "bm")
    (progn
      (setq have-bm t)
      (byte-compile-if-newer "~/.elisp/bm")

      ;; make bookmarks persistent as default
      (setq-default bm-buffer-persistence t)

      (setq bm-restore-repository-on-load t)
      (require 'bm)

      ;; Restoring bookmarks when on file find.
      (add-hook 'find-file-hooks 'bm-buffer-restore)

      ;; Saving bookmark data on killing a buffer
      (add-hook 'kill-buffer-hook 'bm-buffer-save)

      ;; Saving the repository to file when on exit.  kill-buffer-hook is not
      ;; called when Emacs is killed, so we must save all bookmarks first.
      (add-hook 'kill-emacs-hook '(lambda nil
                                    (bm-buffer-save-all)
                                    (bm-repository-save)))

      ;; Update bookmark repository when saving the file.
      (add-hook 'after-save-hook 'bm-buffer-save)

      ;; Restore bookmarks when buffer is reverted.
      (add-hook 'after-revert-hook 'bm-buffer-restore)

      (setq bm-highlight-style 'bm-highlight-line-and-fringe)
      )
  (message "package bm not available")
  )



;;
;; **********************************************************************
;; **                                                                  **
;; ** Variables                                                        **
;; **                                                                  **
;; **********************************************************************
;;

;; Get hostname
(defvar hostname (getenv "HOSTNAME"))

;; Get username
(defvar user (getenv "USER"))

(defvar custom-cmd "ExecuteCommand &" )



;;
;; **********************************************************************
;; **                                                                  **
;; ** Load packages                                                    **
;; **                                                                  **
;; **********************************************************************
;;

(defvar have-ack 'nil)
(if (locate-library "ack")
    (progn
      (setq have-ack t)
      (byte-compile-if-newer "~/.elisp/ack")
      (autoload 'ack "ack" "Run ack" t)
      )
  (message "package ack not available")
  )

;;; acme-search.el --- right-click searching
(defvar have-acme-search 'nil)
(if (locate-library "acme-search")
    (progn
      (setq have-acme-search t)
      (byte-compile-if-newer "~/.elisp/acme-search")
      (require 'acme-search)
      )
  (message "package acme-search not available")
  )

;; all.el --- Edit all lines matching a given regexp
(defvar have-all 'nil)
(if (locate-library "all")
    (progn
      (setq have-all t)
      (byte-compile-if-newer "~/.elisp/all")
      (autoload 'all "all" "Show all lines in the current buffer containing a match for REGEXP" t nil)
      )
  (message "package all not available")
  )

;;; ascii --- ASCII code display.
(defvar have-ascii 'nil)
(if (locate-library "ascii")
    (progn
      (setq have-ascii t)
      (byte-compile-if-newer "~/.elisp/ascii")
      (autoload 'ascii-on        "ascii" "Turn on ASCII code display."   t)
      (autoload 'ascii-off       "ascii" "Turn off ASCII code display."  t)
      (autoload 'ascii-display   "ascii" "Toggle ASCII code display."    t)
      (autoload 'ascii-customize "ascii" "Customize ASCII code display." t)
      )
  (message "package ascii not available")
  )

;; auto-fill-mode-inhibit -- finer grained control over auto-fill-mode (de)activation
(defvar have-auto-fill-inhibit 'nil)
;; Note (21March2011): this is causinig compile log errors on startup.  Maybe
;; not critical errors?  Nonetheless, presently not used
;; (if (locate-library "auto-fill-inhibit")
;;     (progn
;;       (setq have-auto-fill-inhibit t)
;;       (byte-compile-if-newer "~/.elisp/auto-fill-inhibit")
;;       (require 'auto-fill-inhibit)
;;       )
;;   (message "package auto-fill-inhibit not available")
;;   )

;; autorevert.el -- revert buffers when files on disk change
(defvar have-autorevert 'nil)
(if (locate-library "autorevert")
    (progn
      (setq have-autorevert t)
      (autoload 'auto-revert-mode "autorevert" nil t)
      (autoload 'turn-on-auto-revert-mode "autorevert" nil nil)
      (autoload 'global-auto-revert-mode "autorevert" nil t)
      (global-auto-revert-mode 1)
      )
  (message "package autorevert not available")
  )

;;; boxquote.el --- Quote text with a semi-box.
(defvar have-boxquote 'nil)
(if (locate-library "boxquote")
    (progn
      (setq have-boxquote t)
      (byte-compile-if-newer "~/.elisp/boxquote")
      (require 'boxquote)
      )
  (message "package boxquote not available")
  )

;;; browse-kill-ring.el --- interactively insert items from kill-ring
(defvar have-browse-kill-ring 'nil)
(if (locate-library "browse-kill-ring")
    (progn
      (setq have-browse-kill-ring t)
      (byte-compile-if-newer "~/.elisp/browse-kill-ring")
      (require `browse-kill-ring)
      )
  (message "package browse-kill-ring not available")
  )

;;; cdargs.el --- Directory Bookmarks
(defvar have-cdargs 'nil)
(if (locate-library "cdargs")
    (progn
      (setq have-cdargs t)
      (byte-compile-if-newer "~/.elisp/cdargs")
      (require 'cdargs)
      )
  (message "package cdargs not available")
  )

;;; color-file-completion.el --- add colors to file completion
(defvar have-color-file-completion 'nil)
(if (locate-library "color-file-completion")
    (progn
      (setq have-color-file-completion t)
      (byte-compile-if-newer "~/.elisp/color-file-completion")
      (require 'color-file-completion)
      )
  (message "package color-file-completion not available")
  )

;;; color-theme.el --- install color themes
(defvar have-color-theme 'nil)
(if (locate-library "color-theme")
    (progn
      (setq have-color-theme t)
      (byte-compile-if-newer "~/.elisp/color-theme")
      (byte-compile-if-newer "~/.elisp/themes/color-theme-library")
      (require 'color-theme)
      (color-theme-initialize)
      (setq color-theme-is-global nil)
      )
  (message "package color-theme not available")
  )

(if (equal have-color-theme t)
    (progn
      (defvar have-custom-color-theme 'nil)
      (if (locate-library "custom-color-theme")
          (progn
            (setq have-custom-color-theme t)
            (byte-compile-if-newer "~/.elisp/custom-color-theme")
            (require 'custom-color-theme)
            )
        (message "package custom-color-theme not available")
        )
      )
  )

;;; color-theme-x.el --- convert color themes to X11 resource settings
(defvar have-color-theme-x 'nil)
(if (locate-library "color-theme-x")
    (progn
      (setq have-color-theme-x t)
      (byte-compile-if-newer "~/.elisp/color-theme-x")
      (require 'color-theme-x)
      )
  (message "package package color-theme-x not available")
  )

;;; cpp.el --- highlight or hide text according to cpp conditionals
(defvar have-cpp 'nil)
(if (locate-library "cpp")
    (progn
      (setq have-cpp t)
      (autoload 'cpp-highlight-buffer "cpp" "Highlight C code according to preprocessor conditionals." t nil)
      (autoload 'cpp-parse-edit       "cpp" "Edit display information for cpp conditionals." t nil)
      )
  (message "package cpp not available")
  )

;;; csv-mode.el --- major mode for editing comma-separated value files
(defvar have-csv-mode 'nil)
(if (locate-library "csv-mode")
    (progn
      (setq have-csv-mode t)
      (byte-compile-if-newer "~/.elisp/csv-mode")
      (add-to-list 'auto-mode-alist '("\\.[Cc][Ss][Vv]\\'" . csv-mode))
      (autoload 'csv-mode "csv-mode" "Major mode for editing comma-separated value files." t)
      )
  (message "package csv-mode not available")
  )

;;; cyclebuffer.el --- select buffer by cycling through
(defvar have-cyclebuffer 'nil)
(if (locate-library "cyclebuffer")
    (progn
      (setq have-cyclebuffer t)
      (byte-compile-if-newer "~/.elisp/cyclebuffer")
      (autoload 'cyclebuffer-forward "cyclebuffer" "cycle forward" t)
      (autoload 'cyclebuffer-backward "cyclebuffer" "cycle backward" t)
      )
  (message "package cyclebuffer not available")
  )

;;; dedicated.el --- A very simple minor mode for dedicated buffers
(defvar have-dedicated 'nil)
(if (locate-library "dedicated")
    (progn
      (setq have-dedicated t)
      (byte-compile-if-newer "~/.elisp/dedicated")
      (autoload 'dedicated-mode "Toggle dedicated minor mode" t nil)
      )
  (message "package dedicated not available")
  )

;; dictionary.el -- an interface to RFC 2229 dictionary server
(defvar have-dictionary 'nil)
(if (locate-library "dictionary")
    (progn
      (setq have-dictionary t)
      (byte-compile-if-newer "~/.elisp/dictionary/connection")
      (byte-compile-if-newer "~/.elisp/dictionary/dictionary")
      (byte-compile-if-newer "~/.elisp/dictionary/dictionary-init")
      (byte-compile-if-newer "~/.elisp/dictionary/install-package")
      (byte-compile-if-newer "~/.elisp/dictionary/link")
      (byte-compile-if-newer "~/.elisp/dictionary/lpath")
      (autoload 'dictionary-search "dictionary"  "Ask for a word and search it in all dictionaries" t)
      (autoload 'dictionary-match-words "dictionary" "Ask for a word and search all matching words in the dictionaries" t)
      (autoload 'dictionary-lookup-definition "dictionary" "Unconditionally lookup the word at point." t)
      (autoload 'dictionary "dictionary" "Create a new dictionary buffer" t)
      (autoload 'dictionary-mouse-popup-matching-words "dictionary" "Display entries matching the word at the cursor" t)
      (autoload 'dictionary-popup-matching-words "dictionary" "Display entries matching the word at the point" t)
      (autoload 'dictionary-tooltip-mode "dictionary" "Display tooltips for the current word" t)
      (autoload 'global-dictionary-tooltip-mode "dictionary" "Enable/disable dictionary-tooltip-mode for all buffers" t)
      )
  (message "pacakge dictionary not available")
  )

;;; diminish.el --- Diminished modes are minor modes with no modeline display
(defvar have-diminish 'nil)
(if (locate-library "diminish")
    (progn
      (setq have-diminish t)
      (byte-compile-if-newer "~/.elisp/diminish")
      (autoload 'diminish "diminish")
      )
  (message "package diminish not available")
  )

;;; doc-mode.el --- a major-mode for highlighting a hierarchy structured text.
(defvar have-doc-mode 'nil)
(if (locate-library "doc-mode")
    (progn
      (setq have-doc-mode t)
      (byte-compile-if-newer "~/.elisp/doc-mode")
      (autoload 'doc-mode "doc-mode")
      (add-to-list 'auto-mode-alist '("\\.adoc$" . doc-mode))
      )
  (message "package doc-mode not available")
  )

;;; edit-env.el --- display and edit environment variables
(defvar have-edit-env 'nil)
(if (locate-library "edit-env")
    (progn
      (setq have-edit-env t)
      (byte-compile-if-newer "~/.elisp/edit-env")
      (require 'edit-env)
      )
  (message "package edit-env not available")
  )

;; elscreen.el -- screen for emacs
(defvar have-elscreen 'nil)
(if window-system
    (if (locate-library "elscreen")
        (progn
          (setq have-elscreen t)
          (byte-compile-if-newer "~/.elisp/apel/alist")
          (byte-compile-if-newer "~/.elisp/apel/apel-ver")
          (byte-compile-if-newer "~/.elisp/apel/product")
          (byte-compile-if-newer "~/.elisp/apel/pym")
          (byte-compile-if-newer "~/.elisp/apel/static")
          (byte-compile-if-newer "~/.elisp/elscreen")
          (setq elscreen-prefix-key "\C-\\")
          (setq elscreen-tab-display-kill-screen nil)
          (load "elscreen" "ElScreen" t)
          )
      (message "package elscreen not available")
      )
  )

;; filladapt.el -- Adaptive fill
(defvar have-filladapt 'nil)
(if (locate-library "filladapt")
    (progn
      (setq have-filladapt t)
      (byte-compile-if-newer "~/.elisp/filladapt")
      (require 'filladapt)
      (add-hook 'text-mode-hook 'turn-on-filladapt-mode)
      )
  (message "package filladapt not available")
  )

;; fold-dwim.el -- Unified user interface for Emacs folding modes
(defvar have-fold-dwim 'nil)
(if (locate-library "fold-dwim")
    (progn
      (setq have-fold-dwim t)
      (byte-compile-if-newer "~/.elisp/fold-dwim")
      (require 'fold-dwim)
      )
  (message "package fold-dwim not available")
  )

;;; generic-x.el --- A collection of generic modes
(defvar have-generic-x 'nil)
(if (locate-library "generic-x")
    (progn
      (setq have-generic-x t)
      (require 'generic-x)
      )
  (message "package generic-x not available")
  )

(condition-case () (global-hi-lock-mode 1) (error (message "global-hi-lock-mode is not available")))

;; gnuplot-mode
(defvar have-gnuplot 'nil)
(if (locate-library "gnuplot")
    (progn
      (setq have-gnuplot t)
      (autoload 'gnuplot-mode "gnuplot" "gnuplot major mode" t)
      (autoload 'gnuplot-make-buffer "gnuplot" "open a buffer in gnuplot mode" t)
      (setq special-display-buffer-names (cons "*gnuplot*" special-display-buffer-names))
      (setq auto-mode-alist (append '(("\\.gp$" . gnuplot-mode)) auto-mode-alist))
      )
  (message "package gnuplot not available")
  )

;;; goto-last-change.el --- Move point through buffer-undo-list positions
(defvar have-goto-last-change 'nil)
(if (locate-library "goto-last-change")
    (progn
      (setq have-goto-last-change t)
      (byte-compile-if-newer "~/.elisp/goto-last-change")
      (autoload 'goto-last-change "goto-last-change" "Set point to the position of the last change." t)
      )
  (message "package goto-last-change not available")
  )

;;; graphviz-dot-mode.el --- Mode for the dot-language used by graphviz (att).
(defvar have-graphviz-dot-mode 'nil)
(if (locate-library "graphviz-dot-mode")
    (progn
      (setq have-graphviz-dot-mode t)
      (byte-compile-if-newer "~/.elisp/graphviz-dot-mode")
      (load (locate-library "graphviz-dot-mode"))
      )
  (message "package graphviz-dot-mode not available")
  )

;;; hl-line.el --- highlight the current line
(defvar have-hl-line 'nil)
(if (locate-library "hl-line")
    (progn
      (setq have-hl-line t)
      (global-hl-line-mode 1)
      ;;(set-face-attribute hl-line-face nil :underline t)
      (if (equal user "root")
          (set-face-background hl-line-face "dark red")
        (set-face-background hl-line-face "dark blue")
        )
      )
  (message "package hl-line not available")
  )

;;; highlight-parentheses.el --- highlight surrounding parentheses
(defvar have-highlight-parentheses 'nil)
(if (locate-library "highlight-parentheses")
    (progn
      (setq have-highlight-parentheses t)
      (byte-compile-if-newer "~/.elisp/highlight-parentheses")
      (require 'highlight-parentheses)
      (add-hook 'c-mode-common-hook (function (lambda () (highlight-parentheses-mode))))
      )
  (message "package highlight-parentheses not available")
  )

;;; home-end.el --- Alternative Home and End commands.
(defvar have-home-end 'nil)
(if (locate-library "home-end")
    (progn
      (setq have-home-end t)
      (byte-compile-if-newer "~/.elisp/home-end")
      (autoload 'home-end-end  "home-end" "Go to end of line/window/buffer" t nil)
      (autoload 'home-end-home "home-end" "Go to beginning of line/window/buffer" t nil)
      )
  (message "package home-end not available")
  )

;; htmlize.el -- Convert buffer text and decorations to HTML.
(defvar have-htmlize 'nil)
(if (locate-library "htmlize")
    (progn
      (setq have-htmlize t)
      (byte-compile-if-newer "~/.elisp/htmlize")
      (autoload 'htmlize-buffer "htmlize" "Convert BUFFER to HTML, preserving colors and decorations" t nil)
      (autoload 'htmlize-region "htmlize" "Convert the region to HTML, preserving colors and decorations" t nil)
      (autoload 'htmlize-file   "htmlize" "Load FILE, fontify it, convert it to HTML, and save the result" t nil)
      (autoload 'htmlize-many-files "htmlize" "Convert FILES to HTML and save the corresponding HTML versions" t nil)
      (autoload 'htmlize-many-files-dired "htmlize" "HTMLize dired-marked files" t nil)
      )
  (message "package htmlize not available")
  )

;; UNUSED
;;;; imenu.el --- framework for mode-specific buffer indexes
;; (if (locate-library "imenu")
;;     (progn
;;       (require 'imenu)
;;       ;; add imenu to menu bar
;;       (add-hook 'c-mode-hook (function (lambda () (imenu-add-menubar-index))))
;;       (add-hook 'c++-mode-hook (function (lambda () (imenu-add-menubar-index))))
;;       (add-hook 'perl-mode-hook (function (lambda () (imenu-add-menubar-index))))
;;       (add-hook 'java-mode-hook (function (lambda () (imenu-add-menubar-index))))
;;       (add-hook 'c-mode-hook (function (lambda () (imenu-add-to-menubar 'Func))))
;;       (add-hook 'c++-mode-hook (function (lambda () (imenu-add-to-menubar 'Func))))
;;       (add-hook 'perl-mode-hook (function (lambda () (imenu-add-to-menubar 'Func))))
;;       (add-hook 'java-mode-hook (function (lambda () (imenu-add-to-menubar 'Func))))
;;       )
;;   (message "package imenu not available")
;;   )

;; iswitchb.el --- switch between buffers using substrings
(defvar have-iswitchb 'nil)
(if (locate-library "iswitchb")
    (progn
      (setq have-iswitchb t)
      (require 'iswitchb)

      ;; ignore case
      (setq iswitchb-case 1)

      ;; always show new buffer in the same window
      (setq iswitchb-default-method 'samewindow)

      ;; turn on iswitchb mode
      (iswitchb-mode 1)
      )
  (message "package iswitchb not available")
  )

;;; jka-compr.el --- reading/writing/loading compressed files
(defvar have-jka-compr 'nil)
(if (locate-library "jka-compr")
    (progn
      (setq have-jka-compr t)
      (require 'jka-compr)
      (auto-compression-mode 1)
      )
  (message "package jka-compr not available")
  )

;; light-symbol.el --- Minor mode to highlight symbol under point
(defvar have-light-symbol 'nil)
(if (locate-library "light-symbol")
    (progn
      (setq have-light-symbol t)
      (byte-compile-if-newer "~/.elisp/light-symbol")
      (autoload 'light-symbol-mode "light-symbol" "Toggle Light Symbol mode" t nil)
      (add-hook 'c-mode-common-hook (function (lambda () (light-symbol-mode))))
      )
  (message "package light-symbol not available")
  )

;; linum --- fast line numbering
(defvar have-linum 'nil)
(if (locate-library "linum")
    (progn
      (setq have-linum t)
      (autoload 'linum-mode "linum" "Toggle display of line numbers in the left margin" t)
      (autoload 'global-linum-mode "linum" "Toggle display of line numbers in the left margin" t)
      )
  (message "package linum not available")
  )

;;; markerpen.el --- allows you to colour and highlight arbitrary sections of buffers.
(defvar have-markerpen 'nil)
(if (locate-library "markerpen")
    (progn
      (setq have-markerpen t)
      (byte-compile-if-newer "~/.elisp/markerpen")
      (require 'markerpen)
      )
  (message "package markerpen not available")
  )

;;; matlab.el --- major mode for MATLAB dot-m files
(defvar have-matlab 'nil)
(if (locate-library "matlab")
    (progn
      (setq have-matlab t)
      (byte-compile-if-newer "~/.elisp/matlab")
      (autoload 'matlab-mode "matlab" "Enter Matlab mode" t)
      (autoload 'matlab-shell "matlab" "Interactive Matlab mode." t)
      (setq matlab-indent-function t)
      (setq auto-mode-alist (cons '("\\.m\\'" . matlab-mode) auto-mode-alist))
      )
  (message "package matlab not available")
  )

;; mouse-copy.el --- one-click text copy and move
(defvar have-mouse-copy 'nil)
(if (locate-library "mouse-copy")
    (progn
      (setq have-mouse-copy t)
      (require 'mouse-copy)
      )
  (message "package mouse-copy not available")
  )

;; mouse-drag.el --- use mouse-2 to do a new style of scrolling
(defvar have-mouse-drag 'nil)
(if (locate-library "mouse-drag")
    (progn
      (setq have-mouse-drag t)
      (require 'mouse-drag)
      )
  (message "package mouse-drag not available")
  )

;; move-text.el --- move text
(defvar have-move-text 'nil)
(if (locate-library "move-text")
    (progn
      (setq have-move-text t)
      (byte-compile-if-newer "~/.elisp/move-text")
      (require 'move-text)
      )
  (message "package move-text not available")
  )

(defvar have-nav 'nil)
(if (locate-library "nav")
    (progn
      (setq have-nav t)
      (byte-compile-if-newer "~/.elisp/nav")
      (autoload 'nav   "nav" "Opens Nav in a new window to the left of the current one." t)
      )
  (message "package nav not available")
  )

;;; nxml-mode.el --- a new XML mode
(defvar have-nxml-mode 'nil)
(if (locate-library "nxml-mode")
    (progn
      (setq have-nxml-mode t)
      (autoload 'nxml-mode "nxml-mode" "Major mode for editing XML" t)
      (setq auto-mode-alist (cons '("\\.\\(xml\\|xsl\\|rng\\|xhtml\\|glade\\)\\'" . nxml-mode) auto-mode-alist))
      )
  (message "package nxml-mode available")
  )

;;; pager.el --- windows-scroll commands
(defvar have-pager 'nil)
(if (locate-library "pager")
    (progn
      (setq have-pager t)
      (byte-compile-if-newer "~/.elisp/pager")
      (require 'pager)
      )
  (message "package pager not available")
  )

;;; paren.el --- highlight matching paren
(defvar have-paren 'nil)
(if (locate-library "paren")
    (progn
      (setq have-paren t)
      (require 'paren)

      ;; Always use parenthesis matching
      (show-paren-mode t)

      ;; no delay matching parens
      (setq show-paren-delay 0)

      (setq show-paren-style 'expression)
      )
  (message "package paren not available")
  )

;;; protbuf.el --- protect buffers from accidental killing
(defvar have-protbuf 'nil)
(if (locate-library "protbuf")
    (progn
      (setq have-protbuf t)
      (byte-compile-if-newer "~/.elisp/protbuf")
      (autoload 'protect-buffer-from-kill-mode "protbuf" "Protect buffer from being killed" t nil)
      )
  (message "package protbuf not available")
  )

;;; recentf.el --- setup a menu of recently opened files
(defvar have-recentf 'nil)
(if (locate-library "recentf")
    (progn
      (setq have-recentf t)
      (require 'recentf)
      ;;(setq recentf-auto-cleanup 'never) ;;To protect tramp
      (recentf-mode 1)
      (add-to-list 'recentf-exclude "/sudo:root@")
      (if (locate-library "tramp")
          (add-to-list 'recentf-exclude tramp-file-name-regexp)
        )
      (setq recentf-max-saved-items 100)
      )
  (message "package recentf not available")
  )

;;; recentf-buffer.el - creates the buffer with the list of recently open files.
(defvar have-recentf-buffer 'nil)
(if (locate-library "recentf-buffer")
    (progn
      (setq have-recentf-buffer t)
      (byte-compile-if-newer "~/.elisp/recentf-buffer")
      (load "recentf-buffer")
      )
  (message "package recentf-buffer not available")
  )

;; save minibuffer history
(condition-case () (savehist-mode 1) (error (message "savehist-mode is not available")))

;;; saveplace.el --- automatically save place in files
(defvar have-saveplace 'nil)
(if (locate-library "saveplace")
    (progn
      (setq have-saveplace t)
      (require `saveplace)
      (setq-default save-place t)
      )
  (message "package saveplace not available")
  )

;;; shell-command.el --- enables tab-completion for `shell-command'
(defvar have-shell-command 'nil)
(if (locate-library "shell-command")
    (progn
      (setq have-shell-command t)
      (byte-compile-if-newer "~/.elisp/shell-command")
      (require 'shell-command)
      (shell-command-completion-mode)
      )
  (message "package shell-command not available")
  )

;; shell-toggle.el -- Toggle to and from the *shell* buffer
(defvar have-shell-toggle 'nil)
(if (locate-library "shell-toggle")
    (progn
      (setq have-shell-toggle t)
      (byte-compile-if-newer "~/.elisp/shell-toggle")
      (autoload 'shell-toggle "shell-toggle" "Toggles between the *shell* buffer and whatever buffer you are editing." t)
      (autoload 'shell-toggle-cd "shell-toggle" "Pops up a shell-buffer and insert a \"cd <file-dir>\" command." t)
      )
  (message "package shell-toggle not available")
  )

;;; syslog.el -- provide a buffer for /var/log/messages named as *syslog*
(defvar have-syslog 'nil)
(if (locate-library "syslog")
    (progn
      (setq have-syslog t)
      (byte-compile-if-newer "~/.elisp/syslog")
      (require 'syslog)
      )
  (message "package syslog not available")
  )

;;; tabbar.el --- Display a tab bar in the header line
(defvar have-tabbar 'nil)
(if (locate-library "tabbar")
    (progn
      (setq have-tabbar t)
      (byte-compile-if-newer "~/.elisp/tabbar")
      (autoload 'tabbar-mode "tabbar" "Toggle the Tabbar global minor mode" t)
      )
  (message "package tabbar not available")
  )

;;; interaction bug with tramp??
;;; tail.el --- Tail files within Emacs
(defvar have-tail 'nil)
(if (locate-library "tail")
    (progn
      (setq have-tail t)
      (byte-compile-if-newer "~/.elisp/tail")
      (autoload 'tail-file "tail" "Tails FILE specified with argument FILE inside a new buffer" t nil)
      (autoload 'tail-command "tail" "Tails COMMAND with arguments ARGS inside a new buffer" t nil)
      )
  (message "package tail not available")
  )

;;; tar-mode.el --- simple editing of tar files from GNU emacs
(defvar have-tar-mode 'nil)
(if (locate-library "tar-mode")
    (progn
      (setq have-tar-mode t)
      (require 'tar-mode)
      )
  (message "package tar-mode not available")
  )

;;; toggle-option.el --- easily toggle frequently toggled options
(defvar have-toggle-option 'nil)
(if (locate-library "toggle-option")
    (progn
      (setq have-toggle-option t)
      (byte-compile-if-newer "~/.elisp/toggle-option")
      (autoload 'toggle-option "toggle-option" "easily toggle frequently toggled options" t)
      )
  (message "package toggle-option not available")
  )

;;; toolbox.el --- create simple menus in buffers
(defvar have-toolbox 'nil)
(if (locate-library "toolbox")
    (progn
      (setq have-toolbox t)
      (byte-compile-if-newer "~/.elisp/toolbox")
      (require 'toolbox)
      )
  (message "package toolbox not available")
  )

;;; tramp.el --- Transparent Remote Access, Multiple Protocol
;; with newer versions of tramp, may want to look at "tramp-persistency-file-name" (ver >= 2.1.6?)
(defvar have-tramp 'nil)
(if (locate-library "tramp")
    (progn
      (setq have-tramp t)
      (require 'tramp)
      (setq tramp-default-method "ssh")
      (add-to-list 'tramp-default-method-alist '("\\`localhost\\'" "\\`root\\'" "su"))
      )
  (message "package tramp not available")
  )

(defvar find-file-root-prefix (if (featurep 'xemacs) "/[sudo/root@localhost]" "/sudo:root@localhost:" )
  "*The filename prefix used to open a file with `find-file-root'.")

(defvar find-file-root-history nil
  "History list for files found using `find-file-root'.")

(defvar find-file-root-hook nil
  "Normal hook for functions to run after finding a \"root\" file.")

(defun find-file-root ()
  "*Open a file as the root user.
   Prepends `find-file-root-prefix' to the selected file name so that it
   maybe accessed via the corresponding tramp method."

  (interactive)
  (require 'tramp)
  (let* ( ;; We bind the variable `file-name-history' locally so we can
         ;; use a separate history list for "root" files.
         (file-name-history find-file-root-history)
         (name (or buffer-file-name default-directory))
         (tramp (and (tramp-tramp-file-p name)
                     (tramp-dissect-file-name name)))
         path dir file)

    ;; If called from a "root" file, we need to fix up the path.
    (when tramp
      (setq path (tramp-file-name-path tramp)
            dir (file-name-directory path)))

    (when (setq file (read-file-name "Find file (UID = 0): " dir path))
      (find-file (concat find-file-root-prefix file))
      ;; If this all succeeded save our new history list.
      (setq find-file-root-history file-name-history)
      ;; allow some user customization
      (run-hooks 'find-file-root-hook))))

(defface find-file-root-header-face
  '((t (:foreground "white" :background "red3")))
  "*Face use to display header-lines for files opened as root.")

(defun find-file-root-header-warning ()
  "*Display a warning in header line of the current buffer.
   This function is suitable to add to `find-file-root-hook'."
  (let* ((warning "WARNING: EDITING FILE AS ROOT!")
         (space (+ 6 (- (frame-width) (length warning))))
         (bracket (make-string (/ space 2) ?-))
         (warning (concat bracket warning bracket)))
    (setq header-line-format
          (propertize  warning 'face 'find-file-root-header-face))))

(add-hook 'find-file-root-hook 'find-file-root-header-warning)

;;; uniquify.el --- unique buffer names dependent on file name
(defvar have-uniquify 'nil)
(if (locate-library "uniquify")
    (progn
      (setq have-uniquify t)
      (require 'uniquify)
      (setq uniquify-buffer-name-style 'forward)
      )
  (message "package uniquify not available")
  )

;; verilog-mode.el --- major mode for editing verilog source in Emacs
(defvar have-verilog-mode 'nil)
(if (locate-library "verilog-mode")
    (progn
      (setq have-verilog-mode t)
      (autoload 'verilog-mode "verilog-mode" "Verilog mode" t )
      (setq auto-mode-alist (cons  '("\\.v\\'" . verilog-mode) auto-mode-alist))
      (setq auto-mode-alist (cons  '("\\.dv\\'" . verilog-mode) auto-mode-alist))
      )
  (message "package verilog-mode not available")
  )

;;; vhdl-mode.el --- major mode for editing VHDL code
(defvar have-vhdl-mode 'nil)
(if (locate-library "vhdl-mode")
    (progn
      (setq have-vhdl-mode t)
      (autoload 'vhdl-mode "vhdl-mode" "VHDL Mode" t)
      (setq auto-mode-alist (cons '("\\.vhdl?\\'" . vhdl-mode) auto-mode-alist))
      )
  (message "package vhdl-mode not available")
  )

;;; xrdb-mode.el --- mode for editing X resource database files
(defvar have-xrdb-mode 'nil)
(if (locate-library "xrdb-mode")
    (progn
      (setq have-xrdb-mode t)
      (byte-compile-if-newer "~/.elisp/xrdb-mode")
      (autoload 'xrdb-mode "xrdb-mode" "Mode for editing X resource files" t)
      (setq auto-mode-alist
            (append '(("\\.Xdefaults$"    . xrdb-mode)
                      ("\\.Xenvironment$" . xrdb-mode)
                      ("\\.Xresources$"   . xrdb-mode)
                      ("*.\\.ad$"         . xrdb-mode)
                      )
                    auto-mode-alist))
      )
  (message "package xrdb-mode not available")
  )

;;; vcursor.el --- manipulate an alternative ("virtual") cursor
(defvar have-vcursor 'nil)
(if (locate-library "vcursor")
    (progn
      (setq have-vcursor t)
      (setq vcursor-key-bindings t)
      (require 'vcursor)
      (global-set-key [C-S-iso-lefttab] 'vcursor-toggle-copy)      
      )
  (message "package vcursor not available")
  )

;;; vline.el --- show vertical line mode.
(defvar have-vline 'nil)
(if (locate-library "vline")
    (progn
      (setq have-vline t)
      (byte-compile-if-newer "~/.elisp/vline")
      (require 'vline)
      )
  (message "package vline not available")
  )

;;; volatile-highlights.el -- Minor mode for visual feedback on some operations.
(defvar have-volatile-highlights 'nil)
(if (locate-library "volatile-highlights")
    (progn
      (setq have-volatile-highlights t)
      (byte-compile-if-newer "~/.elisp/volatile-highlights")
      (require 'volatile-highlights)
      (volatile-highlights-mode t)
      )
  (message "package volatile-highlights not available")
  )

;; window-number.el -- Window number mode allows you to select windows by numbers
(defvar have-window-number 'nil)
(if (locate-library "window-number")
    (progn
      (setq have-window-number t)
      (byte-compile-if-newer "~/.elisp/window-number")
      (require 'window-number)
      (window-number-mode)
      )
  (message "package window-number not available")
  )

;; woman.el --- browse UN*X manual pages `wo (without) man' woman is nice, but
;; it messes up some manpages; therefore, by default bind f1 to man, except on
;; windows, where it is bound to woman
(defvar have-woman 'nil)
(global-set-key [f1] 'man)
(if (locate-library "woman")
    (progn
      (setq have-woman t)
      (setq woman-cache-filename "~/.wmncach.el")
      (autoload 'woman "woman" "Decode and browse a UN*X man page." t)
      (autoload 'woman-find-file "woman" "Find, decode and browse a specific UN*X man-page file." t)
      )
  (message "package woman not available")
  )

;; yasnippet.el --- Yet another snippet extension for Emacs.
(defvar have-yasnippet 'nil)
(if (locate-library "yasnippet")
    (progn
      (setq have-yasnippet t)
      (byte-compile-if-newer "~/.elisp/yasnippet/dropdown-list")
      (byte-compile-if-newer "~/.elisp/yasnippet/yasnippet")
      (require 'yasnippet)
      ;; (yas/initialize)
      ;; (yas/load-directory "~/.elisp/yasnippet/snippets")
      ;; (setq yas/prompt-functions '(yas/dropdown-prompt yas/ido-prompt yas/completing-prompt))
      )
  (message "package yasnippet not available")
  )



;;
;; **********************************************************************
;; **                                                                  **
;; ** Color setup: cursor, themese, etc.                               **
;; **                                                                  **
;; **********************************************************************
;;

;; Set color of cursor according to mode:
;;     red:  buffer is read-only
;;     white: overwrite on
;;     green: else
(defvar hcz-set-cursor-color-color "")
(defvar hcz-set-cursor-color-buffer "")
(defun hcz-set-cursor-color-according-to-mode ()
  "change cursor color according to some minor modes."
  ;; set-cursor-color is somewhat costly, so we only call it when needed:
  (let ((color
         (if buffer-read-only "red"
           (if overwrite-mode "white"
             "green"))))
    (unless (and
             (string= color hcz-set-cursor-color-color)
             (string= (buffer-name) hcz-set-cursor-color-buffer))
      (set-cursor-color (setq hcz-set-cursor-color-color color))
      (setq hcz-set-cursor-color-buffer (buffer-name)))))
(add-hook 'post-command-hook 'hcz-set-cursor-color-according-to-mode)

(defvar local-color-themes (list 'ignore)
  "List of color themes used by `theme-next'. Intended to be set in .local.el.")

(defun car-theme ()
  "Get the next theme"
  (interactive)
  (if (equal have-color-theme t)
      (cond
       ((consp (car theme-current))
        (caar theme-current))
       (t
        (car theme-current)))
    )
  )

(defun theme-initialize ()
  "Initialize the theme"
  (interactive)
  (if (equal have-color-theme t)
      (progn
        (setq theme-current local-color-themes)
        (funcall (car-theme))
        (set-face-attribute 'mode-line nil :box nil)
        (hcz-set-cursor-color-according-to-mode)
        )
    )
  )

(defun theme-next ()
  "Goto next theme"
  (interactive)
  (if (equal have-color-theme t)
      (progn
        (setq theme-current (cdr theme-current))
        (if (null theme-current)
            (setq theme-current local-color-themes))
        (funcall (car-theme))
        (set-face-attribute 'mode-line nil :box nil)
        (hcz-set-cursor-color-according-to-mode)
        (message "%S" (car-theme)))
    )
  )

(defun do-theme ()
  "Call/recall current theme"
  (interactive)
  (if (equal have-color-theme t)
      (progn
        (funcall (car-theme))
        (set-face-attribute 'mode-line nil :box nil)
        (hcz-set-cursor-color-according-to-mode)
        (message "%S" (car-theme))
        )
    )
  )



;;
;; **********************************************************************
;; **                                                                  **
;; ** Custom functions                                                 **
;; **                                                                  **
;; **********************************************************************
;;

(defun time-stamp ()
  "Insert a time stamp."
  (interactive "*")
  (insert (concat "[" (format-time-string "%c" (current-time)) " " user-real-login-name "@" hostname "]")))

(defun custom-make-clean ()
  "run 'make clean'"
  (interactive)
  (ro-all)
  (compile "make clean"))

(defun custom-make ()
  "run make"
  (interactive)
  (ro-all)
  (compile "make"))

(defun custom-make-install ()
  "run 'make install'"
  (interactive)
  (ro-all)
  (compile "make install"))

(defun magic-key ()
  "If text, spell check; if not, run make install"
  (interactive)

    (if (equal major-mode 'text-mode)
        (progn
          (message "magic key for text-mode")
          (ispell-buffer)
          )
      (progn
        (message "magic key for non-text mode")
        (custom-make-install)
        )
      )
  )

(defun custom-make-install-run ()
  "run `make install run`"
  (interactive)
  (ro-all)
  (compile "make install run"))

(defun custom-debug ()
  "run ddd"
  (interactive)
  (shell-command "ddd_from_emacs.sh &"))

(defun up-slightly () (interactive) (scroll-up 5))
(defun down-slightly () (interactive) (scroll-down 5))
(defun up-one () (interactive) (scroll-up 1))
(defun down-one () (interactive) (scroll-down 1))
(defun up-a-lot () (interactive) (scroll-up))
(defun down-a-lot () (interactive) (scroll-down))

;; http://www.opensubscriber.com/message/help-gnu-emacs@gnu.org/11012893.html
(defun kill-buffer-del-frame ()
  "kill buffer, and delete frame"
  (interactive)
  (when (and (frame-live-p (selected-frame))
             (kill-this-buffer))
    (delete-frame))
  )

(defun vi-type-paren-match (arg)
  "Go to the matching parenthesis if on parenthesis otherwise insert %."
  (interactive "p")
  (cond ((looking-at "[([{]") (forward-sexp 1) (backward-char))
        ((looking-at "[])}]") (forward-char) (backward-sexp 1))
        (t (self-insert-command (or arg 1)))))

(defun switch-to-scratch ()
  "Switch to scratch buffer. Create one in `emacs-lisp-mode' if not exists."
  (interactive)
  (let ((previous (get-buffer "*scratch*")))
    (switch-to-buffer "*scratch*")
                                        ; don't change current mode
    (unless previous (emacs-lisp-mode))))

(defun switch-to-messages ()
  "Switch to message buffer. Create one in `emacs-lisp-mode' if not exists."
  (interactive)
  (let ((previous (get-buffer "*Messages*")))
    (switch-to-buffer "*Messages*")
                                        ; don't change current mode
    (unless previous (emacs-lisp-mode))))

(defun setup-cc-mode () (interactive)
  (setq c-hungry-delete-key t)
  (setq c-tab-always-indent t)
  (setq c-basic-offset 4)
  (setq c-default-style '((other . "user")))
  (c-set-style "user")
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'case-label '+)
  (c-set-offset 'innamespace 0)
  (turn-on-auto-fill)
  (setq fill-column 80)
  (message "configured for c/c++ edits")
  )
(add-hook 'c-mode-common-hook (function (lambda () (setup-cc-mode))))

(defun linux-c-mode () (interactive)
  (c-mode)
  (c-set-style "linux")
  (message "configured for c edits in linux kernel source code")
  )
(setq auto-mode-alist (cons '("/usr/src/linux.*/.*\\.[ch]$" . linux-c-mode) auto-mode-alist))

;; Emacs integration by Richard Hult <richard@imendio.com>
(defun devhelp-word-at-point ()
  "runs devhelp"
  (interactive)
  (setq w (current-word))
  (start-process-shell-command "devhelp" nil "devhelp" "-s" w)
  )

(defun custom-term ()
  "custom terminal launcher"
  (interactive)
  (split-window-vertically)
  (next-multiframe-window)
  (ansi-term (getenv "SHELL"))
  ;;  (eshell)
;;  (rename-uniquely)
  )
;;  (make-frame)
;;  (raise-frame)
;;  (focus-frame)
;;...
;;  (switch-to-buffer "*terminal*")

(defun custom-command ()
  "custom command execution"
  (interactive)
  (message "Executing custom-cmd")
  (shell-command custom-cmd))

(defun new-custom-command ()
  "define a new custom command"
  (interactive)
  (switch-to-scratch)
  (end-of-buffer)
  (insert "\n")
  (insert "; ----------------------------------------------------------------------\n")
  (insert "; - enter new command in quotes below\n")
  (insert "; - put an ampersand (&) at the end of the command to execute in\n")
  (insert ";   the background\n")
  (insert "; - to set the variable, go to the end of the line and press C-j\n")
  (insert "; \n")
  (insert "; - to execute, run the command custom-command or use the key\n")
  (insert ";   C-c u\n")
  (insert "(setq custom-cmd \"")
  (insert custom-cmd)
  (insert "\")")
  (beginning-of-line)
  (forward-word 4)
  (backward-word 1))

(defun backup-file ()
  "Backup a file"
  (interactive)
  (shell-command (concat "source $HOME/.functions; bkup " (buffer-file-name (current-buffer)))))

;; Kill the first word in all lines a buffer
(defun kill-first-word()
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (while (not (eobp))
      (kill-word 1)
      (forward-line 1))))

;; Kill the last word in all lines in buffer
(defun kill-last-word()
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (while (not (eobp))
      (end-of-line)
      (backward-kill-word 1)
      (forward-line 1))))

;; Insert word at end of all lines in buffer
(defun insert-word-line-end(arg)
  (interactive "sWord: ")
  (beginning-of-buffer)
  (while (not (eobp))
    (end-of-line)
    (insert-string arg)
    (forward-line 1)))

;; Insert word at begin of all lines in buffer
(defun insert-word-buffer-start(arg)
  (interactive "sWord: ")
  (beginning-of-buffer)
  (while (not (eobp))
    (beginning-of-line)
    (insert-string arg)
    (forward-line 1)))

;; Kill last character of all lines in buffer
(defun kill-last-char()
  (interactive)
  (beginning-of-buffer)
  (while (not (eobp))
    (end-of-line)
    (backward-kill-char 1)
    (forward-line 1)))

;; Removes newlines
(defun remove-newlines()
  (interactive)
  (while (not (eobp))
    (replace-string "\n" "")))

(defun custom-calc()
  "Run calc in a shell window"
  (interactive)

  (setq local-explicit-shell-file-name explicit-shell-file-name)
  (setq explicit-shell-file-name "calc")
  (shell "*calc*")
  (setq explicit-shell-file-name local-explicit-shell-file-name)
  )

(defun pretty-code ()
  "Code beautification"
  (interactive)
  ;;  (set-buffer-file-coding-system "unix")
  (delete-trailing-whitespace)
  (mark-whole-buffer)
  (untabify  (region-beginning) (region-end))
  (mark-whole-buffer)
  (indent-region (region-beginning) (region-end) nil)
  )

(defun pretty-text ()
  "Text beautification"
  (interactive)
  (set-buffer-file-coding-system "unix")
  (delete-trailing-whitespace)
  )

(defun git-diff ()
  "Run git-diff on current file, against HEAD"
  (interactive)
  (shell-command (concat "cd `dirname " (buffer-file-name (current-buffer)) "`; git diff HEAD -- `basename " (buffer-file-name (current-buffer)) "` > /dev/null 2>&1 &" ))
  )

(defun git-gui-blame ()
  "Run git-gui-blame on current file"
  (interactive)
  (shell-command (concat "cd `dirname " (buffer-file-name (current-buffer)) "`; git gui blame `basename " (buffer-file-name (current-buffer)) "` > /dev/null 2>&1 &" ))
  )

(defun lincvs-here ()
  "Run lincvs here"
  (interactive)
  (shell-command "if [ -d \"CVS\" ]; then lincvs `pwd` ; else lincvs ; fi &")
  )

(defun show-file ()
  "Show the name of the current file"
  (interactive)
  (message "%s" (buffer-file-name))
  )

;; stolen from http://www.cabochon.com/~stevey
;; someday might want to rotate windows if more than 2 of them
(defun swap-windows ()
  "If you have 2 windows, it swaps them."
  (interactive)
  (cond
   ((not (= (count-windows) 2))
    (message "You need exactly 2 windows to do this."))
   (t
    (let* ((w1 (first (window-list)))
           (w2 (second (window-list)))
           (b1 (window-buffer w1))
           (b2 (window-buffer w2))
           (s1 (window-start w1))
           (s2 (window-start w2)))
      (set-window-buffer w1 b2)
      (set-window-buffer w2 b1)
      (set-window-start w1 s2)
      (set-window-start w2 s1)))))

(defun custom-make-frame ()
  "Make a frame, then apply a theme to the frame"
  (interactive)
  (select-frame (make-frame))
  (do-theme)
  )

(defun sys-vars ()
  "Load system_makefile_vars.makefile"
  (interactive)
  (setq generic-sys-var (concat (getenv "BUILD_SETUP_DIR") "system_makefile_vars.makefile" ))
  (setq specific-sys-var (concat (getenv "BUILD_SETUP_CONFIGS") "system_makefile_vars.makefile." (getenv "HOSTNAME")))
  (if (file-exists-p specific-sys-var) (find-file-read-only specific-sys-var))
  (if (file-exists-p generic-sys-var) (split-window-vertically))
  (if (file-exists-p generic-sys-var) (find-file-read-only generic-sys-var))
  )

(defun make-needs ()
  "Load make.needs"
  (interactive)
  (split-window-horizontally)
  (find-file-read-only (concat (getenv "BUILD_SETUP_DIR") "make.needs" ))
  )

(defun super-find-tag ()
  "Update TAGS, then find-tag"
  (interactive)
  (shell-command "make `make show_tags`")
  (setq-default tags-table-list 'nil)
  (setq-default tags-file-name (shell-command-to-string "make show_tags"))
  (find-tag (find-tag-default))
  )

;; Stefan Monnier <foo at acm.org>. It is the opposite of fill-paragraph
;; Takes a multi-line paragraph and makes it into a single line of text.
(defun unfill-paragraph ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))

(defun unix-werase-or-kill (arg)
  (interactive "*p")
  (if (and transient-mark-mode
           mark-active)
      (kill-region (region-beginning) (region-end))
    (backward-kill-word arg)))

(defun duplicate-line (arg)
  "Duplicate current line, leaving point in lower line."
  (interactive "*p")

  ;; save the point for undo
  (setq buffer-undo-list (cons (point) buffer-undo-list))

  ;; local variables for start and end of line
  (let ((bol (save-excursion (beginning-of-line) (point)))
        eol)
    (save-excursion

      ;; don't use forward-line for this, because you would have
      ;; to check whether you are at the end of the buffer
      (end-of-line)
      (setq eol (point))

      ;; store the line and disable the recording of undo information
      (let ((line (buffer-substring bol eol))
            (buffer-undo-list t)
            (count arg))
        ;; insert the line arg times
        (while (> count 0)
          (newline)         ;; because there is no newline in 'line'
          (insert line)
          (setq count (1- count)))
        )

      ;; create the undo information
      (setq buffer-undo-list (cons (cons eol (point)) buffer-undo-list)))
    ) ; end-of-let

  ;; put the point in the lowest line and return
  ;;(next-line arg)

  )

;; borrowed from emacs wiki (ToggleWindowSplit); toggles between two windows
;; split horizontally and vertically
(defun toggle-window-split ()
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
                                         (car next-win-edges))
                                     (<= (cadr this-win-edges)
                                         (cadr next-win-edges)))))
             (splitter
              (if (= (car this-win-edges)
                     (car (window-edges (next-window))))
                  'split-window-horizontally
                'split-window-vertically)))
        (delete-other-windows)
        (let ((first-win (selected-window)))
          (funcall splitter)
          (if this-win-2nd (other-window 1))
          (set-window-buffer (selected-window) this-win-buffer)
          (set-window-buffer (next-window) next-win-buffer)
          (select-window first-win)
          (if this-win-2nd (other-window 1))))))

(defun build-debug ()
  "Configured for debug development"
  (interactive)
  (setq new_PATH (shell-command-to-string "source ~/.functions; debug > /dev/null; echo $PATH"))
  (setq new_LD_LIBRARY_PATH (shell-command-to-string "source ~/.functions; debug > /dev/null; echo $LD_LIBRARY_PATH"))
  (setq new_DEFAULT_BUILD_ID (shell-command-to-string "source ~/.functions; debug > /dev/null; echo $DEFAULT_BUILD_ID"))
  (setenv "PATH" (substring new_PATH 0 (- (length new_PATH) 1)))
  (setenv "LD_LIBRARY_PATH" (substring new_LD_LIBRARY_PATH 0 (- (length new_LD_LIBRARY_PATH) 1)))
  (setenv "DEFAULT_BUILD_ID" (substring new_DEFAULT_BUILD_ID 0 (- (length new_DEFAULT_BUILD_ID) 1)))
  (setq frame-title-format (concat "%b ("user-real-login-name"@"hostname") -- DEBUG -- emacs"))
  (message "Configured for debug development"))

(defun build-release ()
  "Configured for release development"
  (interactive)
  (setq new_PATH (shell-command-to-string "source ~/.functions; release > /dev/null; echo $PATH"))
  (setq new_LD_LIBRARY_PATH (shell-command-to-string "source ~/.functions; release > /dev/null; echo $LD_LIBRARY_PATH"))
  (setq new_DEFAULT_BUILD_ID (shell-command-to-string "source ~/.functions; release > /dev/null; echo $DEFAULT_BUILD_ID"))
  (setenv "PATH" (substring new_PATH 0 (- (length new_PATH) 1)))
  (setenv "LD_LIBRARY_PATH" (substring new_LD_LIBRARY_PATH 0 (- (length new_LD_LIBRARY_PATH) 1)))
  (setenv "DEFAULT_BUILD_ID" (substring new_DEFAULT_BUILD_ID 0 (- (length new_DEFAULT_BUILD_ID) 1)))
  (setq frame-title-format (concat "%b ("user-real-login-name"@"hostname") -- RELEASE -- emacs"))
  (message "Configured for release development"))

(defun build-profile ()
  "Configured for profile development"
  (interactive)
  (setq new_PATH (shell-command-to-string "source ~/.functions; profile > /dev/null; echo $PATH"))
  (setq new_LD_LIBRARY_PATH (shell-command-to-string "source ~/.functions; profile > /dev/null; echo $LD_LIBRARY_PATH"))
  (setq new_DEFAULT_BUILD_ID (shell-command-to-string "source ~/.functions; profile > /dev/null; echo $DEFAULT_BUILD_ID"))
  (setenv "PATH" (substring new_PATH 0 (- (length new_PATH) 1)))
  (setenv "LD_LIBRARY_PATH" (substring new_LD_LIBRARY_PATH 0 (- (length new_LD_LIBRARY_PATH) 1)))
  (setenv "DEFAULT_BUILD_ID" (substring new_DEFAULT_BUILD_ID 0 (- (length new_DEFAULT_BUILD_ID) 1)))
  (setq frame-title-format (concat "%b ("user-real-login-name"@"hostname") -- PROFILE -- emacs"))
  (message "Configured for profile development"))

(defun build-default ()
  "Configured for default development"
  (interactive)
  (setq new_PATH (shell-command-to-string "source ~/.functions; default > /dev/null; echo $PATH"))
  (setq new_LD_LIBRARY_PATH (shell-command-to-string "source ~/.functions; default > /dev/null; echo $LD_LIBRARY_PATH"))
  (setenv "PATH" (substring new_PATH 0 (- (length new_PATH) 1)))
  (setenv "LD_LIBRARY_PATH" (substring new_LD_LIBRARY_PATH 0 (- (length new_LD_LIBRARY_PATH) 1)))
  (setenv "DEFAULT_BUILD_ID" "")
  (setq frame-title-format (concat "%b ("user-real-login-name"@"hostname") -- emacs"))
  (message "Configured for default development"))

(defun build ()
  "Echo development type"
  (interactive)
  (if (or (equal (getenv "DEFAULT_BUILD_ID") "")
          (equal (getenv "DEFAULT_BUILD_ID") nil))
      (message "Build type: default")
    (message (concat "Build type: " (getenv "DEFAULT_BUILD_ID"))))
  )

;; configure for sofware development
;; loads NEED_XX_doc.txt for support of completion of NEED_XX variables in
;; makefiles
(defun devel ()
  "Setup for software development"
  (interactive)

  (condition-case ()
      (find-file-read-only (concat (getenv "BUILD_SETUP_DIR") "doc/NEED_XX_doc.txt" ))
    (error nil) ((protect-buffer-from-kill-mode) (bury-buffer))
    )

  (condition-case ()
      (find-file-read-only (concat (getenv "SOURCE") "/incs.txt" ))
    (error nil) ((protect-buffer-from-kill-mode) (bury-buffer))
    )

  (condition-case ()
      (find-file-read-only (concat (getenv "NOTES") "/LockheedMartin/todo.txt" ))
    (error nil) ((protect-buffer-from-kill-mode) (bury-buffer))
    )

  (message "You probably want to invoke build-default, build-debug, build-profile, or build-release")
  )

(defun make-cpp-scratch ()
  "Make a scratch c++ buffer"
  (interactive)
  (with-current-buffer
      (get-buffer-create "*cpp-scratch*")
    (c++-mode))
  )

;; http://platypope.org/blog/2007/8/5/a-compendium-of-awesomeness
;; I-search with initial contents
(defvar isearch-initial-string nil)
(defun isearch-set-initial-string ()
  (remove-hook 'isearch-mode-hook 'isearch-set-initial-string)
  (setq isearch-string isearch-initial-string)
  (isearch-search-and-update))
(defun isearch-forward-at-point (&optional regexp-p no-recursive-edit)
  "Interactive search forward for the symbol at point."
  (interactive "P\np")
  (if regexp-p (isearch-forward regexp-p no-recursive-edit)
    (let* ((end (progn (skip-syntax-forward "w_") (point)))
           (begin (progn (skip-syntax-backward "w_") (point))))
      (if (eq begin end)
          (isearch-forward regexp-p no-recursive-edit)
        (setq isearch-initial-string (buffer-substring begin end))
        (add-hook 'isearch-mode-hook 'isearch-set-initial-string)
        (isearch-forward regexp-p no-recursive-edit)))))

(defun do-header-protection ()
  (interactive)
  (let ((name buffer-file-name))
    (when name
      (setq name (upcase (replace-regexp-in-string "[^a-zA-Z]+" "_"
                                                   (file-name-nondirectory name)))))
    (save-excursion
      (beginning-of-buffer)
      (insert "#ifndef " name "\n#define " name "\n\n")
      (end-of-buffer)
      (insert "\n\n#endif\n"))))

(defun search-google ()
  "Prompt for a query in the minibuffer, launch the web browser and query google."
  (interactive)
  (let ((search (read-from-minibuffer "Google Search: ")))
    (browse-url (concat "http://www.google.com/search?q=" search))))

(defun ro-all ()
  "Make all file buffers read-only"
  (interactive)
  (dolist
      (buffer (buffer-list))
    (with-current-buffer buffer
      (if (and (equal buffer-read-only nil)
               (not (equal buffer-file-name nil))) (toggle-read-only))
      ))
  )

;; found on http://emacs.wordpress.com/
(defun toggle-selective-display (column)
  (interactive "P")
  (set-selective-display
   (if selective-display nil (or column 1))))

;; stolen from somewhere, fixed to make it work
(defun kio-find-file ()
  (interactive)
  (let ((file-name
         (replace-regexp-in-string
          "[\n]+" ""
          (shell-command-to-string "kdialog --getopenurl ~ 2> /dev/null"))))
    (cond
     ((string-match "^file:/" file-name)
      (let ((local-file-name (substring file-name 5)))
        (message "Opening local file '%s'" local-file-name)
        (find-file local-file-name)))
     ((string-match "^[:space:]*$" file-name)
      (message "Empty file name given, doing nothing..."))
     (t
      (message "Opening remote file '%s'" file-name)
      (save-window-excursion
        (shell-command (concat "kioexec emacsclient " file-name "&")))))))

;; borrowed from http://emacs-fu.blogspot.com/2008/12/zooming-inout.html
(defun zoom (n)
  "with positive N, increase the font size, otherwise decrease it"
  (set-face-attribute 'default (selected-frame) :height
                      (+ (face-attribute 'default :height) (* (if (> n 0) 1 -1) 10))))

(defun full-screen-toggle (&optional f)
  (interactive)
  (set-frame-parameter f 'fullscreen
                       (if (frame-parameter f 'fullscreen) nil 'fullboth)))
;; ;; borrowed from http://emacs-fu.blogspot.com/2008/12/running-emacs-in-full-screen-mode.html
;; (defun full-screen-toggle ()
;;   "toggle full-screen mode"
;;   (interactive)
;;   (shell-command "wmctrl -r :ACTIVE: -btoggle,fullscreen"))

;; edit time recording
(defun edit-timesheet ()
  "edit timesheet"
  (interactive)
  (split-window-vertically)
  (find-file-read-only "~/Documents/TimeKeeping/time.txt")
  )

;; stolen from: http://stackoverflow.com/questions/206806/filtering-text-through-a-shell-command-in-emacs
(defun generalized-shell-command (command arg)
  "Unifies `shell-command' and `shell-command-on-region'. If no region is
selected, run a shell command just like M-x shell-command (M-!).  If
no region is selected and an argument is a passed, run a shell command
and place its output after the mark as in C-u M-x `shell-command' (C-u
M-!).  If a region is selected pass the text of that region to the
shell and replace the text in that region with the output of the shell
command as in C-u M-x `shell-command-on-region' (C-u M-|). If a region
is selected AND an argument is passed (via C-u) send output to another
buffer instead of replacing the text in region."
  (interactive (list (read-from-minibuffer "Shell command: " nil nil nil 'shell-command-history)
                     current-prefix-arg))
  (let ((p (if mark-active (region-beginning) 0))
        (m (if mark-active (region-end) 0)))
    (if (= p m)
        ;; No active region
        (if (eq arg nil)
            (shell-command command)
          (shell-command command t))
      ;; Active region
      (if (eq arg nil)
          (shell-command-on-region p m command t t)
        (shell-command-on-region p m command)))))

(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file name new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))

(defun my-save-buffers()
  "make read-only, then call save-buffers"
  (interactive)
  ;; make the buffer writeable - in case there are changes, it is read-only,
  ;; and a trailing newline needs to be added
  (if (buffer-file-name) (toggle-read-only -1))    
  (save-buffer)
  ;; make the buffer read-only
  (if (buffer-file-name) (toggle-read-only 1))  
  )



;;
;; **********************************************************************
;; **                                                                  **
;; ** Options                                                          **
;; **                                                                  **
;; **********************************************************************
;;

;; vc-git seemingly causes unacceptable delays when loading files
(setq vc-handled-backends 'nil)

;; do not display a message in *scratch* buffer at startup
(setq initial-scratch-message 'nil)

;; keep the mouse pointer out of the way
;; This is good except the point jumps around when pasting with the
;;    middle mouse button
;;(if (or (equal window-system 'x)
;;        (equal window-system 'win32)
;;        (equal window-system 'w32))
;;    (mouse-avoidance-mode 'exile)
;;  )

;; this can be useful for occur
;;(setq list-matching-lines-default-context-lines 1)

;; Turn on font-lock mode for Emacs
(global-font-lock-mode t)

;; if images supported, then automatically display them
(if (fboundp 'auto-image-file-mode) (auto-image-file-mode 1))

;; kill whole line if at column 0
(setq-default kill-whole-line t)

;; hungry deletion
(setq c-hungry-delete-key t)
;;(setq cpp-hungry-delete-key t)
;;(setq c++-hungry-delete-key t)

;; Delete selected region with backspace or delete
(setq delete-selection-mode t)

;; follow symbolic links for CVS controlled files? (nil: display
;; warning message; t: automatically follows links; ask: queries user)
(setq-default vc-follow-symlinks t)

;; keep backup files for CVS controlled files?
(setq-default vc-keep-workfiles t)

;; frame title format (%f = file name, %b = buffer name)
(setq frame-title-format
      (concat "%b ("user-real-login-name"@"hostname") -- emacs")
      )

;; icon title format (%f = file name, %b = buffer name)
(setq-default icon-title-format
              (concat "%b ("user-real-login-name"@"hostname") [emacs]")
              )

;; make query-replace highlight
(setq query-replace-highlight t)

;; highlight incremental search
(setq search-highlight t)

;; Completion help
(setq completion-auto-help t)
(setq completion-auto-exit t)

;; scrolling options
;;(setq scroll-step 1)
(setq scroll-up-aggressively 0)
(setq scroll-down-aggressively 0)
(setq scroll-margin 0)
(setq scroll-conservatively 10000000)

;; This really does not work and end up messing up scrolling with the wheel mouse; jmn
;;(setq scroll-preserve-screen-position 1)

;; prevent crazy mouse wheel scrolling
(setq mouse-wheel-progressive-speed 'nil)

;; max size for font-lock; nil for no max size
(setq font-lock-maximum-size 2097152)

;; Max decorations
(setq font-lock-maximum-decoration t)

;; Always highlight marked region
(setq transient-mark-mode t)

;; Display the line number in the status bar
(setq line-number-mode t)

;; Display the column number in the status bar
(setq column-number-mode t)

;; Default tab width
;; this is the number of spaces used for a tab character
(setq default-tab-width 4)
(setq-default tab-width 4)

;; use spaces for whitespace
(setq indent-tabs-mode nil)
(setq-default indent-tabs-mode nil)

;; always indent with TAB in cc-mode
(setq c-tab-always-indent t)

;; Show marker for trailing empty lines
(setq indicate-empty-lines t)
(setq default-indicate-empty-lines t)

;; Different indentation for switch statement in CC-mode
(c-set-offset 'case-label '+)

;; Default/basic indent in CC-mode is 4 spaces
(setq c-basic-offset 4)

;; No space on opening a block
(setq c-default-style '((other . "user")))
(c-set-offset 'substatement-open 0)

;; Display the day, time, and date in the status bar
(setq display-time-mail-file 'nil)
(setq display-time-mail-directory 'nil)
(setq display-time-mail-function 'nil)
(setq display-time-day-and-date 'nil)
(setq display-time-24hr-format 'nil)
;;(display-time)

;; C-n does not add lines to the end of a file
(setq next-line-add-newlines nil)

;; Always put a final newline at the end of a file
(setq require-final-newline t)
;;(setq require-final-newline 'query)

;; Put the scroll bar on the right
;;(set-scroll-bar-mode `right)
;;(setq scroll-bar-mode-explicit t)

;; Dired setup

(autoload 'dired-jump "dired-x" "Jump to dired buffer corresponding to current buffer." 'interactive)

(setq dired-listing-switches "-l -a -F --time-style=long-iso")

;; LC_ALL is typically set to "C".  With this setting, however, ls sorts by
;; ASCII code (such as used with dired).  It is preferred to have a
;; case-insensitive sort.  To do this, the emacs_insert_directory_wrapper sets
;; LC_ALL to en_US, and then calls ls with the arguments provided.  A hack for
;; sure.
(defvar have-dired-wrapper t)
;; fail gracefully when script is not present
(condition-case () (call-process "emacs_insert_directory_wrapper" 'nil 'nil) (error (progn
                                                                                      (setq have-dired-wrapper 'nil)
                                                                                      (message "script emacs_insert_directory_wrapper not found; dired list will be sorted according to LC_ALL"))))
(if (equal have-dired-wrapper t) (setq insert-directory-program "emacs_insert_directory_wrapper"))

(add-hook 'dired-load-hook
          (function (lambda ()
                      (load "dired-x")
                      ;; Set global variables here.  For example:
                      ;; (setq dired-guess-shell-gnutar "gtar")
                      )))

(add-hook 'dired-mode-hook
          (function (lambda ()
                      ;; Set buffer-local variables here.  For example:
                      (dired-omit-mode 1)
                      )))

(put 'dired-find-alternate-file 'disabled nil)
(setq dired-auto-revert-buffer t)

;; I want to make opening a file from dired such that the file is opened
;; read-only.  It's probably possible to provide advice to dired-find-file,
;; but I'm too lazy to figure it out.  So just rip off dired-find-file from
;; the emacs source (lisp/dired.el), change find-file to find-file-read-only,
;; and remaap the associated keys.
(defun jmn-dired-find-file ()
  "In Dired, visit the file or directory named on this line."
  (interactive)
  ;; Bind `find-file-run-dired' so that the command works on directories
  ;; too, independent of the user's setting.
  (let ((find-file-run-dired t))
    (find-file-read-only (dired-get-file-for-visit))))
;; (define-key dired-mode-map "e" 'jmn-dired-find-file)
;; (define-key dired-mode-map "f" 'jmn-dired-find-file)
;; (define-key dired-mode-map [return] 'jmn-dired-find-file)
(add-hook 'dired-load-hook
          (function (lambda ()
;;                      (load "dired-x")
                      (define-key dired-mode-map "e" 'jmn-dired-find-file)
                      (define-key dired-mode-map "f" 'jmn-dired-find-file)
                      (define-key dired-mode-map [return] 'jmn-dired-find-file)
                      )))

;; In ibuffer, C-x C-f is overloaded to find-file.  Fix this to be find-file-read-only
(defun jmn-ibuffer-find-file (file &optional wildcards)
  "Like `find-file', but default to the directory of the buffer at point."
  (interactive
   (let ((default-directory (let ((buf (ibuffer-current-buffer)))
                              (if (buffer-live-p buf)
                                  (with-current-buffer buf
                                    default-directory)
                                default-directory))))
     (list (read-file-name "Find file: " default-directory)
           t)))
  (find-file-read-only file wildcards))
(add-hook 'ibuffer-mode-hook
          (function (lambda ()
                      (define-key ibuffer-mode-map (kbd "C-x C-f") 'jmn-ibuffer-find-file)
                      )))


;; User name
(setq user-full-name "")

;; User mail address
(setq user-mail-address "")

;; Inhibit the startup message
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)
(setq inhibit-splash-screen t)

;; Inhibit startup buffer menu
(setq inhibit-startup-buffer-menu t)

;; no backup files
(setq make-backup-files nil)

;; Set the default major mode
(setq default-major-mode 'fundamental-mode)

;; prompt before exiting
(setq kill-emacs-query-functions
      (cons (lambda () (yes-or-no-p "Really kill Emacs? "))
            kill-emacs-query-functions))

;; suppress printing
(setq lpr-command "")
(setq lpr-switches '"")
(setq ps-lpr-command "")
(setq ps-lpr-switches '"")
(setq printer-name "")
(setq ps-printer-name "")

;; display some buffers in their own frame
(setq special-display-buffer-names
      (cons "*compilation*" special-display-buffer-names))
(setq special-display-buffer-names
      (cons "*grep*" special-display-buffer-names))
(setq special-display-buffer-names
      (cons "*Occur*" special-display-buffer-names))
(setq special-display-buffer-names
      (cons "*Help*" special-display-buffer-names))

;; specially displayed buffers get no toolbars
(add-to-list 'special-display-frame-alist '(tool-bar-lines . 0))

;; toggle the toolbar off;
(tool-bar-mode -1)

;; toggle the menu bar off
(menu-bar-mode -1)

;; turn the scroll bars off
(scroll-bar-mode -1)

;;; display the current function in the modeline
;;(which-function-mode)

;; case insensitive completion
(setq completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)
(setq read-buffer-completion-ignore-case t)

;;; browse with firefox
(if (or (equal window-system 'win32)
        (equal window-system 'w32)
        (equal window-system 'x))
    (setq browse-url-generic-program (executable-find "firefox") browse-url-browser-function 'browse-url-generic)
  )

;;make the y or n suffice for a yes or no question
(fset 'yes-or-no-p 'y-or-n-p)

;; Paste at cursor NOT mouse pointer position
(setq mouse-yank-at-point t)

;; If 1st line begins with #!, make the file executable when saving
;; Glenn Morris <rgm22 at cam.ac.uk> Sun Jul 07 11:11:51 2002
(if (fboundp 'executable-make-buffer-file-executable-if-script-p)
    (add-hook 'after-save-hook
              'executable-make-buffer-file-executable-if-script-p))

(setq resize-minibuffer-mode t)

;; disable keystroke suggestions
;;(setq suggest-key-bindings 'nil)

;; narrow to region -- hide chunks of files
(put 'narrow-to-region 'disabled nil)

;; enable command
(put 'upcase-region 'disabled nil)

;; allow
(put 'erase-buffer 'disabled nil)

;; make the mouse pointer an arrow
(if (equal window-system 'x)
    (setq x-pointer-shape x-pointer-left-ptr)
  )

;; set spacing between lines
(setq-default line-spacing 0)

;; for a highlighted region, delete and replace with new text
(delete-selection-mode 1)

;; don't show cursor in non-selected windows
;;(setq cursor-in-non-selected-windows nil)

;; flyspell config -- spell checking as you type
(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))
(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1))))

(setq mouse-scroll-delay 0)
(setq x-selection-timeout 0)

;; compilation mode customization
(setq compile-command "make")
(setq compilation-scroll-output t)
(setq compilation-window-height 25)
(setq compilation-finish-function
      (lambda (buf str)
        (if (equal major-mode 'compilation-mode)
            (if (string-match "exited abnormally" str)
                ;;there were errors
                (message "COMPILE ERRORS!  Press C-x ` to visit")
              ;;no errors, make the compilation window go away in 0.5 seconds
              (run-at-time 1.0 nil 'delete-windows-on buf)
              (message "No errors in compilation")))))

;; don't ask for confirmation in ibuffer
(setq ibuffer-expert t)

;; when the cursor is on a tab, stretch the cursor
(setq x-stretch-cursor t)

;; Make cut/copy/paste set/use the X CLIPBOARD in preference to the X PRIMARY.
;; Unbreaks cut and paste between Emacs and well-behaved applications like
;; Mozilla, KDE, and GNOME, but breaks cut and paste between Emacs and old
;; applications like terminals.
;; JMN -- need to have KDE setup for a "unified" clipboard and selection
;; buffer for this to work properly
;; klipper / configure - "Synchronize contents of the clipboard and the
;; selection"
;; (if (or (equal window-system 'x)
;;         (setq x-select-enable-clipboard t)
;;         ))
(if (or (equal window-system 'x)
        (equal window-system 'win32)
        (equal window-system 'w32))
    (setq x-select-enable-clipboard t)
  )

(setq ring-bell-function (lambda () (message "BEEP BEEP BEEP BEEP BEEP")))

;; turn off 3d effect of mode line
(set-face-attribute 'mode-line nil :box nil)

;; save bookmarks
(setq bookmark-save-flag 1)

(if (equal (getenv "IS_COMMON_ACCT") "true")
    (message "the emacs server will not be started on this common account")
  (progn
    (server-start)
    (add-hook 'server-switch-hook
              (lambda nil
                (let ((server-buf (current-buffer)))
                  (bury-buffer)
                  (switch-to-buffer-other-frame server-buf))))
    (add-hook 'server-done-hook 'delete-frame)
    (add-hook 'server-done-hook (lambda nil (kill-buffer nil)))
    )
  )

;; automatically indenting yanked text if in programming-modes
(defvar yank-indent-modes '(emacs-lisp-mode
                            c-mode c++-mode
                            tcl-mode sql-mode
                            perl-mode cperl-mode
                            java-mode jde-mode
                            lisp-interaction-mode
                            LaTeX-mode TeX-mode)
  "Modes in which to indent regions that are yanked (or yank-popped)")

(defvar yank-advised-indent-threshold 8000
  "Threshold (# chars) over which indentation does not automatically occur.")

(defun yank-advised-indent-function (beg end)
  "Do indentation, as long as the region isn't too large."
  (if (<= (- end beg) yank-advised-indent-threshold)
      (indent-region beg end nil)))

(defadvice yank (after yank-indent activate)
  "If current mode is one of 'yank-indent-modes, indent yanked text (with prefix arg don't indent)."
  (if (and (not (ad-get-arg 0))
           (member major-mode yank-indent-modes))
      (let ((transient-mark-mode nil))
        (yank-advised-indent-function (region-beginning) (region-end)))))

(defadvice yank-pop (after yank-pop-indent activate)
  "If current mode is one of 'yank-indent-modes, indent yanked text (with prefix arg don't indent)."
  (if (and (not (ad-get-arg 0))
           (member major-mode yank-indent-modes))
      (let ((transient-mark-mode nil))
        (yank-advised-indent-function (region-beginning) (region-end)))))

;; highlight special words in C modes
(add-hook 'c-mode-common-hook
          (lambda ()
            (font-lock-add-keywords nil
                                    '(("\\<\\(FIXME\\|TODO\\|HACK\\|fixme\\|todo\\|hack\\)" 1 
                                       font-lock-warning-face t)))))

;; grow-only
(setq resize-mini-windows 1)

;; auto-fill setup
(set-fill-column 78)
(setq-default fill-column 78)
(setq standard-indent 0)
(add-hook 'text-mode-hook 'auto-fill-mode)
(add-hook 'text-mode-hook 'ruler-mode)

(setq file-name-shadow-properties (quote (invisible t intangible t face file-name-shadow field shadow)))
(setq file-name-shadow-tty-properties (quote (invisible t intangible t field shadow)))

(setq gdb-many-windows t)
(setq gdb-use-inferior-io-buffer t)
(setq gdb-use-separate-io-buffer t)

;; now '_' is not considered a word-delimiter
(add-hook 'c-mode-common-hook '(lambda () (modify-syntax-entry ?_ "w")))

(if (equal (getenv "DEFAULT_BUILD_ID") "DEBUG") (build-debug))
(if (equal (getenv "DEFAULT_BUILD_ID") "RELEASE") (build-release))
(if (equal (getenv "DEFAULT_BUILD_ID") "PROFILE") (build-profile))

;; check spelling in strings, comments
;; (add-hook 'c-mode-hook (function (lambda () (flyspell-prog-mode))))
;; (add-hook 'c++-mode-hook (function (lambda () (flyspell-prog-mode))))

(size-indication-mode)

(icomplete-mode 1)

(setq default-indicate-buffer-boundaries t)

(blink-cursor-mode 0)

;; ignore #include lines
(setq ff-ignore-include t)

;; when toggling between header and source, make the found buffer read-only
(add-hook 'ff-post-load-hook (lambda () (toggle-read-only 1)))

(add-hook 'term-mode-hook
          (function
           (lambda ()
             (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")
             (make-local-variable 'mouse-yank-at-point)
             (make-local-variable 'transient-mark-mode)
             (setq mouse-yank-at-point t)
             (setq transient-mark-mode nil)
             (auto-fill-mode -1)
             (setq tab-width 8 ))))

;; files opened with tramp get added to ido's history... prevent saving ido
;; history between sessions
(setq ido-save-directory-list-file nil)
(require 'ido)
(ido-mode 'both)
(ido-everywhere 1)
(setq ido-case-fold t)
(setq ido-show-dot-for-dired t)
(setq ido-default-file-method 'selected-window)
(setq ido-default-buffer-method 'selected-window)
(setq ido-enable-flex-matching t)
(setq ido-use-filename-at-point nil)
(setq ido-enable-tramp-completion nil)
(add-hook 'ido-setup-hook
          (lambda ()
            (define-key ido-completion-map (kbd "C-w") 'ido-delete-backward-updir)))

;; fix cursor position when exiting isearch
;; from http://www.emacswiki.org/emacs/IncrementalSearch
(add-hook 'isearch-mode-end-hook 'custom-goto-match-beginning)
(defun custom-goto-match-beginning ()
  (when isearch-forward (goto-char isearch-other-end)))
(defadvice isearch-exit (after custom-goto-match-beginning activate)
  "Go to beginning of match."
  (when isearch-forward (goto-char isearch-other-end)))

;; ibuffer: load a filter group by default
(add-hook 'ibuffer-mode-hook
          (lambda ()
            (ibuffer-switch-to-saved-filter-groups "default")))

;; number of lines maintained in the message log buffer (i.e. *Messages*)
(setq message-log-max 1000)



;;
;; **********************************************************************
;; **                                                                  **
;; ** Keyboard & mouse setup                                           **
;; **                                                                  **
;; **********************************************************************
;;


(global-set-key [f1] 'man)
(if have-woman
    (if (or (equal window-system 'win32)
            (equal window-system 'w32))
        (global-set-key [f1] 'woman)
      )
  )

(global-set-key (kbd "<s-f1>") '(lambda() (interactive) (message (concat (format-time-string "%c" (current-time))))))

(if have-bm (global-set-key (kbd "<s-f2>") 'bm-toggle))
(if have-bm (global-set-key (kbd "<f2>")   'bm-next))
(if have-bm (global-set-key (kbd "<S-f2>") 'bm-previous))

(global-set-key [f3] 'custom-make)
(global-set-key (kbd "<s-f3>") 'generalized-shell-command)
(global-set-key [(shift f3)] '(lambda() (interactive) (kill-buffer (current-buffer))))

(global-set-key [f4] 'magic-key)
(global-set-key [(shift f4)] 'kill-buffer-del-frame)

(if have-fold-dwim (global-set-key (kbd "<s-f5>") 'fold-dwim-toggle))
(global-set-key [(shift f5)] 'custom-debug)
(global-set-key [f5] 'compile)

(global-set-key [f6] 'ibuffer)
(global-set-key [(shift f6)] 'ping)
(global-set-key [M-f6] 'recompile)
;;(global-set-key (kbd "<s-f6>") 'semantic-tag-folding-fold-all)

(global-set-key [f7] 'grep)
(global-set-key [M-f7] 'highlight-changes-mode)
(global-set-key [(shift f7)] 'ifconfig)
;;(global-set-key (kbd "<s-f7>") 'semantic-tag-folding-show-all)

(global-set-key [f8] 'custom-term)
(global-set-key [M-f8] 'global-linum-mode)
(global-set-key [(shift f8)] 'proced)

(if have-gnuplot (global-set-key [(M-f9)] 'gnuplot-make-buffer))
(global-set-key [(shift f9)] 'custom-make-install-run)
(global-set-key [f9] 'speedbar-get-focus)
(global-set-key (kbd "s-<f9>") 'dired-jump)

(add-hook 'c-mode-common-hook (lambda() (local-set-key  (kbd "<f10>") 'ff-get-other-file)))
(global-set-key [M-f10] '(lambda() (interactive) (find-file (concat (getenv "SOURCE") "/srcdb.txt"))))
(global-set-key [(shift f10)] 'todo-show)
(global-set-key (kbd "s-<f10>") 'start-kbd-macro)

(global-set-key [M-f11] 'sys-vars)
(global-set-key (kbd "<f11>")  'full-screen-toggle)
(global-set-key [(shift f11)] 'theme-next)
(global-set-key (kbd "s-<f11>") 'end-kbd-macro)

(global-set-key [f12] 'custom-make-frame)
(global-set-key (kbd "s-<f12>") 'call-last-kbd-macro)

(global-set-key [?\C-c ?2] 'swap-windows)
(global-set-key [?\C-c ?3] 'toggle-window-split)
(global-set-key [?\C-c ?'] 'markerpen-clear-region)
(if have-tabbar (global-set-key [?\C-c ?a] 'tabbar-mode))
(global-set-key [?\C-c ?b] 'backup-file)
(global-set-key [?\C-c ?c] 'custom-calc)
(global-set-key [?\C-c ?d] 'devhelp-word-at-point)
(if have-shell-toggle (global-set-key [?\C-c ?e] 'shell-toggle-cd))
(if have-tramp (global-set-key [?\C-c ?f] 'find-file-root))
(if have-goto-last-change (global-set-key [?\C-c ?g] 'goto-last-change))
(global-set-key [?\C-c ?h] 'highlight-regexp)
(global-set-key [?\C-c ?i] 'pretty-code)
(global-set-key [?\C-c ?j] 'setup-cc-mode)
(global-set-key [?\C-c ?k] 'linux-c-mode)
(global-set-key [?\C-c ?l] 'build)
(global-set-key [?\C-c ?m] 'switch-to-messages)
(global-set-key [?\C-c ?n] 'isearch-forward-at-point)
(global-set-key [?\C-c ?o] 'occur)
(global-set-key [?\C-c ?p] 'protect-buffer-from-kill-mode)
(global-set-key [?\C-c ?q] 'git-gui-blame)

(if have-recentf-buffer (global-set-key [?\C-c ?r ?f] 'recentf-open-files-in-simply-buffer))
(global-set-key [?\C-c ?r ?m] 'make-needs)
(global-set-key [?\C-c ?r ?o] 'toggle-selective-display)
(global-set-key [?\C-c ?r ?r] 'raise-frame)
(global-set-key [?\C-c ?r ?t] '(lambda() (interactive) (search-forward ">>>")))

(global-set-key [?\C-c ?s] 'switch-to-scratch)
(global-set-key [?\C-c ?t] 'time-stamp)
(global-set-key [?\C-c ?u] 'custom-command)
(global-set-key [?\C-c ?v] 'git-diff)
(global-set-key [?\C-c ?w] 'show-file)
(global-set-key [?\C-c ?x] 'custom-term)
(global-set-key [?\C-c ?y] 'edit-timesheet)
(global-set-key [?\C-c ?z] 'balance-windows)

(global-set-key "\C-x\C-f" 'find-file-read-only)
(global-set-key "\C-x\C-k" 'kill-this-buffer)
(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-x\C-r" 'find-file)
(global-set-key "\C-x\C-s" 'my-save-buffers)

(global-set-key (kbd "s-0") '(lambda() (interactive) (insert-file "~/.emacs_quick_templates/0")))
(global-set-key (kbd "s-1") '(lambda() (interactive) (insert-file "~/.emacs_quick_templates/1")))
(global-set-key (kbd "s-2") '(lambda() (interactive) (insert-file "~/.emacs_quick_templates/2")))
(global-set-key (kbd "s-3") '(lambda() (interactive) (insert-file "~/.emacs_quick_templates/3")))
(global-set-key (kbd "s-4") '(lambda() (interactive) (insert-file "~/.emacs_quick_templates/4")))
(global-set-key (kbd "s-5") '(lambda() (interactive) (insert-file "~/.emacs_quick_templates/5")))
(global-set-key (kbd "s-6") '(lambda() (interactive) (insert-file "~/.emacs_quick_templates/6")))
(global-set-key (kbd "s-7") '(lambda() (interactive) (insert-file "~/.emacs_quick_templates/7")))
(global-set-key (kbd "s-8") '(lambda() (interactive) (insert-file "~/.emacs_quick_templates/8")))
(global-set-key (kbd "s-9") '(lambda() (interactive) (insert-file "~/.emacs_quick_templates/9")))

(if have-acme-search (global-set-key [(mouse-3)] 'acme-search-forward))
(if have-acme-search (global-set-key [(shift mouse-3)] 'acme-search-backward))

(if have-mouse-copy (global-set-key [s-down-mouse-1] 'mouse-drag-secondary-pasting))
(if have-mouse-copy (global-set-key [C-s-down-mouse-1] 'mouse-drag-secondary-moving))

(if have-mouse-drag (global-set-key [down-mouse-2] 'mouse-drag-drag))

(global-set-key [mouse-4] 'down-slightly)
(global-set-key [mouse-5] 'up-slightly)
(global-set-key [S-mouse-4] 'down-one)
(global-set-key [S-mouse-5] 'up-one)
;;(global-set-key [C-mouse-4] 'down-a-lot)
;;(global-set-key [C-mouse-5] 'up-a-lot)

(global-set-key "\C-m" 'newline-and-indent) ;; auto-indent on a newline
(global-set-key "\C-o" 'ro-all)
(global-set-key "\C-t" 'duplicate-line)
(global-set-key (kbd "C-w") 'unix-werase-or-kill)

(if (and have-cyclebuffer window-system) (global-set-key "\M-]" `cyclebuffer-forward))
(if (and have-cyclebuffer window-system) (global-set-key "\M-[" `cyclebuffer-backward))

(if have-move-text (global-set-key (kbd "M-<left>") 'move-text-up))
(if have-move-text (global-set-key (kbd "M-<right>") 'move-text-down))

(global-set-key [M-up] 'up-one)
(global-set-key [M-down] 'down-one)

(global-set-key "\M-o" 'toggle-read-only)
(global-set-key "\M-p" 'repeat-complex-command)
(global-set-key "\M-s" 'grep)

;; M-y : browse-kill-ring
(if have-browse-kill-ring (browse-kill-ring-default-keybindings))

(global-set-key (kbd "<s-SPC>") 'pop-to-mark-command)
(global-set-key (kbd "s-.") 'super-find-tag)
(global-set-key (kbd "s-`") 'kio-find-file)

(global-set-key (kbd "s-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "s-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "s-<down>") 'shrink-window)
(global-set-key (kbd "s-<up>") 'enlarge-window)

(if have-toggle-option (global-set-key (kbd "s-p") 'toggle-option))

(if have-home-end (global-set-key [end]  'home-end-end))
(if have-home-end (global-set-key [home] 'home-end-home))

(if have-pager (global-set-key "\C-v" 'pager-page-down))
(if have-pager (global-set-key [next] 'pager-page-down))
(if have-pager (global-set-key "\ev" 'pager-page-up))
(if have-pager (global-set-key [prior] 'pager-page-up))
(if have-pager (global-set-key '[M-kp-8] 'pager-row-up))
(if have-pager (global-set-key '[M-kp-2] 'pager-row-down))

;; shift-left : windmove-left
;; shift-right : windmove-right
;; shift-up : windmove-up
;; shift-down : windmove-down
(windmove-default-keybindings)

(define-key global-map "%" `vi-type-paren-match)

;; the delete keys deletes under the cursor and to the right
(global-set-key [delete] 'delete-char)
(global-set-key [kp-delete] 'delete-char)

(global-set-key (kbd "C-S-f") 'full-screen-toggle)

;; cycle through buffers
(global-set-key [C-M-tab] 'bury-buffer)

;; cylce through frames
(global-set-key [C-M-S-iso-lefttab] 'next-multiframe-window)

(global-set-key [C-home] 'beginning-of-buffer)

(global-set-key [C-end] 'end-of-buffer)

(global-set-key "\C-\M-f" 'find-file-at-point)

(global-set-key [pause] 'toggle-read-only)

(global-set-key (kbd "C-+")      '(lambda nil (interactive) (text-scale-increase 1)))
(global-set-key [C-kp-add]       '(lambda nil (interactive) (text-scale-increase 1)))
(global-set-key (kbd "C--")      '(lambda nil (interactive) (text-scale-decrease 1)))
(global-set-key [C-kp-subtract]  '(lambda nil (interactive) (text-scale-decrease 1)))

;; while in i-search, hit C-o to run occur on the expression
(define-key isearch-mode-map (kbd "C-o")
  (lambda ()
    (interactive)
    (let ((case-fold-search isearch-case-fold-search))
      (occur (if isearch-regexp isearch-string
               (regexp-quote isearch-string))))))



;;
;; **********************************************************************
;; **                                                                  **
;; ** Modes for files                                                  **
;; **                                                                  **
;; **********************************************************************
;;

(setq auto-mode-alist (cons '("\\.cfg\\'" . shell-script-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.ini\\'" . shell-script-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("/tmp/kde-.*/kontact.*" . text-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("/tmp/kde-.*/kmail.*" . text-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("SConstruct" . python-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("SConscript" . python-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.pp\\'" . c++-mode) auto-mode-alist))


;;
;; **********************************************************************
;; **                                                                  **
;; ** Experimental                                                     **
;; **                                                                  **
;; **********************************************************************
;;

;; ;; just-in-time font lock
;;(condition-case () (require 'jit-lock) (error (message "upgrade emacs") (setq jit-lock-steath-time 1)))

;; this does not work
;;(condition-case () (add-hook 'server-switch-hook (function (lambda () (custom-color-theme-arjen)))) (error (message "Failed to set server hook")))

;; Load CEDET
;; uncomment to enable cedet
;;(load-file "/usr/local/src/cedet/cedet/common/cedet.el")

;; Enabling various SEMANTIC minor modes.  See semantic/INSTALL for more ideas.
;; Select one of the following:

;; * This enables the database and idle reparse engines
;;(semantic-load-enable-minimum-features)

;; * This enables some tools useful for coding, such as summary mode
;;   imenu support, and the semantic navigator
;;(semantic-load-enable-code-helpers)

;; * This enables even more coding tools such as the nascent intellisense mode
;;   decoration mode, and stickyfunc mode (plus regular code helpers)
;;(semantic-load-enable-guady-code-helpers)

;; * This turns on which-func support (Plus all other code helpers)
;; uncomment to enable cedet
;;(semantic-load-enable-excessive-code-helpers)

;; This turns on modes that aid in grammar writing and semantic tool
;; development.  It does not enable any other features such as code
;; helpers above.
;; (semantic-load-enable-semantic-debugging-helpers)

;; uncomment to enable cedet
;;(global-semantic-tag-folding-mode)

;; uncomment to enable cedet
;;(setq semanticdb-default-save-directory "~/.semanticdb")

;; (when (file-directory-p "/usr/local/src/ecb-2.32") (add-to-list 'load-path "/usr/local/src/ecb-2.32"))
;; (condition-case () (require 'ecb) (error (message "no package ecb") (setq have-ecb 'nil)))

;; flymake is nice... but it slows things down too much
;; (setq have-flymake t)
;; (condition-case () (require 'flymake) (error (message "no package flymake") (setq have-flymake 'nil)))
;; (if (equal have-flymake t) (add-hook 'find-file-hook 'flymake-find-file-hook))
;; (setq flymake-no-changes-timeout 36000)



(defun roll-v-3 ()
  "Rolling 3 window buffers clockwise"
  (interactive)
  (select-window (get-largest-window))
  (if (= 3 (length (window-list)))
      (let ((winList (window-list)))
        (let ((1stWin (car winList))
              (2ndWin (car (cdr winList)))
              (3rdWin (car (cdr (cdr winList)))))
          (let ((1stBuf (window-buffer 1stWin))
                (2ndBuf (window-buffer 2ndWin))
                (3rdBuf (window-buffer 3rdWin))
                )
            (set-window-buffer 1stWin 3rdBuf)
            (set-window-buffer 2ndWin 1stBuf)
            (set-window-buffer 3rdWin 2ndBuf)
            )
          )
        )
    )
  )

(defun split-window-4()
  "Splite window into 4 sub-window"
  (interactive)
  (progn (split-window-vertically)
         (split-window-horizontally)
         (other-window 2)
         (split-window-horizontally)))


(add-hook 'before-save-hook (lambda () (toggle-read-only 1)))
(add-hook 'after-save-hook (lambda () (toggle-read-only 1)))

;; make buffers read-only after 60 seconds of idle time
(run-with-idle-timer 60 t (lambda () (ro-all) (hcz-set-cursor-color-according-to-mode)))




;; (setq Man-notify-method 'aggressive)
(setq Man-notify-method 'newframe)
(setq Man-width 80)




;; (require 'framemove)
;; (setq framemove-hook-into-windmove t)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; KEEP LAST
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (if (locate-library "diminish")
;;     (progn
;;       (diminish 'abbrev-mode)
;;       (diminish 'auto-fill-function)
;;       (diminish 'highlight-parentheses-mode)
;;       (diminish 'light-symbol-mode)
;;       (diminish 'yas/minor-mode)
;;       )
;;   )

(devel)
(build-debug)
(switch-to-scratch)
(end-of-buffer)
(insert "\n")
(insert ";; C-x C-e to evaluate lisp\n")
(insert "\n")
(insert ";; Howto keep the compilation window from automatically going away:\n")
(insert "(setq compilation-finish-function nil)\n")
(insert "\n")
(insert ";; Edit account specific startup file::\n")
(insert "(find-file \"~/.local.el\")\n")
(insert "\n")

(setq custom-file "~/.elisp/custom.el")
(if (file-exists-p custom-file)
    (progn
      (byte-compile-if-newer "~/.elisp/custom")
      (load "~/.elisp/custom")
      )
  )

(if (file-exists-p "~/.local.el")
    (progn
      (byte-compile-if-newer "~/.local")      
      (load "~/.local")
      )
  )
(if (equal have-color-theme t) (theme-initialize))

;; This should be done last, or at least near to last... This allows settings
;; above to be applied to the buffers that the desktop package loads.  So for
;; example, settings for c/c++ mode will be in effect in the buffers loaded.
;;
;; From GNU Emacs 21.3.50 onwards, both the function desktop-load-default and
;; the variable desktop-enable are obsolete. These should be substituted with
;; a simple:
;; (desktop-save-mode 1)
;;
(if (locate-library "desktop")
    (progn

      (require 'desktop)

      (desktop-save-mode 1)

      ;;(condition-case () (desktop-load-default) (error (message "No desktop?!?")))
      (setq desktop-globals-to-save
            (append '(
                      command-history
                      extended-command-history
                      file-name-history
                      grep-history
                      minibuffer-history
                      query-replace-history
                      search-ring
                      )
                    desktop-globals-to-save))
      (add-to-list 'desktop-modes-not-to-save 'dired-mode)
      (add-to-list 'desktop-modes-not-to-save 'Info-mode)
      (add-to-list 'desktop-modes-not-to-save 'info-lookup-mode)

      ;;(setq desktop-enable t)
      )
  (message "package desktop not available")
  )

;; make all file buffers read-only
(ro-all)
(add-hook 'desktop-after-read-hook 'ro-all)

(message ".emacs_real.el loaded")
