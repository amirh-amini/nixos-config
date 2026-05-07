;; -*- lexical-binding: t; -*-

;; Disable org element cache to prevent known parser errors.
;; Must be set before org is loaded (including during tangle).
(setq org-element-use-cache nil)

;; Resolve the symlink so we find config.org where it actually lives.
;; config.el gets tangled next to it (in your flake repo), and we load it from there.
(let* ((config-org (file-truename (expand-file-name "config.org" user-emacs-directory)))
       (config-dir (file-name-directory config-org))
       (config-el  (expand-file-name "config.el" config-dir)))
  (when (or (not (file-exists-p config-el))
            (file-newer-than-file-p config-org config-el))
    (require 'org)
    (org-babel-tangle-file config-org config-el))
  (load-file config-el))

;; -*- lexical-binding: t; -*-
