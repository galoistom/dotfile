;;; -*- lexical-binding: t; -*-
; this is a simple script that is aimed to be fast and portable on every machine with emacs isntalled,
; it should only require the basic package that emacs have, with no other dependency required
(setq-default tab-width 8)
(setq-default indent-tabs-mode nil)
(setq standard-indent 8)
(setq inhibit-startup-screen t)
(setq select-enable-clipboard t)
(setq select-enable-primary t)
(window-divider-mode t)
(electric-pair-mode 1)
(column-number-mode t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
;; (setopt completion-eager-display t) ; New in 31.1
;; (setopt completion-eager-update t) ; New in 31.1
;; (setopt minibuffer-visible-completions t)
;; (setopt completions-sort 'historical)
;(setopt completions-format 'one-column)
;; (setq scroll-step 1)                ; 每次滚动 1 行
;; (setq scroll-conservatively 10000)
;; (setq scroll-margin 9)
(ido-mode t)
(fido-mode 1)
;; 轻量 Dracula 风格：以内置 wombat 为底，只覆盖常用 face。
(load-theme 'wombat t)
(dolist (spec
         '((default :background "black" :foreground "#f8f8f2")
           (cursor :background "#f8f8f2")
           (fringe :background "black")
           (region :background "#44475a")
           (mode-line :background "#44475a" :foreground "#f8f8f2")
           (mode-line-inactive :background "black" :foreground "#6272a4")
           (window-divider :foreground "#44475a")
           (line-number :background "black" :foreground "#6272a4")
           (line-number-current-line :background "black" :foreground "#ff79c6")
           (minibuffer-prompt :foreground "#ff79c6")
           (isearch :background "#ff79c6" :foreground "#282a36")
           (lazy-highlight :background "#6272a4" :foreground "#f8f8f2")
           (font-lock-comment-face :foreground "#6272a4")
           (font-lock-keyword-face :foreground "#ff79c6")
           (font-lock-string-face :foreground "#f1fa8c")
           (font-lock-function-name-face :foreground "#50fa7b")
           (font-lock-type-face :foreground "#8be9fd")
           (font-lock-constant-face :foreground "#bd93f9")
           (font-lock-builtin-face :foreground "#8be9fd")))
  (apply #'set-face-attribute (car spec) nil (cdr spec)))
(set-background-color "black")
(setq auto-save-default t)
(setq auto-save-timeout 5)
(setq auto-save-interval 50)
(setq dired-listing-switches "-alhn")
(global-display-line-numbers-mode t)
(setq elisp-fontify-semantically t)
(setq gc-cons-threshold (* 16 1024 1024))
(setq read-process-output-max (* 3 1024 1024))
(defun my/create-non-existent-directories ()
  (let ((parent (file-name-directory buffer-file-name)))
    (when (and parent (not (file-exists-p parent)))
      (make-directory parent t))))

(when (and (not (display-graphic-p))
           (executable-find "wl-copy")
           (executable-find "wl-paste"))
  (setq interprogram-cut-function
        (lambda (text)
          (let ((process-connection-type nil))
            (let ((proc (start-process "wl-copy" nil "wl-copy")))
              (process-send-string proc text)
              (process-send-eof proc)))))

  (setq interprogram-paste-function
        (lambda ()
          (when (executable-find "wl-paste")
            (string-trim-right
             (shell-command-to-string "wl-paste -n"))))))


(use-package which-key
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.5)
  (setq which-key-side-window-location 'bottom)
  (setq which-key-max-description-length 40)
  (setq which-key-max-display-columns nil))

;; 基于缓冲区文本的轻量自动补全提示。
(require 'dabbrev)
(defun my/add-dabbrev-capf ()
  "Add dabbrev as a buffer-local completion source."
  (add-hook 'completion-at-point-functions #'dabbrev-capf nil t))
(add-hook 'prog-mode-hook #'my/add-dabbrev-capf)
(add-hook 'text-mode-hook #'my/add-dabbrev-capf)

;; 弹窗式补全（只依赖内置的 completion-preview 和 child frame）：
;; - 光标后的行内虚线预览由 completion-preview 提供
;; - 候选列表显示在光标下方的小弹窗中
;; - C-n/C-p 切换候选，C-e 接受，C-g 关闭
;; - 弹窗中选中的候选会同步成为光标后的虚线预览
(when (require 'completion-preview nil t)
  (setq completion-preview-message-format nil)

  (defface my-completion-popup
    '((t :background "#282a36" :foreground "#f8f8f2"))
    "Face for completion popup candidates."
    :group 'completion)

  (defface my-completion-popup-selected
    '((t :background "#44475a" :foreground "#f8f8f2" :weight bold))
    "Face for the selected completion popup candidate."
    :group 'completion)

  (defcustom my-completion-popup-max-rows 12
    "Maximum number of candidates shown in the completion popup."
    :type 'natnum
    :group 'completion)

  (defvar my-completion-popup--frame nil)
  (defvar my-completion-popup--buffer nil)
  (defvar my-completion-popup--content nil)

  (defconst my-completion-popup--frame-parameters
    '((visibility . nil)
      (width . 0) (height . 0)
      (no-accept-focus . t)
      (no-focus-on-map . t)
      (no-other-frame . t)
      (no-other-window . t)
      (no-delete-other-windows . t)
      (undecorated . t)
      (border-width . 0)
      (internal-border-width . 0)
      (child-frame-border-width . 0)
      (left-fringe . 0)
      (right-fringe . 0)
      (vertical-scroll-bars . nil)
      (horizontal-scroll-bars . nil)
      (menu-bar-lines . 0)
      (tool-bar-lines . 0)
      (tab-bar-lines . 0)
      (unsplittable . t)
      (cursor-type . nil)
      (no-special-glyphs . t)
      (desktop-dont-save . t)))

  (defun my-completion-popup--ensure-buffer ()
    "Return the buffer used by the completion popup."
    (unless (buffer-live-p my-completion-popup--buffer)
      (setq my-completion-popup--buffer
            (get-buffer-create " *my-completion-popup*")
            my-completion-popup--content nil)
      (with-current-buffer my-completion-popup--buffer
        (setq-local mode-line-format nil
                    header-line-format nil
                    tab-line-format nil
                    cursor-type nil
                    truncate-lines t
                    show-trailing-whitespace nil
                    display-line-numbers nil
                    left-fringe-width 0
                    right-fringe-width 0
                    left-margin-width 0
                    right-margin-width 0
                    fringes-outside-margins 0
                    buffer-undo-list t
                    buffer-read-only t)
        (use-local-map (make-sparse-keymap))))
    my-completion-popup--buffer)

  (defun my-completion-popup--ensure-frame ()
    "Return a live popup child frame for the selected frame."
    (let ((parent (selected-frame)))
      (unless (and (frame-live-p my-completion-popup--frame)
                   (eq (frame-parent my-completion-popup--frame) parent)
                   (eq (display-graphic-p parent)
                       (display-graphic-p my-completion-popup--frame))
                   (window-live-p (frame-root-window my-completion-popup--frame)))
        (when (frame-live-p my-completion-popup--frame)
          (delete-frame my-completion-popup--frame))
        (setq my-completion-popup--frame
              (let ((after-make-frame-functions nil)
                    (before-make-frame-hook nil)
                    (window-min-height 1)
                    (window-min-width 1))
                (make-frame
                 (append
                  `((parent-frame . ,parent)
                    (minibuffer . ,(minibuffer-window parent))
                    (name . " *my-completion-popup*")
                    (font . ,(frame-parameter parent 'font))
                    (background-color . "#282a36")
                    (foreground-color . "#f8f8f2"))
                  my-completion-popup--frame-parameters)))))
      (let ((win (frame-root-window my-completion-popup--frame)))
        (unless (eq (window-buffer win) (my-completion-popup--ensure-buffer))
          (set-window-buffer win (my-completion-popup--ensure-buffer)))
        (set-window-dedicated-p win t)
        (set-window-parameter win 'no-other-window t)
        (set-window-parameter win 'no-delete-other-windows t))
      (redirect-frame-focus my-completion-popup--frame parent)
      my-completion-popup--frame))

  (defun my-completion-popup--state ()
    "Return (BEG CANDIDATES INDEX) for the current completion preview."
    (when (and completion-preview-active-mode
               (overlayp completion-preview--overlay)
               (eq (overlay-buffer completion-preview--overlay)
                   (current-buffer)))
      (let* ((ov completion-preview--overlay)
             (beg (overlay-get ov 'completion-preview-beg))
             (base (or (overlay-get ov 'completion-preview-base) ""))
             (common (or (overlay-get ov 'completion-preview-common) ""))
             (suffixes (overlay-get ov 'completion-preview-suffixes))
             (index (or (overlay-get ov 'completion-preview-index) 0)))
        (when (and beg suffixes)
          (list beg
                (mapcar (lambda (suffix)
                          (replace-regexp-in-string
                           "[\n\r\t]" " "
                           (substring-no-properties
                            (concat base common suffix))))
                        suffixes)
                index)))))

  (defun my-completion-popup--lines (candidates index width)
    "Return propertized popup lines for CANDIDATES, highlighting INDEX."
    (let* ((count (length candidates))
           (max-rows (max 1
                          (min my-completion-popup-max-rows
                               (max 1 (1- (window-body-height))))))
           (rows (min count max-rows))
           (half (/ rows 2))
           (lo (if (<= count rows)
                   0
                 (max 0 (min (- index half) (- count rows)))))
           (lines nil))
      (dotimes (i rows)
        (let* ((j (+ lo i))
               (candidate (nth j candidates))
               (selected (= j index))
               (text (concat (if selected "▸ " "  ") candidate))
               (text (truncate-string-to-width text width nil nil "…"))
               (text (concat text
                             (make-string (max 0 (- width (string-width text)))
                                          ?\s))))
          (push (propertize text 'face (if selected
                                           'my-completion-popup-selected
                                         'my-completion-popup))
                lines)))
      (nreverse lines)))

  (defun my-completion-popup--move (frame position width rows)
    "Move FRAME below POSITION, flipping above when there is no room."
    (let* ((edges (window-inside-pixel-edges))
           (top (nth 1 edges))
           (bottom (nth 3 edges))
           (char-width (frame-char-width (selected-frame)))
           (char-height (frame-char-height (selected-frame)))
           (beg-posn (or (posn-at-point position) (posn-at-point)))
           (point-posn (or (posn-at-point) beg-posn))
           (beg-xy (posn-x-y beg-posn))
           (point-xy (posn-x-y point-posn))
           (x (+ (nth 0 edges) (or (car beg-xy) 0)))
           (point-y (+ top (or (cdr point-xy) 0)))
           (below-y (+ point-y char-height))
           (popup-width (* width char-width))
           (popup-height (* rows char-height))
           (frame-width (frame-pixel-width (selected-frame)))
           (x (max 0 (min x (- frame-width popup-width))))
           (y (if (<= (+ below-y popup-height) bottom)
                  below-y
                (max top (- point-y popup-height)))))
      (set-frame-position frame x y)))

  (defun my-completion-popup--show (position candidates index)
    "Show CANDIDATES with INDEX selected, anchored at POSITION."
    (let* ((parent (selected-frame))
           (max-width (apply #'max
                             (mapcar (lambda (candidate)
                                       (+ 3 (string-width candidate)))
                                     candidates)))
           (width (max 4 (min (1+ max-width)
                              (max 4 (- (frame-width parent) 2)))))
           (lines (my-completion-popup--lines candidates index width))
           (content (mapconcat #'identity lines "\n"))
           (frame (my-completion-popup--ensure-frame)))
      (unless (equal content my-completion-popup--content)
        (setq my-completion-popup--content content)
        (with-current-buffer (my-completion-popup--ensure-buffer)
          (let ((inhibit-read-only t)
                (inhibit-modification-hooks t))
            (erase-buffer)
            (insert content)
            (goto-char (point-min)))))
      (let ((timer (frame-parameter frame 'my-completion-popup--hide-timer)))
        (when (timerp timer)
          (cancel-timer timer)
          (set-frame-parameter frame 'my-completion-popup--hide-timer nil)))
      (set-window-buffer (frame-root-window frame)
                         (my-completion-popup--ensure-buffer))
      (let ((window-min-height 1)
            (window-min-width 1))
        (set-frame-size frame (* width (frame-char-width parent))
                        (* (length lines) (frame-char-height parent)) t))
      (my-completion-popup--move frame position width (length lines))
      (make-frame-visible frame)))

  (defun my-completion-popup--hide-now (frame)
    "Hide FRAME immediately and clear its contents."
    (when (frame-live-p frame)
      (set-frame-parameter frame 'my-completion-popup--hide-timer nil)
      (when (frame-visible-p frame)
        (make-frame-invisible frame))
      (when (buffer-live-p my-completion-popup--buffer)
        (with-current-buffer my-completion-popup--buffer
          (let ((inhibit-read-only t))
            (erase-buffer))))
      (setq my-completion-popup--content nil)))

  (defun my-completion-popup--hide ()
    "Hide the completion popup."
    (when (and (frame-live-p my-completion-popup--frame)
               (frame-visible-p my-completion-popup--frame))
      (let ((frame my-completion-popup--frame))
        (if (display-graphic-p frame)
            (my-completion-popup--hide-now frame)
          ;; TTY child frames are safer to hide after the current redisplay.
          (let ((timer (frame-parameter frame 'my-completion-popup--hide-timer)))
            (unless (timerp timer)
              (set-frame-parameter
               frame 'my-completion-popup--hide-timer
               (run-at-time 0 nil #'my-completion-popup--hide-now frame))))))))

  (defun my-completion-popup--selecting-p ()
    "Return non-nil if there are several candidates to select from."
    (when-let* ((state (my-completion-popup--state)))
      (>= (length (nth 1 state)) 2)))

  (defun my-completion-popup--refresh ()
    "Synchronize the completion popup with the completion preview."
    (condition-case nil
        (if-let* ((state (my-completion-popup--state)))
            (pcase-let ((`(,beg ,candidates ,index) state))
              (if (and (>= (length candidates) 2)
                       (or (display-graphic-p)
                           (featurep 'tty-child-frames)))
                  (my-completion-popup--show
                   beg candidates (min index (1- (length candidates))))
                (my-completion-popup--hide)))
          (my-completion-popup--hide))
      (error (my-completion-popup--hide))))

  (defun my-completion-popup--window-change (&rest _)
    "Hide the completion popup when the current window changes."
    (my-completion-popup--hide))

  (defun my-completion-popup--frame-deleted (frame)
    "Clear popup state when FRAME is deleted."
    (when (eq frame my-completion-popup--frame)
      (setq my-completion-popup--frame nil
            my-completion-popup--content nil)))

  (defun my-completion-popup--setup ()
    "Install popup hooks for the current completion-preview buffer."
    (unless (eq (current-buffer) my-completion-popup--buffer)
      (if completion-preview-mode
          (progn
            ;; Run after `completion-preview--post-command'.
            (add-hook 'post-command-hook #'my-completion-popup--refresh 90 t)
            (add-hook 'window-selection-change-functions
                      #'my-completion-popup--window-change nil t)
            (add-hook 'window-buffer-change-functions
                      #'my-completion-popup--window-change nil t)
            (add-hook 'kill-buffer-hook #'my-completion-popup--hide nil t))
        (remove-hook 'post-command-hook #'my-completion-popup--refresh t)
        (remove-hook 'window-selection-change-functions
                     #'my-completion-popup--window-change t)
        (remove-hook 'window-buffer-change-functions
                     #'my-completion-popup--window-change t)
        (remove-hook 'kill-buffer-hook #'my-completion-popup--hide t)
        (my-completion-popup--hide))))

  (defun my-completion-popup-next ()
    "Select the next popup candidate, or move down when there is no popup."
    (interactive)
    (if (my-completion-popup--selecting-p)
        (completion-preview-next-candidate 1)
      (completion-preview-active-mode -1)
      (my-completion-popup--hide)
      (line-move 1)))

  (defun my-completion-popup-prev ()
    "Select the previous popup candidate, or move up when there is no popup."
    (interactive)
    (if (my-completion-popup--selecting-p)
        (completion-preview-prev-candidate 1)
      (completion-preview-active-mode -1)
      (my-completion-popup--hide)
      (line-move -1)))

  (defun my-completion-popup-quit ()
    "Dismiss the completion popup and preview."
    (interactive)
    (completion-preview-active-mode -1)
    (my-completion-popup--hide))

  ;; These commands update the preview themselves; don't let the
  ;; preview's post-command handler hide it before the popup refreshes.
  (dolist (command '(my-completion-popup-next my-completion-popup-prev))
    (add-to-list 'completion-preview--internal-commands command))

  (define-key completion-preview-active-mode-map (kbd "C-n")
              #'my-completion-popup-next)
  (define-key completion-preview-active-mode-map (kbd "C-p")
              #'my-completion-popup-prev)
  (define-key completion-preview-active-mode-map (kbd "C-e")
              #'completion-preview-insert)
  (define-key completion-preview-active-mode-map (kbd "RET")
              #'completion-preview-insert)
  (define-key completion-preview-active-mode-map (kbd "C-g")
              #'my-completion-popup-quit)
  ;; TAB should keep its normal indentation/prefix behavior.
  (define-key completion-preview-active-mode-map (kbd "C-i") nil)

  (add-hook 'completion-preview-mode-hook #'my-completion-popup--setup)
  (add-hook 'minibuffer-setup-hook #'my-completion-popup--hide)
  (add-hook 'delete-frame-functions #'my-completion-popup--frame-deleted)

  ;; 让行内预览更像一条淡色的虚线。
  (set-face-attribute 'completion-preview nil
                      :foreground "#6272a4"
                      :underline '(:color "#6272a4" :style dashes))

  (global-completion-preview-mode 1))

;; flash.nvim 风格的可见区域搜索跳转。
(defvar my/flash--overlays nil)

(defun my/flash--clear ()
  (mapc #'delete-overlay my/flash--overlays)
  (setq my/flash--overlays nil))

(defun my/flash--show (pattern)
  "高亮当前窗口中的 PATTERN，并返回 ((LABEL . POS) ...)。"
  (my/flash--clear)
  (let ((case-fold-search (string= pattern (downcase pattern)))
        (labels (string-to-list "asdfghjklqwertyuiopzxcvbnm"))
        (positions nil))
    (save-excursion
      (goto-char (window-start))
      (while (search-forward pattern (window-end nil t) t)
        (push (match-beginning 0) positions)))
    (setq positions (nreverse positions))
    (dolist (pos positions)
      ;; 避免标签与“继续输入搜索词”冲突。
      (let ((next (char-after (+ pos (length pattern)))))
        (when next
          (setq labels (delq (downcase next) labels))))
      (let ((ov (make-overlay pos (min (point-max)
                                       (+ pos (length pattern))))))
        (overlay-put ov 'face '(:background "#6272a4" :foreground "#f8f8f2"))
        (push ov my/flash--overlays)))
    (let ((pairs nil))
      (dolist (pos (sort (copy-sequence positions)
                         (lambda (a b)
                           (< (abs (- a (point))) (abs (- b (point)))))))
        (when labels
          (let* ((label (char-to-string (pop labels)))
                 (ov (make-overlay pos (1+ pos))))
            (overlay-put ov 'display label)
            (overlay-put ov 'priority 1)
            (overlay-put ov 'face
                         '(:background "#ff79c6" :foreground "#282a36" :weight bold))
            (push ov my/flash--overlays)
            (push (cons label pos) pairs))))
      (nreverse pairs))))

(defun my/flash-jump ()
  "在当前窗口可见区域内按 flash.nvim 的方式跳转。"
  (interactive)
  (let ((pattern "")
        (pairs nil))
    (unwind-protect
        (catch 'done
          (while t
            (setq pairs (if (string-empty-p pattern)
                            (progn (my/flash--clear) nil)
                          (my/flash--show pattern)))
            (let ((key (condition-case nil
                           (read-char-exclusive (concat "Flash: " pattern))
                         (quit nil))))
              (cond
               ((null key) (throw 'done nil))
               ((not (integerp key)) nil)
               ((memq key '(27 7)) (throw 'done nil))
               ((memq key '(127 8))
                (if (string-empty-p pattern)
                    (throw 'done nil)
                  (setq pattern (substring pattern 0 -1))))
               ((and (>= key 32) (<= key 126))
                (let ((hit (assoc (char-to-string key) pairs)))
                  (if hit
                      (progn
                        (push-mark (point) t)
                        (goto-char (cdr hit))
                        (throw 'done nil))
                    (setq pattern (concat pattern (char-to-string key))))))
               (t nil)))))
      (my/flash--clear))))

(defun my/ido-sudo-find-file ()
  "Use ido to check file and open it with sudo."
  (interactive)
  (let ((file (ido-read-file-name "Open with sudo: ")))
    (when file (find-file (concat "/sudo::" file)))))

(defun my/ssh-tramp (host &optional path)
  "Connect to HOST via TRAMP SSH and open PATH (defaults to home)."
  (interactive "sSSH to (e.g. user@host): ")
  (let ((remote-path (format "/ssh:%s:%s" host (or path "~"))))
    (find-file remote-path)))

(defun my/move-line-down ()
  "Move line Down and keep cursor."
  (interactive)
  (let ((col (current-column)))
    (forward-line 1)
    (transpose-lines 1)
    (forward-line -1)
    (move-to-column col)))

(defun my/move-line-up ()
  "Move line up and keep cursor."
  (interactive)
  (let ((col (current-column)))
    (transpose-lines 1)
    (forward-line -2)
    (move-to-column col)))

(defun my/isearch-region-or-start ()
  "Search content if region is marked, otherwise normal isearch."
  (interactive)
  (if (use-region-p)
      (let ((text (buffer-substring-no-properties (region-beginning) (region-end))))
        (deactivate-mark)
        (isearch-mode t)
        (isearch-yank-string text))
    (isearch-forward)))

(defun my/isearch-region-back-or-start ()
  "Search content if region is marked, otherwise normal isearch."
  (interactive)
  (if (use-region-p)
      (let ((text (buffer-substring-no-properties (region-beginning) (region-end))))
        (deactivate-mark)
        (isearch-mode t)
        (isearch-yank-string text))
    (isearch-backward)))

(require 'battery)
(setq battery-mode-line-format "")
(defun my-dynamic-battery-show (&optional bat-status)
  "Render battery string from BAT-STATUS alist."
  (let ((bat-data (or bat-status
                      (and (boundp 'battery-status-function)
                           battery-status-function
                           (fboundp battery-status-function)
                           (ignore-errors (funcall battery-status-function))))))
    (if (not bat-data) ""
      (ignore-errors
        (let* ((online (string-equal (battery-format "%L" bat-data) "on-line"))
               (color (if online "#50fa7b" "#ffffff"))
               (bat-str (if (string-equal (battery-format "%B" bat-data) "charging")
                            (battery-format "󰂄%p%% " bat-data)
                          (battery-format "󰁹%p%% " bat-data))))
          (propertize bat-str 'face `(:weight bold :foreground ,color)))))))
(defvar my-battery-status "" "Used to show battery status.")
(put 'my-battery-status 'risky-local-variable t)
(defun my-update-battery (&optional status)
  "Update the STATUS of battery component."
  (setq my-battery-status (my-dynamic-battery-show status))
  (force-mode-line-update t))
(add-hook 'battery-update-functions #'my-update-battery)
(setq battery-update-interval 15)
(display-battery-mode 1)
(my-update-battery)

(defvar-local my-word-count-string "" "Used to count word number.")
(put 'my-word-count-string 'risky-local-variable t)
(defun my-update-word-count ()
  "Update word count."
  (interactive)
  (setq my-word-count-string
        (propertize (format " 󰌨 %d " (count-words (point-min) (point-max)))
                    'face '(:foreground "#8be9fd"))))
(my-update-word-count)
(add-hook 'after-save-hook #'my-update-word-count)
(add-hook 'find-file-hook #'my-update-word-count)

(defvar my-mode-line-format '("%e" mode-line-front-space
               (:propertize (""
                             mode-line-mule-info
                             mode-line-client
                             mode-line-modified
                             mode-line-remote
                             mode-line-window-dedicated)
                            display (min-width (6.0)))
               "  " mode-line-position
               my-word-count-string
               mode-line-frame-identification
               mode-line-buffer-identification
               (project-mode-line project-mode-line-format)
               mode-line-format-right-align
               my-battery-status
               (vc-mode vc-mode) " "
               mode-line-modes
               mode-line-misc-info
               mode-line-end-spaces))
(setq-default mode-line-format my-mode-line-format)

(use-package esh-mode
  :config
  (define-key eshell-mode-map (kbd "C-c e") (lambda () (interactive) (eshell t))))

(use-package org
  :config
  ;; 关闭 Org-mode 默认的行截断行为
  (setq org-startup-truncated nil)
  ;; 为 Org-mode 开启视觉软换行（按单词边界智能折行）
  (add-hook 'org-mode-hook #'visual-line-mode))

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
            (define-key map (kbd "C-c C-p") #'my/move-line-up)
            (define-key map (kbd "C-c C-n") #'my/move-line-down)
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
(global-set-key (kbd "C-o")     #'my/flash-jump)
(global-set-key (kbd "s-s")     #'save-buffer)
(global-set-key (kbd "s-d")     #'backward-delete-char)
(global-set-key (kbd "s-f")     #'ido-find-file)
(global-set-key (kbd "M-+")     #'text-scale-increase)
(global-set-key (kbd "M-_")     #'text-scale-decrease)
(global-set-key (kbd "C-<tab>") #'other-window)
(global-set-key (kbd "M-\"")    #'shell-command)

(global-set-key (kbd "C-x C-a") #'replace-regexp)
(global-set-key (kbd "C-x C-q") #'kill-emacs)
(global-set-key (kbd "C-c C-j") #'mode-line-invisible-mode)
(global-set-key (kbd "C-x c")   #'compile)

(global-set-key (kbd "C-c z")   #'zap-to-char)
(global-set-key (kbd "C-c c")   #'my/capital-forward)
(global-set-key (kbd "C-c r")   #'rgrep)
(global-set-key (kbd "C-c e")   #'eshell)
(global-set-key (kbd "C-c D")   #'kill-whole-line)
(global-set-key (kbd "C-c i")   #'indent-region)
(global-set-key (kbd "C-c E")   #'query-replace)
