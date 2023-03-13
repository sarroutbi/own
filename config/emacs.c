(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(c-syntactic-indentation nil)
 '(case-fold-search t)
 '(current-language-environment "Latin-9")
 '(default-input-method "latin-9-prefix")
 '(global-font-lock-mode t nil (font-lock))
 '(mouse-wheel-mode t nil (mwheel))
 '(package-selected-packages
   '(## yaml-mode req-package neotree markdown-mode irony-eldoc go-mode go-autocomplete flymd flymake-go flycheck-irony flycheck-bashate exec-path-from-shell dockerfile-mode company-irony atom-one-dark-theme anaconda-mode))
 '(tab-width 8)
 '(tags-add-tables 'ask-user)
 '(transient-mark-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:stipple nil :background "black" :foreground "white" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 135 :width normal :family "adobe-courier")))))
'(c-set-style bsd)
(add-to-list 'load-path "~/.emacs.d/lisp/")
;;; (require 'cscope)
(require 'xcscope)
(setq cscope-do-not-update-database t)
(put 'set-goal-column 'disabled nil)
(put 'upcase-region 'disabled nil)
(menu-bar-mode -1)
(toggle-scroll-bar -1)
(tool-bar-mode -1)
