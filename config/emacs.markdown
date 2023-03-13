(add-to-list 'load-path "~/.emacs.d/list")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(indent-tabs-mode nil)
 '(mouse-wheel-mode t nil (mwheel))
 '(package-selected-packages
   '(flymd map flycheck-bashate flymake-shellcheck atom-one-dark-theme))
 '(setq tab-width t)
 '(tags-add-tables 'ask-user)
 '(transient-mark-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:stipple nil :background "black" :foreground "white" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 135 :width normal :family "adobe-courier")))))
'(c-set-style bsd)

;; disable menu-bar-mode
(menu-bar-mode -1)
(tool-bar-mode -1)
;;(window-system -1)

;; iswitchb mode
(iswitchb-mode 1)

;; column number mode
(column-number-mode 1)

;; markdown mode
(markdown-mode)

(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/")
   t)
  (package-initialize))

;; Fix issues with melpa installation
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
