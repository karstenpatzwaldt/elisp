;;; gtest-mode.el --- google test runner

;; Author: Pralay Patoria <ppatoria@gmail.com> May 2016
;; keywords: gtest runner mode emacs
;; Commentary:

;; This minor mode provides following functionalities.
;; - List tests
;; - Run test interactively

(defgroup gtest nil
  "gtest group"
  :group 'tools)


(defcustom gtest-target ""
  "gtest target"
  :group 'tools'
  :type 'string)

(defvar gtest-current-target nil)
(defvar gtest-target-history nil)

(defun gtest-read-target-name ()
  "Read name of gtest executable to execute"
  (let ((file-name (read-file-name "gtest executable: " default-directory gtest-current-target)))
    (setq gtest-current-target file-name)
    file-name))

(defun gtest-list (test-target)
  "List all the tests"
  (interactive (list (gtest-read-target-name)))
  (shell-command (concat test-target " --gtest_list_tests" "&")))

(defun gtest-run-all (test-target)
  "run all the tests"
  (interactive (list (gtest-read-target-name)))
  (shell-command (concat test-target "&")))

(defun gtest-run (test-target filter)
  "Run gtest as per filter"
  (interactive (list
                (gtest-read-target-name)
                (read-string
                 (format "filter (%s): "
                         (concat "*" (thing-at-point 'symbol) "*"))
                             nil nil (concat"*" (thing-at-point 'symbol) "*"))))
  (shell-command (concat gtest-target " --gtest_filter=" filter "&")))

(defun is-line-at-point-is-test-hierarchy-or-fixture ()
  ""
  (interactive)
  (string-match "[.]" (thing-at-point 'line t)))

(defun is-c++-mode ()
  "check if its a c++ mode"
  (interactive)
  (eq 'c++-mode (buffer-local-value 'major-mode (current-buffer))))


(defun parse-test ()
  "parse the test from the source"
  (interactive)
  (setq test (thing-at-point 'line t))
  (when (string-match "TEST.*" test)
    (replace-regexp-in-string
     " "
     ""
     (replace-regexp-in-string
      ",[ ]*"
      "."
      (replace-regexp-in-string
       "[)]"
       ""
       (replace-regexp-in-string
        "TEST.*[(]"
        ""
        test))))))


(defun search-test-at-point-in-source-file ()
  "search test from the source"
  (interactive)
  (parse-test))


(defun search-test-at-point ()
  "search test at pointsearch test at point"
  (interactive)
  (if (is-c++-mode)
      (search-test-at-point-in-source-file)
    (setq test (thing-at-point 'symbol t))
    (if (is-line-at-point-is-test-hierarchy-or-fixture)
	(concat test "*")
      (re-search-backward "^[_[:alnum:]]+[.]")
      (setq test-hierarchy-or-fixture (thing-at-point 'symbol t))
      (concat test-hierarchy-or-fixture "." test))))

(defun gtest-run-at-point ()
  "run test at point"
  (interactive)
  (setq test (search-test-at-point))
  (push (regexp-quote test) regexp-history)
  (call-interactively(gtest-run test))
  )

(define-minor-mode gtest-mode
  "gtest runner"
  :lighter "gtest-mode"
  :keymap (let ((map (make-sparse-keymap)))
	    (define-key map (kbd "C-c l") 'gtest-list)
	    (define-key map (kbd "C-c t") 'gtest-run)
	    (define-key map (kbd "C-M-t") 'gtest-run)
	    map))
(provide 'gtest-mode)

