(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(when (< emacs-major-version 24)
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)


;;------------------------------------------
;;插件添加
;;-----------------------------------------
;;自动补全
(add-to-list 'load-path "~/.emacs.d/plugins/auto-complete/")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories 
         "~/.emacs.d/plugins/auto-complete/dict/")
(ac-config-default)
 
;;添加一些定义
(add-to-list 'load-path "~/.emacs.d/plugins/yasnippet")
(require 'yasnippet)
(yas/global-mode 1)
;;------------------------------------------
;;插件添加结束

(add-to-list 'load-path "~/.emacs.d/plugins/exec-path-from-shell")
(require 'exec-path-from-shell)
;; Use C-tab to autocomplete the files and directories
;; based on the two commands `comint-dynamic-complete-filename`
;; and `comint-dynamic-list-filename-completions`

(defun atfd ()
  (interactive)
  (comint-dynamic-list-filename-completions)
  (comint-dynamic-complete-as-filename))

(global-set-key ( kbd "\C-c k" ) 'atfd)

(setq compile-command "scons -j8")
(setq compilation-scroll-output t)

(require 'ido)
(ido-mode t)


(require 'eshell)

(defun eshell-load-bash-aliases ()
       "Reads bash aliases from Bash and inserts
them into the list of eshell aliases."
       (interactive)
       (progn
               (message "Parsing aliases")
               (shell-command "alias" "bash-aliases" "bash-errors")
               (switch-to-buffer "bash-aliases")
               (replace-string "alias " "")
               (goto-char 1)
               (replace-string "='" " ")
               (goto-char 1)
               (replace-string "'\n" "\n")
               (goto-char 1)
               (let ((alias-name) (command-string) (alias-list))
                    (while (not (eobp))
                       (while (not (char-equal (char-after) 32))
                              (forward-char 1))
                           (setq alias-name
                                   (buffer-substring-no-properties (line-beginning-position) (point)))
                           (forward-char 1)
                           (setq command-string 
                                   (buffer-substring-no-properties (point) (line-end-position)))
                           (setq alias-list (cons (list alias-name command-string) alias-list))
                           (forward-line 1))
                    (setq eshell-command-aliases-list alias-list))
           (if (get-buffer "bash-aliases")(kill-buffer "bash-aliases"))
           (if (get-buffer "bash-errors")(kill-buffer "bash-errors"))))

;;(add-hook 'c-mode-common-hook
;;  (lambda() 
;;    (local-set-key  (kbd "C-x t") 'ff-find-other-file)))

(defun dts-switch-between-header-and-source ()
  "Switch between a c/c++ header (.h) and its corresponding source (.c/.cpp)."
  (interactive)
  ;; grab the base of the current buffer's file name
  (setq bse (file-name-sans-extension buffer-file-name))
  ;; and the extension, converted to lowercase so we can
  ;; compare it to "h", "c", "cpp", etc
  (setq ext (downcase (file-name-extension buffer-file-name)))
  ;; This is like a c/c++ switch statement, except that the
  ;; conditions can be any true/false evaluated statement
  (cond
   ;; first condition - the extension is "h"
   ((equal ext "h")
    ;; first, look for bse.c 
    (setq nfn (concat bse ".c"))
    (if (file-exists-p nfn)
        ;; if it exists, either switch to an already-open
        ;;  buffer containing that file, or open it in a new buffer
        (find-file nfn)
      ;; this is the "else" part - note that if it is more than
      ;;  one line, it needs to be wrapped in a (progn )
      (progn
        ;; look for a bse.cpp
        (setq nfn (concat bse ".cpp"))
        ;; likewise 
        (find-file nfn)
        )
      )
    )
   ;; second condition - the extension is "c" or "cpp"
   ((or (equal ext "cpp") (equal ext "c"))
    ;; look for a corresponding bse.h
    (setq nfn (concat bse ".h"))
    (find-file nfn)
    )
   )
  )
(global-set-key (kbd "C-x t") 'dts-switch-between-header-and-source)
(setq c-basic-offset 4)
