(in-package :cl-user)
(defpackage lisp2cnodejs.model
  (:use :cl :cl-mongo)
  (:export :find-user
           :add-user
           :auth-user))
(in-package :lisp2cnodejs.model)

;; Database
(db.use "node-club")

;; Collection
(defparameter *col* "user") 

(defun add-user (uname pwd email)
  "add user record to database."
  (db.insert *col* ($ ($ "username" uname)
                      ($ "password" ;; (cl-pass:hash pwd)
                         pwd)
                      ($ "email" email))))

(defun find-username (uname)
  "lookup user record by username."
  (docs (db.find *col* ($ "username" uname))))

(defun find-email (email)
  "lookup user record by email."
  (docs (db.find *col* ($ "email" email))))

(defun find-user (uname email)
  "lookup user record by username or email."
  ;; (or (find-username uname)
  ;;     (find-email email))
  (docs (db.find *col* (kv "$or" (list ($ "username" uname)
                                       ($ "email" email))))))

(defun auth-user (uname pwd)
  ;; (db.find *col* ($ ($ :username uname)
  ;;                   ($ :password pwd)))
  (let ((pwd-hash (first (get-element "password"
                               (find-username uname)))))
    (if pwd-hash
        (values ;; (cl-pass:check-password pwd pwd-hash)
         (string= pwd pwd-hash)
         uname)
        (values nil nil))))