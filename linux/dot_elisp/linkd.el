;;; linkd.el --- hypermedia wiki system for emacs

;;  _ _       _       _ 
;; | (_)_ __ | | ____| |
;; | | | '_ \| |/ / _` |
;; | | | | | |   < (_| |
;; |_|_|_| |_|_|\_\__,_|
;;                     
;; Copyright (C) 2007  David O'Toole

;; Author: David O'Toole <dto@gnu.org>
;; Additional code by Eduardo Ochs <eduardoochs@gmail.com>
;; Keywords: hypermedia
;; $Id: linkd.el,v 1.1 2008/02/06 02:11:44 jeremy Exp $

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;; This file is not part of GNU Emacs. 

;;; Commentary:

;; Linkd-mode is a hypertext system for organizing and interlinking
;; all resources available to GNU Emacs. 
;;
;; This is a preliminary alpha release. Some things are not
;; implemented and there are sure to be bugs. Please send feedback and
;; bug reports to me at dto@gnu.org
;; 
;; For now, the documentation is kept on the linkd home page:
;; 
;; http://dto.freeshell.org/notebook/Linkd.html
;;
;; You can download the icons from:
;;
;; http://dto.freeshell.org/packages/linkd-icons.tar.gz


;;; Code:


(require 'easy-mmode)


;; (@* "finding links")


(defvar linkd-generic-regexp (concat "\(" "@" "[^)]*\)"))


(defun linkd-link-at-point ()
  "Get the link around point and return it as a sexp, or nil if
not found."
  (if (get-char-property (point) 'linkd)
      (save-excursion
	(read (current-buffer)))))


(defun linkd-link-on-this-line ()
  "Get the rightmost link from the current line. Return the sexp, or nil if not found."
  (save-excursion
    (end-of-line)
    (backward-sexp)
    (linkd-link-at-point)))

    
;; (@* "following links")
  

(defun linkd-follow (sexp)
  "Follow the link represented by SEXP."
  (let* ((plist (eval sexp))
	 (follower (plist-get plist :follow)))
    (if follower
	(funcall follower)
      (error "No follow function for link %S" sexp))))
   

(defun linkd-follow-on-this-line ()
  "Follow the rightmost link on the current line."
  (interactive)
  (linkd-follow (linkd-link-on-this-line)))


(defun linkd-follow-at-point ()
  "Follow the link at point."
  (interactive)
  (linkd-follow (linkd-link-at-point)))


(defun linkd-follow-mouse (event)
  "Follow the clicked link."
  (interactive "e")
  (when event
    (let ((pos (posn-point (car (cdr event)))))
      (goto-char pos)
      (linkd-follow (linkd-link-at-point)))))


;; (@* "rendering links with overlays")


(defvar linkd-default-bullet-string ">>>")


(defun linkd-insert (string)
  (insert (substring-no-properties string)))


(defun linkd-overlay (beg end display-text &optional display-face bullet-text bullet-face bullet-icon)
  (let ((overlay (make-overlay beg end)))
    (overlay-put overlay 'display (propertize display-text 
					      'face (or display-face linkd-generic-name-face)))
    ;;
    ;; mark the overlay so that we can find it later
    ;; see also (@> "navigating links")
    ;;
    (overlay-put overlay 'linkd t)
    ;; 
    ;; add a bullet, if any
    (when bullet-text
      (let* ((face (if (and bullet-icon linkd-use-icons)
		       linkd-icon-face
		     bullet-face))
	     (b1 (if face
		     (propertize bullet-text 'face face)
		   bullet-text))
	     (b2 (if (and bullet-icon linkd-use-icons)
		     (propertize b1 'display `(image :file ,bullet-icon
						     :type xpm
						     :ascent center))
		   b1)))
	(overlay-put overlay 'before-string (concat b2 " "))))
    ;;
    (overlay-put overlay 'evaporate t)
    ;;
    ;; defontify if the user edits the text
    (overlay-put overlay 'modification-hooks 
		 (list (lambda (ov foo beg end &rest ignore)
			 (let ((inhibit-modification-hooks t))
			   (delete-overlay ov)
			   (remove-text-properties (point-at-bol) (point-at-eol)
						   (list 'linkd-fontified nil
							 'linkd nil))))))
    ;;
    ;; don't prevent re-fontifying when yanking
    (overlay-put overlay 'yank-handler 'linkd-insert)))

						      


(defvar linkd-use-icons nil "When non-nil, icons are displayed for links instead of text bullets.")


(defvar linkd-icons-directory "~/.linkd-icons" "Directory where linkd's icons are kept.")


(defun linkd-icon (icon-name)
  (concat (file-name-as-directory linkd-icons-directory) "linkd-" icon-name ".xpm"))


(defun linkd-file-icon (file-name)
  "Choose an appropriate icon for FILE-NAME based on the name or extension.
Returns the file-name to the icon image file."
  (let* ((dir (file-name-as-directory linkd-icons-directory))
	 (icon (concat dir "linkd-file-" (file-name-extension file-name) ".xpm")))
    (if (file-exists-p icon)
	icon
      (concat dir "linkd-file-generic.xpm"))))


;; (@* "navigating links")


(defun linkd-next-link ()
  (interactive)
  (forward-char 1)
  (let ((inhibit-point-motion-hooks nil))
    ;;
    ;; get out of the current overlay if needed
    (when (get-char-property (point) 'linkd)
      (while (and (not (eobp))
		  (get-char-property (point) 'linkd))
	(goto-char (min (next-overlay-change (point))
			(next-single-char-property-change (point) 'linkd)))))
    ;;
    ;; now find the next linkd overlay
    (while (and (not (eobp))
		(not (get-char-property (point) 'linkd)))
      (goto-char (min (next-overlay-change (point))
		      (next-single-char-property-change (point) 'linkd))))))


(defun linkd-previous-link ()
  (interactive)
  (let ((inhibit-point-motion-hooks nil))
    ;;
    ;; get out of the current overlay if needed
    (when (get-char-property (point) 'linkd)
      (while (and (not (bobp))
		  (get-char-property (point) 'linkd))
	(goto-char (max (previous-overlay-change (point))
			(previous-single-char-property-change (point) 'linkd)))))
    ;;
    ;; now find the previous linkd overlay
    (while (and (not (bobp))
		(not (get-char-property (point) 'linkd)))
      (goto-char (max (previous-overlay-change (point))
		      (previous-single-char-property-change (point) 'linkd))))))
  

;; (@* "inserting and editing links")


(defun linkd-insert-single-arg-link (type-string argument)
  (insert (if (not (string= "" argument))
	    (format (concat "(" "@%s %S)") type-string argument)
	    (format (concat "(" "@%s)") type-string))))


(defun linkd-insert-tag (tag-name)
  (interactive "sTag name: ")
  (linkd-insert-single-arg-link ">" tag-name)) 


(defun linkd-insert-star (star-name)
  (interactive "sStar name: ")
  (linkd-insert-single-arg-link "*" star-name)) 


(defun linkd-insert-wiki (wiki-name)
  (interactive "sWiki page: ")
  (linkd-insert-single-arg-link "!" wiki-name))


(defun linkd-insert-command (command-name)
  (interactive "sCommand name: ")
  (linkd-insert-single-arg-link "$" command-name))


(defvar linkd-insertion-schemes '(("file" :file-name :to :display)
				  ("man" :page :to :display)
				  ("info" :file-name:node :to :display)
				  ("url" :file-name :display)))


(defun linkd-insert-link (&optional type current-values)
  (interactive)
  (let* ((type (or type (completing-read "Link type: " linkd-insertion-schemes)))
	 (keys (cdr (assoc type linkd-insertion-schemes)))
	 (key (car keys))
	 (link-args nil))
    (while key
      ;;
      ;; read an argument value
      (let ((value (read-from-minibuffer (format "%S " key)
					 (plist-get current-values key))))
	(when (not (string= "" value))
	  (setq link-args (plist-put link-args key value))))
      ;;
      ;; next
      (setq keys (cdr keys))
      (setq key (car keys)))
    ;;
    ;; format and insert the link
    (insert (format (concat "(" "@%s %s)")
		    type
		    (mapconcat (lambda (sexp)
				 (format "%S" sexp))
			       link-args
			       " ")))))


(defun linkd-edit-link-at-point ()
  (interactive)
  (let ((link (linkd-link-at-point)))
    (when link
      (if (keywordp (car (cdr link)))
	  ;;
	  ;; it's a general link
	  (save-excursion	
	    (linkd-insert-link 
	     ;; drop the @ sign
	     (substring (format "%S" (car link)) 1)
	     (cdr link)))
	;;
	;; it's a single-arg link
	(let ((new-value (read-from-minibuffer "New value: " (car (cdr link)))))
	  (insert (format "%S" (list (car link) new-value)))))
      ;;
      ;; now erase old link
      (re-search-backward linkd-generic-regexp)
      (delete-region (match-beginning 0) (match-end 0)))))


;; (@* "file links")


(defvar linkd-file-handler-alist nil 
"Association list mapping file extensions to functions that open such files for the user.
Each value should be a function of one argument (the file name).")


(defun @file (&rest p)
  (let ((file-name (plist-get p :file-name))
	(to (plist-get p :to))
	(display (plist-get p :display)))
    `(:follow
      (lambda ()
	(let ((handler (cdr (assoc (file-name-extension ,file-name)
				   linkd-file-handler-alist))))
	  (if handler
	      (funcall handler ,file-name)
	    ;; default action is find-file
	    (find-file ,file-name)
	    (when ,to
	      (beginning-of-buffer)
	       (search-forward ,to)))))
      :render
      (lambda (beg end)
	(linkd-overlay beg end ,(or display 
				    (concat file-name (if to 
						     (concat " : " to)
						    "")))
		       nil linkd-default-bullet-string nil ,(linkd-file-icon file-name))))))


;; (@* "other link types")


(defun @man (&rest p)
  (let ((page (plist-get p :page))
	(to (plist-get p :to))
	(display (plist-get p :display)))
    `(:follow
      (lambda ()
	(man ,page)
	(when ,to
	  (beginning-of-buffer)
	  (search-forward ,to)))
      :render
      (lambda (beg end)
	(linkd-overlay beg end ,(or display 
				    (concat page " manual" (if to 
							       (concat " : " to)
							     "")))
		       nil linkd-default-bullet-string nil ,(linkd-icon "man"))))))


(defun @info (&rest p)
  (let ((file (plist-get p :file-name))
	(node (plist-get p :node))
	(to (plist-get p :to))
	(display (plist-get p :display)))
    `(:follow
      (lambda ()
	(info (concat "(" ,file ")" ,node)) 
	(when ,to
	  (beginning-of-buffer)
	  (search-forward ,to)))
      :render
      (lambda (beg end)
	(linkd-overlay beg end ,(or display 
				    (concat file " manual" (if to
							       (concat " : " to)
							     "")))
		       linkd-generic-name-face linkd-default-bullet-string nil ,(linkd-icon "info"))))))


(defun @url (&rest p)
  (let ((file-name (plist-get p :file-name))
	(display (plist-get p :display)))
    `(:follow
      (lambda ()
	(browse-url ,file-name))
      :render
      (lambda (beg end)
	(linkd-overlay beg end ,(or display file-name)
		       linkd-generic-name-face 
		       linkd-default-bullet-string nil ,(linkd-icon "url"))))))


;; (@* "commands")


(defun @$ (command-name)
  `(:follow
    (lambda ()
      (funcall ,(symbol-function (intern command-name))))
    :render
    (lambda (beg end)
      (linkd-overlay beg end ,(concat "(" command-name ")")
		     linkd-command-face
		     "M-x" nil ,(linkd-icon "command")))))



;; (@* "tags")
;; Following a tag link navigates to the next tag (or star) with the same name,
;; cycling to the beginning of the buffer when the end is reached. 


(defun linkd-find-next-tag-or-star (name)
  (let* ((regexp (concat "\(\@\\(\*\\|>\\) \"" name))
	 (found-position 
	  (save-excursion
	    (goto-char (point-at-eol))
	    (if (re-search-forward regexp nil t)
		(match-beginning 0)
	      ;;
	      ;; start over at the beginning of the buffer
	      (goto-char (point-min))
	      (when (re-search-forward regexp nil t)
		(match-beginning 0))))))
    (when found-position
      (goto-char found-position))))

  
(defun @> (tag-name)
  `(:follow
    (lambda ()
      (linkd-find-next-tag-or-star ,tag-name))
    :render
    (lambda (beg end)
      (linkd-overlay beg end ,tag-name linkd-tag-name-face
		     ">" linkd-tag-face ,(linkd-icon "tag")))))


;; (@* "stars")
;; Stars delimit (and optionally name) blocks of text. 


(defun @* (&optional star-name)
  `(:follow
    (lambda ()
      (linkd-find-next-tag-or-star ,star-name))
    :render
    (lambda (beg end)
      (linkd-overlay beg end 
		     ,(if star-name 
			 star-name
		       " ") ;; leave a space so that fontified link doesn't disappear
		     ',(if star-name
			   linkd-star-name-face
			 'default)
		     "*" linkd-star-face ,(linkd-icon "star")))))


;; (@* "wiki features")
;;


(defvar linkd-wiki-directory "~/linkd-wiki" "Default directory to look for wiki pages.")


(defun linkd-wiki-find-page (page-name)
  (interactive "s")
  (find-file (concat (file-name-as-directory linkd-wiki-directory)
		     page-name ".linkd")))


(defun @! (page) 
  `(:follow
    (lambda ()
      (linkd-wiki-find-page ,page))
    :render
    (lambda (beg end) 
      (linkd-overlay beg end ,page linkd-wiki-face))))

 
;; (@* "processing blocks")
;; Sending the text in a block to some lisp function or external
;; program for further processing


(defvar linkd-star-search-string (concat "\(" "\@\*"))


(defun linkd-block-around-point () 
  "Return the block around point as a string."
  (interactive)
  (let ((beg (save-excursion 
	       (search-backward linkd-star-search-string)
	       (beginning-of-line)
	       (point)))
	(end (save-excursion
	       (search-forward linkd-star-search-string)
	       (point))))
    (buffer-substring-no-properties beg end)))


(defvar linkd-block-file-name "~/.linkd-block" 
"File where temporary block text is stored for processing by
external programs.")


(defun linkd-write-block-to-file (block-text)
  "Write the BLOCK-TEXT to the file named by linkd-block-file-name."
  (interactive)
  (with-temp-buffer 
    (insert block-text)
    (write-file linkd-block-file-name)))


(defvar linkd-process-block-function nil 
"This function is called with the contents of the block around
point as a string whenever (linkd-process-block) is called. You
can set this in the Local Variables section of a file.")


(make-variable-buffer-local 'linkd-process-block-function)


(defun linkd-process-block ()
  (interactive)
  (funcall linkd-process-block-function (linkd-block-around-point)))
	       

(defvar linkd-shell-buffer-name "*linkd shell*")


;;
;; The following function is adapted from Eduardo Ochs's "eepitch.el"
;;

(defun linkd-send-block-to-shell (block-text)
  (interactive)
  (when (not (get-buffer-window linkd-shell-buffer-name))
    ;;
    ;; create shell if needed, but not in current window
    (save-window-excursion (shell linkd-shell-buffer-name))
    (display-buffer linkd-shell-buffer-name))
  ;;
  (linkd-write-block-to-file block-text)
  (save-selected-window
    (select-window (get-buffer-window linkd-shell-buffer-name))
    (end-of-buffer)
    ;;
    ;; make the shell source the temp file
    (insert (concat ". " linkd-block-file-name))
    (call-interactively (key-binding "\r"))))

   
;; (@* "linkd minor mode")


(defvar linkd-map nil)
;;(setq linkd-map nil)
(when (null linkd-map)
  (setq linkd-map (make-sparse-keymap))
  (define-key linkd-map (kbd "C-c .") 'linkd-follow-on-this-line)
  (define-key linkd-map (kbd "C-c *") 'linkd-process-block)
  (define-key linkd-map (kbd "C-c [") 'linkd-previous-link)
  (define-key linkd-map (kbd "C-c ]") 'linkd-next-link)
  (define-key linkd-map (kbd "C-c '") 'linkd-follow-at-point)
  (define-key linkd-map (kbd "C-c , ,") 'linkd-insert-link)
  (define-key linkd-map (kbd "C-c , t") 'linkd-insert-tag)
  (define-key linkd-map (kbd "C-c , s") 'linkd-insert-star)
  (define-key linkd-map (kbd "C-c , w") 'linkd-insert-wiki)
  (define-key linkd-map (kbd "C-c , c") 'linkd-insert-command)
  (define-key linkd-map (kbd "C-c , e") 'linkd-edit-link-at-point))
  

(define-minor-mode linkd-mode
  "Grand unified hyperlinker for emacs."
  nil 
  :lighter " Linkd"
  :keymap linkd-map
  (if linkd-mode
      (linkd-enable)
    (linkd-disable)))


(defun linkd-enable ()
  (linkd-do-font-lock 'font-lock-add-keywords)
  (font-lock-fontify-buffer))


(defun linkd-disable ()
  ;;
  ;; remove all linkd's overlays
  (mapcar (lambda (overlay)
	    (when (get-text-property (overlay-start overlay)
				     'linkd-fontified)
	      (delete-overlay overlay)))
	  (overlays-in (point-min) (point-max)))
  ;;
  ;; remove font-lock rules, textprops, and then refontify the buffer
  (linkd-do-font-lock 'font-lock-remove-keywords)
  (remove-text-properties (point-min) (point-max) '(linkd-fontified))
  (font-lock-fontify-buffer))


;; (@* "font locking")


(defun linkd-render-link (beg end)
  (when (not (get-text-property beg 'linkd-fontified))
    (save-excursion
      (goto-char beg)
      (add-text-properties beg (+ beg 1) (list 'linkd-fontified t))		  
      (let* ((sexp (read (current-buffer)))
	     (plist (eval sexp))
	     (renderer (plist-get plist :render)))
	(when (null renderer) (error "No renderer for link."))
	(funcall renderer beg end)))))


(defun linkd-do-font-lock (add-or-remove)
  (funcall add-or-remove nil 
	   `((,linkd-generic-regexp 
	      0
	      (let ((beg (match-beginning 0))
		    (end (match-end 0)))
		(linkd-render-link beg end)
		linkd-generic-face)
	      prepend))))		 	      

;; (@* "faces")


(defface linkd-generic-face '((t (:foreground "yellow")))
  "Face for linkd links.")

(defvar linkd-generic-face 'linkd-generic-face)


(defface linkd-generic-name-face '((t (:foreground "yellow")))
  "Face for linkd links.")


(defvar linkd-generic-name-face 'linkd-generic-name-face)


(defface linkd-star-face '((t (:foreground "yellow" :background "red" :underline nil)))
  "Face for star delimiters.")

(defvar linkd-star-face 'linkd-star-face)


(defface linkd-star-name-face '((t (:foreground "yellow" :background "red" :underline "yellow")))
  "Face for star names.")

(defvar linkd-star-name-face 'linkd-star-name-face)


(defface linkd-tag-face '((t (:foreground "yellow" :background "forestgreen")))
  "Face for tags.")

(defvar linkd-tag-face 'linkd-tag-face)

(defface linkd-tag-name-face '((t (:foreground "yellow" :background "blue" :underline "yellow")))
  "Face for tag names.")

(defvar linkd-tag-name-face 'linkd-tag-name-face)

(defface linkd-icon-face '((t (:underline nil)))
  "Face for icons.")

(defvar linkd-icon-face 'linkd-icon-face)

(defface linkd-wiki-face '((t (:foreground "cyan" :underline "yellow")))
  "Face for camel case wiki links.")

(defvar linkd-wiki-face 'linkd-wiki-face)

(defface linkd-command-face '((t (:foreground "red" :background "blue")))
  "Face for command links.")

(defvar linkd-command-face 'linkd-command-face)


;; (@* "version")


(defun linkd-version ()
  (interactive)
  (message "$Id: linkd.el,v 1.1 2008/02/06 02:11:44 jeremy Exp $"))


(provide 'linkd)
;;; linkd.el ends here
