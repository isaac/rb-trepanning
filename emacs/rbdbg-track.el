;;; rbdbg-track.el --- Tracking the Ruby debugger from a shell

;; -------------------------------------------------------------------
;; Variables.
;;

(eval-when-compile
  (defconst rbdbg-track-char-range 10000
    "Max number of characters from end of buffer to search for stack entry."))


;; -------------------------------------------------------------------
;; Dependencies.
;;

(require 'comint)
(require 'eshell)

(eval-when-compile
  (require 'cl)
  (setq load-path (cons nil (cons ".." load-path)))
  (load "rbdbg-loc")
  (load "rbdbg-lochist")
  (load "rbdbg-file")
  (load "rbdbg-var")
  (load "rbdbg-window")
  (load "rbdbgr-regexp")
  (setq load-path (cddr load-path)))
(require 'rbdbgr-regexp)

; FIXME: DRY CODE below!
(defun rbdbg-track-hist-newer()
  (interactive)
  (let* ((loc-hist (rbdbg-dbgr-loc-hist rbdbg-dbgr))
	 (cmd-window (selected-window))
	 (cmd-buff (current-buffer))
	 (position (rbdbg-loc-hist-newer loc-hist))
	 (loc (rbdbg-loc-hist-item loc-hist)))
    (rbdbg-loc-goto loc 'rbdbg-split-or-other-window)
    ; FIXME: DRY below code. See also comments elsewhere
    (set-buffer cmd-buff)
    (select-window cmd-window))
  )

(defun rbdbg-track-hist-newest()
  (interactive)
  (let* ((loc-hist (rbdbg-dbgr-loc-hist rbdbg-dbgr))
	 (cmd-window (selected-window))
	 (cmd-buff (current-buffer))
	 (position (rbdbg-loc-hist-newest loc-hist))
	 (loc (rbdbg-loc-hist-item loc-hist)))
    (rbdbg-loc-goto loc 'rbdbg-split-or-other-window)
    ; FIXME: DRY below code. See also comments elsewhere
    (set-buffer cmd-buff)
    (select-window cmd-window))
  )

(defun rbdbg-track-hist-older()
  (interactive)
  (let* ((loc-hist (rbdbg-dbgr-loc-hist rbdbg-dbgr))
	 (cmd-window (selected-window))
	 (cmd-buff (current-buffer))
	 (position (rbdbg-loc-hist-older loc-hist))
	 (loc (rbdbg-loc-hist-item loc-hist)))
    (rbdbg-loc-goto loc 'rbdbg-split-or-other-window)
    ; FIXME: DRY below code. See also comments elsewhere
    (set-buffer cmd-buff)
    (select-window cmd-window))
  )

(defun rbdbg-track-hist-oldest()
  (interactive)
  (let* ((loc-hist (rbdbg-dbgr-loc-hist rbdbg-dbgr))
	 (cmd-window (selected-window))
	 (cmd-buff (current-buffer))
	 (position (rbdbg-loc-hist-oldest loc-hist))
	 (loc (rbdbg-loc-hist-item loc-hist)))
    (rbdbg-loc-goto loc 'rbdbg-split-or-other-window)
    ; FIXME: DRY below code. See also comments elsewhere
    (set-buffer cmd-buff)
    (select-window cmd-window))
  )

(defun rbdbg-track-loc-action(loc cmd-buff cmd-window)
  "If loc is valid, show loc and do whatever actions we do for
encountering a new loc."
  (if (rbdbg-loc-p loc)
      (progn 
	(rbdbg-loc-goto loc 'rbdbg-split-or-other-window)
	; (rbdbg-loc-hist-add (rbdbg-dbgr-loc-hist rbdbg-dbgr) loc)
      )
    (message "%s" loc))

  ; We need to go back to the process/command buffer because other
  ; output-filter hooks run after this may assume they are in that
  ; buffer.
  (set-buffer cmd-buff)

  ; I like to stay on the debugger prompt rather than the found
  ; source location. Folks like Anders (who would like to totally
  ; get rid of the command line) no doubt feel differently about this.
  (select-window cmd-window))


(defun rbdbg-track-comint-output-filter-hook(text)
  "An output-filter hook custom for comint shells.  Find
location(s), if any, and run the action(s) associated with
finding a new location(s).  The parameter TEXT appears because it
is part of the comint-output-filter-functions API. Instead we use
marks set in buffer-local variables to extract text"

  ;; Instead of trying to piece things together from partial text
  ;; (which can be almost useless depending on Emacs version), we
  ;; monitor to the point where we have the next rbdbg prompt, and then
  ;; check all text from comint-last-input-end to process-mark.

  ; FIXME: Add unwind-protect? 
  (lexical-let* ((proc-buff (current-buffer))
		 (proc-window (selected-window))
		 (curr-proc (get-buffer-process proc-buff))
		 (last-output-end (process-mark curr-proc))
		 (last-output-start (max comint-last-input-end 
				   (- last-output-end rbdbg-track-char-range)))
		 (loc (rbdbg-track-from-region last-output-start 
					       last-output-end)))

    (rbdbg-track-loc-action loc proc-buff proc-window)))

(defun rbdbg-track-eshell-output-filter-hook()
  "An output-filter hook custom for eshell shells.  Find
location(s), if any, and run the action(s) associated with We use
marks set in buffer-local variables to extract text"

  ; FIXME: Add unwind-protect? 
  (lexical-let ((proc-buff (current-buffer))
		(proc-window (selected-window))
		(loc (rbdbg-track-from-region eshell-last-output-start 
					      eshell-last-output-end)))
    (rbdbg-track-loc-action loc proc-buff proc-window)))

(defun rbdbg-track-from-region(from to)
  (interactive "r")
  (if (> from to) (psetq to from from to))
  (rbdbg-track-loc (buffer-substring from to)))

; FIXME: move somewhere else? Or maybe a top-level tracking UI will
; be created in another file
(defun rbdbg-track-loc(text)
"We use `rbdbg-input-prompt-regexp' to find and parse the
location"
  ; FIXME rbdbgr-loc-regexp is for rbdbgr. Change to rbdbg-loc-regexp
  ; which will be generic and picked up from a buffer-local variable
  ; containing the "debugger" object.
  (if (string-match rbdbgr-loc-regexp text)
      (lexical-let* ((filename (match-string rbdbgr-loc-regexp-file-group text))
		     (lineno (string-to-number
			      (match-string rbdbgr-loc-regexp-line-group text))))
	(rbdbg-file-loc-from-line filename lineno))
    nil))
  

;; -------------------------------------------------------------------
;; The end.
;;

(provide 'rbdbg-track)

;;; Local variables:
;;; eval:(put 'rbdbg-debug-enter 'lisp-indent-hook 1)
;;; End:

;;; rbdbg-track.el ends here
