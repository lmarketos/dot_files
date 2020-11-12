
(provide 'syslog)

(defvar syslog-buffer "*syslog*" "syslog buffer")

(defun syslog ()
  "Run tail -f /var/log/messages and display the results."
  (interactive)
  (switch-to-buffer syslog-buffer)
  (erase-buffer)
  (let ((syslog-process (start-process "syslog" syslog-buffer "tail" "--retry" "--follow=name" "--lines=200" "/var/log/messages")))
    (set-process-sentinel syslog-process (function (lambda (process state)
						    (message "Process %s %s" process state))))
    (pop-to-buffer syslog-buffer)))

  
