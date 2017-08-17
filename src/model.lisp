(in-package :cl-user)
(defpackage lisp2cnodejs.model
  (:use :cl :cl-mongo :cl-mongo-id)
  (:import-from :cl-mongo
                :make-bson-oid)
  (:export :find-user
           :add-user
           :auth-user
           :add-topic
           :find-topic
           :find-sort-topic
           :find-topic-by-id
           :topic-docs->hts))
(in-package :lisp2cnodejs.model)

;; Database
(db.use "node-club")

;; Count
(defun doc-count (col &key (sel :all))
  (first (get-element "n" (docs (db.count col sel)))))

;; User
(defparameter *user-col* "user")





;; User
(defun add-user (uname pwd email)
  "add user to database."
  (db.insert *user-col* ($ ($ "username" uname)
                           ($ "password" ;; (cl-pass:hash pwd)
                              pwd)
                           ($ "email" email))))

(defun find-username (uname)
  "lookup user by username."
  (docs (db.find *user-col* ($ "username" uname))))

(defun find-email (email)
  "lookup user by email."
  (docs (db.find *user-col* ($ "email" email))))

(defun find-user (uname email)
  "lookup user by username or email."
  ;; (or (find-username uname)
  ;;     (find-email email))
  (docs (db.find *user-col* (kv "$or"
                                (list ($ "username" uname)
                                      ($ "email" email))))))

(defun auth-user (uname pwd)
  ;; (db.find *user-col* ($ ($ :username uname)
  ;;                   ($ :password pwd)))
  (let ((pwd-hash (first (get-element "password"
                               (find-username uname)))))
    (if pwd-hash
        (values ;; (cl-pass:check-password pwd pwd-hash)
         (string= pwd pwd-hash)
         uname)
        (values nil nil))))

;; Topic
(defparameter *topic-col* "topic")

;; Help
(defun topic-docs->hts (docs)
  (let (hts)
    (loop for i in docs
       do (let ((ht (make-hash-table :test 'equal)))
            (setf (gethash "id" ht)  (oid-str (doc-id i)))
            (setf (gethash "title" ht) (get-element "title" i))
            (setf (gethash "content" ht) (get-element "content" i))
            (setf (gethash "tab" ht) (get-element "tab" i))
            (setf (gethash "username" ht) (get-element "username" i))
            (setf (gethash "insertTime" ht) (get-element "insertTime" i))
            (push ht hts)))
    (nreverse hts)))

;; Add
(defun add-topic (uname tab title content date)
  "add topic to database."
  (db.insert *topic-col* ($ ($ "title" title)
                           ($ "content" content)
                           ($ "tab" tab)
                           ($ "username" uname)
                           ($ "insertTime" date))))

(defun find-topic (query &optional option)
  "find topic from database."
  (let* ((qy (if query
                 (apply #'kv (loop for (k v) in query
                                collect (kv k v)))
                 :all) )
         (docs (docs (apply #'db.find
                            *topic-col*
                            qy
                            option)) ))
    (values docs
            (doc-count *topic-col* :sel qy))))

(defun find-sort-topic (query field asc &key (skip 0) (limit 0))
  "sort topic from database."
  (let* ((qy (if query
                 (apply #'kv (loop for (k v) in query
                                collect (kv k v)))
                 :all) )
         (docs (docs (db.sort *topic-col* qy
                             :field field :asc asc
                             :skip skip :limit limit ))))
    (values docs
            (doc-count *topic-col* :sel qy))))

(defun find-topic-by-id (id)
  (let ((oid (make-bson-oid :oid (oid id))))
    (docs (db.find *topic-col* (kv "_id" oid)))))
