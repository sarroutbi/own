(menu-bar-mode -1)
(toggle-scroll-bar -1)
(tool-bar-mode -1)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(js2-mode zenburn-theme yasnippet yaml-mode which-key rustic req-package projectile neotree lsp-ui json-mode irony-eldoc icomplete-vertical helm-xref helm-lsp go-mode go-autocomplete flymd flymake-go flycheck-irony flycheck-bashate exec-path-from-shell eglot dockerfile-mode diminish dap-mode company-irony atom-one-dark-theme anaconda-mode)))
'(tab-width 2)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . js2-mode))

(setq-default indent-tabs-mode nil) ; Use spaces instead of tabs
(setq tab-width 2)
