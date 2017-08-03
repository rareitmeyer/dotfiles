;; .emacs file

;; Copyright 2001-2017 R. A. Reitmeyer

;; remove trailing whitespace on file save
(defadvice save-buffer (before delete-training-whitespace-on-save)
  "remove training whitespace on file save"
  (progn (delete-trailing-whitespace (point-min) (point-max))))
(ad-activate 'save-buffer)

;; utility function
(defun rar-stripped-shell-command-to-string (command)
    "Execute shell command, and strip off the very last newline"
    (substring (shell-command-to-string command) 0 -1))

;; Only tabify at start of line.
(setq tabify-regexp "^[ \\t]+")




;; make meta-G run goto-line.
(global-set-key "\M-g" 'goto-line)

;; Ditch upcase / downcase as too easy to type by accident
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;; Make delete just delete the last character, dammit.
;; (Emacs 20.3 and above, by default, turns tabs into spaces and
;; deletes the last space.)
(add-hook 'c-mode-hook (lambda ()
			 (setq backward-delete-char-untabify-method nil)) t)

;; Turn off the tool-bar added to UNIX emacs 21.1; supply
;; a negative argument to tool-bar-mode to get rid of it.
(if (> emacs-major-version '20)
    (tool-bar-mode '-1))


;; Start trying to tweak for my C style.
(if (> emacs-major-version '19)
    (progn (c-add-style "rar" '("k&r"
				(c-basic-offset . 4)
				(c-offsets-alist
				 (string 0)
				 (func-decl-cont +)
				 (arglist-cont +)
				 (arglist-cont-nonempty +))))
	   (setq c-default-style '((c-mode . "rar") (c++-mode . "rar")))))




;; Turn on the emacs 21.1 variable show-trailing-whitespace
;; (This is ignored in versions prior to 21.1)
(add-hook 'find-file-hook (lambda ()
	    (setq show-trailing-whitespace t)) t)

;; should consider turning on emacs 21.1 feature
;; hl-line-mode in buffers, or global-hl-line-mode.

;;;; Try to display window size when windows are resized
(defvar rar-report-window-size-assoc nil
  "This is an assoc of windows and overlays in the window")

(defvar rar-report-window-size-cleanup-handle nil
  "This is a holder for the timer handle for the cleanup function,
if one is scheduled.  Use it to try to minimize (although not totally
avoid) race conditions.")

(defun rar-report-window-size-cleanup ()
  "Removes all overlays in rar-report-window-size-assoc."
  (interactive)
  (let (window-sizes-assoc w-overlay)
    (while rar-report-window-size-assoc
      (setq window-sizes-assoc (car rar-report-window-size-assoc))
      (setq rar-report-window-size-assoc (cdr rar-report-window-size-assoc))
      (setq w-overlay (cadr window-sizes-assoc))
      (delete-overlay w-overlay))))

(defun rar-report-window-size-hook (&optional f)
  "Prints window size in the top-left corner of each window.
This is intended as a hook to be added to the variable
`window-size-change-functions.'

Overlays exist for 3 seconds after window resize, when they're
automatically removed by rar-report-window-size-cleanup()."
  (interactive)
  (if (or (null f) (interactive-p)) (setq f (selected-frame)))
  (let (w first-w w-count s debug-s window-sizes-assoc w-overlay)
    (setq w (frame-first-window f))
    (setq first-w w)
    (setq w-count 0)
    (cond ((null w) (message "error: no windows in frame!"))
	  (t (progn
	       (while
		   (progn
		     (setq s (format "(%2d x %2d) "
				     (window-height w)
				     (window-width w)))
		     (setq debug-s (concat debug-s (format "{%s %dx%d} "
							   (buffer-name (window-buffer w))
							   (window-height w)
							   (window-width w))))
		     (setq window-sizes-assoc
			   (assoc w rar-report-window-size-assoc))
		     (cond ((null window-sizes-assoc)
			    (setq w-overlay (make-overlay (window-start w)
							  (window-start w)
							  (window-buffer w) t t))
			    (overlay-put w-overlay 'window w)
					; make overlay window-specific
			    (setq rar-report-window-size-assoc
				  (cons (list w w-overlay)
					rar-report-window-size-assoc)))
			   (t (setq w-overlay (cadr window-sizes-assoc))))
		     (overlay-put w-overlay 'after-string s)
		     (setq w (next-window w "never-see-minbuffer"
					  "this-frame-only"))
		     (setq w-count (1+ w-count))
		     (not (equal w first-w))))
	       (if rar-report-window-size-cleanup-handle
		   (progn (cancel-timer rar-report-window-size-cleanup-handle)
			  (setq rar-report-window-size-cleanup-handle nil)))
	       (setq rar-report-window-size-cleanup-handle
		     (run-at-time "3 sec" nil
				  'rar-report-window-size-cleanup)))))))
(add-hook 'window-size-change-functions 'rar-report-window-size-hook)

;; general shell stuff.
(setq comint-scroll-show-maximum-output t)
(setq comint-scroll-to-bottom-on-input t)
(setq comint-scroll-to-bottom-on-output "all")
(setq shell-pushd-regexp "pd")
(setq shell-popd-regexp "bd")


;; Fix some X-windows key binding problems: the key marked [DEL]
;; should be different from the key marked [backspace]
(if (not (string= system-type "windows-nt"))
    (progn (define-key function-key-map [delete] nil)
	   (global-set-key [delete] `delete-char)))



;; Add .py as Python mode.  Note that python mode 4.6.
;;(if (or (> emacs-major-version '20)
;;	(and (= emacs-major-version '20) (> emacs-minor-version '7)))
;;    (progn
;;      (setq auto-mode-alist
;;	    (cons '("\\.py$" . python-mode) auto-mode-alist))
;;      (setq interpreter-mode-alist
;;	    (cons '("python" . python-mode)
;;		  interpreter-mode-alist))
;;      (autoload 'python-mode "python-mode" "Python editing mode." t)))

;; Set up .ts as signifying a Qt translation file, in UTF-8.
;;
(modify-coding-system-alist 'file "\\.ts\\'" 'utf-8)
;;  Don't run thin generally: (setq inhibit-iso-escape-detection t)

;; make DOS line ending obvious.
(setq inhibit-eol-conversion t)

;;(set-default-font "-*-Arial Unicode MS-normal-r-*-*-12-*-*-*-c-*-c-utf-8")
;;(set-default-font   "-*-Lucida Console-normal-r-*-*-12-*-*-*-c-*-c-iso8859-1")

(add-hook 'python-mode-hook
	  (lambda ()
	    (setq tab-width 8) ; it's a standard, dammit
	    ;(setq py-indent-offset 8) ; *&#$^!
	    (setq indent-tabs-mode nil) ; don't use tabs

	    ;; The following advice will have Emacs run tabify before
	    ;; saving any Python buffer.  The advice will be called
	    ;; on every file save (once you've loaded a Python file),
	    ;; so the first thing to do is to confirm that we want to
	    ;; do anything at all.
	    ;(defadvice save-buffer (before python-tab-fixup)
	    ;  "screw with indentation before saving python files"
	    ;  (progn (if (string-match ".*\\.py$" (buffer-file-name))
	    ;		 (let ((tabify-regexp "^[ \\t]+")) ; only tabify BOL!
	    ;		   ; Write out message to *Messages* to enablle
	    ;		   ; a posteri finger-pointing.
	    ;		   (print (list "running tabify on python file"
	    ;				(buffer-file-name)
	    ;				" with tabify-regexp of "
	    ;				tabify-regexp))
	    ;		   ; Actually do the tabify, for the whole buffer
	    ;		   (tabify (point-min) (point-max))))))
	    ;; turn on advice
	    ;(ad-activate 'save-buffer)
	    (setq backward-delete-char-untabify-method nil)) t)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t)
 '(matlab-fill-code nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;; Org mode
(setq org-log-done 'time)
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)
(setq org-catch-invisible-edits "error")
