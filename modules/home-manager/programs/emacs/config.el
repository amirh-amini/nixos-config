(use-package gcmh
  :config
  (gcmh-mode 1))

(use-package no-littering
  :demand t)

(use-package evil
  :demand t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-Y-yank-to-eol t
        evil-undo-system 'undo-fu)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package undo-fu)

(use-package general
  :demand t
  :config
  (general-create-definer my/leader-def
    :keymaps 'override
    :states '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "M-SPC"))

(use-package which-key
  :config
  (which-key-mode 1))

(use-package doom-themes
  :config
  (load-theme 'doom-one t))

(use-package doom-modeline
  :config
  (doom-modeline-mode 1))

(use-package saveplace
  :config
  (save-place-mode 1))

(use-package autorevert
  :config
  (global-auto-revert-mode 1))
