(custom-set-variables
  ;; custom-set-variables was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
'(c-basic-offset 2)
'(c-progress-interval 2)
'(c-syntactic-indentation nil)
'(case-fold-search t)
'(current-language-environment "Latin-9")
'(default-input-method "latin-9-prefix")
'(fortran-tab-mode-default nil t)
'(global-font-lock-mode t nil (font-lock))
'(indent-tabs-mode nil)
'(mouse-wheel-mode t nil (mwheel))
'(tab-width 1)
'(tags-add-tables (quote ask-user) t)
'(transient-mark-mode t))
(custom-set-faces
  ;; custom-set-faces was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
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
