;;; -*- lexical-binding: t; -*-
(setq-default tab-width 8)
(setq-default indent-tabs-mode nil)
(setq standard-indent 8)
(setq inhibit-startup-screen t)
(setq select-enable-clipboard t)
(setq select-enable-primary t)
(display-time-mode t)
(window-divider-mode t)
(electric-pair-mode 1)
(column-number-mode t)
(setq scroll-step 1)                ; 每次滚动 1 行
(setq scroll-conservatively 10000)
(setq scroll-margin 9)
(ido-mode t)
(load-theme 'wheatgrass t)

(defun my/capital-forward ()
  "Capitalize-Word before cursor."
  (interactive)
  (backward-word)
  (capitalize-word 1))

(define-minor-mode my-cj-mode
  "Force \\[keyboard-quit] to be \\<ctl-x-map>\\[ctl-x-map] map."
  :global t
  :type 'boolean
  :group 'my-config
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-j")     ctl-x-map)
	    (define-key map (kbd "C-c C-d") #'backward-kill-word)
	    (define-key map (kbd "C-c d")   #'kill-word)
	    (define-key map (kbd "M-e")     #'mark-word)
            map))

(my-cj-mode 1)
(require 'dired)

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c C-e") 'wdired-change-to-wdired-mode))

(define-prefix-command 'my/w-prefix)
(global-set-key (kbd "C-c w") 'my/w-prefix)
(global-set-key (kbd "C-c w t") #'split-window-below)
(global-set-key (kbd "C-c w v") #'split-window-right)
(global-set-key (kbd "C-c w d") #'kill-buffer-and-window)
(global-set-key (kbd "C-c w x") #'delete-window)
(global-set-key (kbd "C-c w f") #'delete-other-windows)
(global-set-key (kbd "C-c w b") #'balance-windows)
(global-set-key (kbd "C-c w m") #'maximize-window)
(global-set-key (kbd "C-c w ,") #'minimize-window)
(global-set-key (kbd "C-c w o") #'other-window)

(global-set-key (kbd "C-.")          #'duplicate-line)
(global-set-key (kbd "s-s")          #'save-buffer)
(global-set-key (kbd "s-d")          #'backward-delete-char)
(global-set-key (kbd "s-f")          #'ido-find-file)
(global-set-key (kbd "C-<tab>")      #'other-window)
(global-set-key (kbd "M-\"")         #'shell-command)
(global-set-key (kbd "C-M-f")        #'up-list)

(global-set-key (kbd "C-x C-a")      #'replace-regexp)
(global-set-key (kbd "C-x c")        #'compile)
(global-set-key (kbd "C-x C-q")      #'kill-emacs)

(global-set-key (kbd "C-c z")        #'zap-to-char)
(global-set-key (kbd "C-c c")        #'my/capital-forward)
(global-set-key (kbd "C-c r")        #'rgrep)
(global-set-key (kbd "C-c e")        #'eshell)
(global-set-key (kbd "C-c D")        #'kill-whole-line)
(global-set-key (kbd "C-c i")        #'indent-region)
