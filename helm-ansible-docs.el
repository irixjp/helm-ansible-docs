;;; helm-ansible-docs.el --- ansible documents with helm interface  -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Tomoaki Nakajima

;; Author: Tomoaki Nakajima <twitter@irix_jp>
;; URL: https://github.com/irixjp/
;; Version: 0.01
;; Package-Requires:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; ansible documents with helm interface

;;; Code:

(require 'helm)
(require 'json)
(require 'cl-lib)

(defgroup helm-ansible-docs nil
  "helm interface for ansible-docs command"
  :group 'helm)

(defcustom helm-ansible-docs-url "https://docs.ansible.com/ansible/latest/modules/"
  "Documents URL."
  :group 'helm-ansible-docs)

(setq *helm-ansible-docs-data* nil)

(defun helm-ansible-docs--get-docs ()
  "Get ansible documents data from ansible-doc -l -j."
  (setq *helm-ansible-docs-data*
        (mapcar #'(lambda (x) (cons (symbol-name (car x)) (cdr x)))
                  (json-read-from-string (shell-command-to-string "ansible-doc -l -j")))))

(defun helm-ansible-docs--initialize ()
  "Initialize document source."
  (if *helm-ansible-docs-data*
      t
    (helm-ansible-docs--get-docs)))

(defun helm-ansible-docs--candidates ()
  "Build data for candidates."
  (helm-ansible-docs--initialize)
  (mapcar #'(lambda (x)
              (list (concatenate 'string (car x) ": " (cdr x))
                    (car x)
                    (cdr x))) *helm-ansible-docs-data*))

(defun helm-ansible-docs--insert (module)
  (insert (car module)))

(defun helm-ansible-docs--insert-in-helm-buffer ()
  (interactive)
  (with-helm-alive-p
    (helm-exit-and-execute-action 'helm-ansible-docs--insert)))

(defun helm-ansible-docs--open-url (module)
  (browse-url (concatenate 'string
                           helm-ansible-docs-url
                           (car module)
                           "_module.html")))

(defun helm-ansible-docs--open-doc (module)
  (let ((buffer (get-buffer-create "*ansible doc*")))
    (save-excursion
      (set-buffer buffer)
      (fundamental-mode)
      (erase-buffer)
      (insert (shell-command-to-string (concatenate 'string "ansible-doc " (car module))))
      (goto-char (point-min))
      (view-mode)
      (display-buffer buffer))))

(defvar helm-ansible-docs-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map helm-map)
    (define-key map (kbd "C-c i") 'helm-ansible-docs--insert-in-helm-buffer)
    map)
  "Keymap for `helm-ansible-docs'.")

(defvar helm-ansible-docs--source
  (helm-build-sync-source "Ansible Modules list"
    :candidates #'helm-ansible-docs--candidates
    :volatile t
    :action (helm-make-actions
             "Open module document" #'helm-ansible-docs--open-doc
             "Insert" #'helm-ansible-docs--insert
             "Open Browser" #'helm-ansible-docs--open-url
             )))

(defun helm-ansible-docs ()
  "Display helm interface for ansbile docs."
  (interactive)
  (helm :sources '(helm-ansible-docs--source)
        :buffer "*helm ansible docs*"
        :keymap helm-ansible-docs-map))

(define-key global-map (kbd "C-c d a") 'helm-ansible-docs)

(provide 'helm-ansible-docs)
;;; helm-ansible-docs.el ends here
