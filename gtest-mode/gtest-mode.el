(defgroup gtest nil
  "gtest group"	
  :group 'tools)


(defcustom gtest-target "iltest/testil/testil"
  "gtest target"
  :group 'tools'
  :type 'string)

(defun gtest-list ()
  "List all the tests"
  (interactive)
  (shell-command (concat gtest-target " --gtest_list_tests" "&")))

(defun gtest-run(filter)
  "Run gtest as per filter"
  (interactive "sFilter: ")
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
  
(defun test-parse-test ()
  (interactive)
  (message "%s" (parse-test)))

(defun search-test-at-point-in-source-file ()
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
	    