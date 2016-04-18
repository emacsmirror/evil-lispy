(require 'evil-lispy)
(require 'dash)
(require 'buttercup)
(require 's)
(require 'shut-up)

(defmacro with-test-buffer (contents &rest test-forms)
  "This awesome macro is adapted (borrowed) from
  https://github.com/abo-abo/lispy/blob/master/lispy-test.el#L15"
  (declare (indent 1))
  `(let ((temp-buffer (generate-new-buffer "evil-lispy-test-buffer")))
     (save-window-excursion
       (unwind-protect
           (shut-up
             (switch-to-buffer temp-buffer)
             (evil-mode)
             (evil-lispy-mode)
             (emacs-lisp-mode)

             (insert ,contents)

             (evil-goto-first-line)
             (when (search-forward "|")
               (backward-delete-char 1))

             ,@test-forms

             (let ((p (point))
                   (m (mark)))
               ;; show mark as well (other side of selection, if any)
               (goto-char p)
               (insert "|")

               ;; show mark as well (other side of selection, if any)
               (when mark-active
                 (goto-char (mark))
                 (insert "~")))

             (let ((result-lines (->> (buffer-substring-no-properties (point-min)
                                                                      (point-max))
                                      (s-split "\n"))))
               (if (= 1 (length result-lines))
                   (-first-item result-lines)
                 result-lines)))
         (when (buffer-name temp-buffer)
           (kill-buffer temp-buffer))))))

;; these are borrowed from omnisharp-emacs
;;
(defun ot--keyboard-input (&rest text-vectors)
  "Simulates typing. Can be used to do interactive input, but
detecting situations in the middle of input is impossible."
  (condition-case error
      (execute-kbd-macro (reduce 'vconcat text-vectors))
    (error (print (format "ot--keyboard-input error: %s" error)))))

(defun ot--meta-x-command (command)
  (vconcat
   (ot--press-key "M-x")
   (ot--type command)
   (ot--press-key "RET")))

(defun ot--type (text)
  (string-to-vector text))

(defun ot--press-key (key-or-chord)
  (edmacro-parse-keys key-or-chord))
