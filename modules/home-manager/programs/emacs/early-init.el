;; -*- lexical-binding: t; -*-

;; Disable package.el — Nix handles package installation.
(setq package-enable-at-startup nil)

;; Prevent UI elements from flashing before our config loads.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq inhibit-startup-message t)
;; (setq vc-follow-symlinks t)

;; Redirect native-comp cache out of ~/.config/emacs/
(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name "var/eln-cache/" user-emacs-directory))))

