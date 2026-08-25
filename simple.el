;;; -*- lexical-binding: t; -*-
(setq-default tab-width 8)
(setq-default indent-tabs-mode nil)
(setq standard-indent 8)
(setq inhibit-startup-screen t)
(setq select-enable-clipboard t)
(setq select-enable-primary t)
(window-divider-mode t)
(electric-pair-mode 1)
(column-number-mode t)
(setq scroll-step 1)                ; 每次滚动 1 行
(setq scroll-conservatively 10000)
(setq scroll-margin 9)
(ido-mode t)
(fido-mode 1)
(load-theme 'wheatgrass t)
(setq auto-save-default t)
(setq auto-save-timeout 5)
(setq auto-save-interval 50)
(setq dired-listing-switches "-alhn")
(global-display-line-numbers-mode t)
(setq gc-cons-threshold (* 16 1024 1024))
(setq read-process-output-max (* 3 1024 1024))
(defun my/create-non-existent-directories ()
  (let ((parent (file-name-directory buffer-file-name)))
    (when (and parent (not (file-exists-p parent)))
      (make-directory parent t))))

(use-package which-key
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.5)
  (setq which-key-side-window-location 'bottom)
  (setq which-key-max-description-length 40)
  (setq which-key-max-display-columns nil))

(require 'time)
(setq display-time-format "󰥔 %d %H:%M")
(setq display-time-default-load-average nil)
(display-time-mode t)

(require 'battery)
(setq battery-mode-line-format nil)
(defun dynamic-battery-show ()
  "Dynamically show battery status."
  (if (not (fboundp battery-status-function))
      "foo"
    (let* ((bat-status (funcall battery-status-function))
           (online (string-equal (cdr (assoc 76 bat-status)) "on-line"))
           (color (if online "#30c97b" "#F54927"))
           (bat-str (if (string-equal (cdr (assoc 66 bat-status)) "charging")
                        (battery-format "󰂄%p" bat-status)
                        (battery-format "󰁹%p" bat-status))))
      (propertize bat-str 'face `(:weight bold :foreground ,color)))))
(display-battery-mode 1)
(setq-default mode-line-format
              '("%e" mode-line-front-space
               (:propertize (""
                             mode-line-mule-info
                             mode-line-client
                             mode-line-modified
                             mode-line-remote
                             mode-line-window-dedicated) display (min-width (6.0)))
               "  " mode-line-position
               mode-line-frame-identification
               mode-line-buffer-identification
               (project-mode-line project-mode-line-format)
               (vc-mode vc-mode)
               mode-line-format-right-align
               (:eval (dynamic-battery-show)) " "
               mode-line-modes
               mode-line-misc-info
               mode-line-end-spaces))

(dolist (hook '(eshell-mode-hook))
  (add-hook hook
            (lambda ()
              (setq-local mode-line-format nil))))

(use-package esh-mode
  :config
  (define-key eshell-mode-map (kbd "C-c e") (lambda () (interactive) (eshell t))))

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

(use-package dired
  :config (define-key dired-mode-map (kbd "C-c C-e") 'wdired-change-to-wdired-mode))

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

(global-set-key (kbd "C-.")     #'duplicate-line)
(global-set-key (kbd "s-s")     #'save-buffer)
(global-set-key (kbd "s-d")     #'backward-delete-char)
(global-set-key (kbd "s-f")     #'ido-find-file)
(global-set-key (kbd "C-<tab>") #'other-window)
(global-set-key (kbd "M-\"")    #'shell-command)
(global-set-key (kbd "C-M-f")   #'up-list)

(global-set-key (kbd "C-x C-a") #'replace-regexp)
(global-set-key (kbd "C-x c")   #'compile)
(global-set-key (kbd "C-x C-q") #'kill-emacs)

(global-set-key (kbd "C-c z")   #'zap-to-char)
(global-set-key (kbd "C-c c")   #'my/capital-forward)
(global-set-key (kbd "C-c r")   #'rgrep)
(global-set-key (kbd "C-c e")   #'eshell)
(global-set-key (kbd "C-c D")   #'kill-whole-line)
(global-set-key (kbd "C-c i")   #'indent-region)
