(in-package :cl-user)
(defpackage lisp2cnodejs.model
  (:use :cl :cl-mongo :cl-mongo-id)
  (:import-from :cl-mongo
                :make-bson-oid)
  (:export :doc-count
           :find-user
           :add-user
           :auth-user
           :add-topic
           :find-topics
           :find-sort-topics
           :find-topic-by-id
           :topic-docs->hts
           :add-reply
           :find-replys
           :find-sort-replys
           :reply-docs->hts))
(in-package :lisp2cnodejs.model)

;; Database
(db.use "node-club")

;; Count
(defun doc-count (col &key (sel :all))
  (first (get-element "n" (docs (db.count col sel)))))

;; User
(defparameter *user-col* "user")

;; Add
(defun add-user (uname pwd email)
  "add user to database."
  (db.insert *user-col* ($ ($ "username" uname)
                           ($ "password" ;; (cl-pass:hash pwd)
                              pwd)
                           ($ "email" email))))

;; Find
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

;; Auth
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
            (setf (gethash "id" ht) (oid-str (doc-id i)))
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

;; Find
(defun find-topics (query &optional option)
  "find topic from database."
  (let* ((qy (if query
                 (apply #'kv (loop for (k v) in query
                                collect (kv k v)))
                 :all))
         (docs (docs (apply #'db.find *topic-col* qy option))))
    (values docs
            (doc-count *topic-col* :sel qy))))

(defun find-sort-topics (query field asc &key (skip 0) (limit 0))
  "sort topic from database."
  (let ((cl-mongo::*mongo-registry* nil))
    (cl-mongo:with-mongo-connection (:db "node-club")
      (let* ((qy (if query
                     (apply #'kv (loop for (k v) in query
                                    collect (kv k v)))
                     :all))
             (docs (docs (db.sort *topic-col* qy
                                  :field field :asc asc
                                  :skip skip :limit limit))
               ))
        (values docs
                0 ;; (doc-count *topic-col* :sel qy)
                ))))
  
  )

(defun find-topic-by-id (id)
  (let ((oid (make-bson-oid :oid (oid id))))
    (docs (db.find *topic-col* (kv "_id" oid)))))

;; Topic
(defparameter *reply-col* "reply")

;; Help
(defun reply-docs->hts (docs)
  (let (hts)
    (loop for i in docs
       do (let ((ht (make-hash-table :test 'equal)))
            (setf (gethash "id" ht)  (oid-str (doc-id i)))
            (setf (gethash "username" ht) (get-element "username" i))
            (setf (gethash "tid" ht) (get-element "topic-id" i))
            (setf (gethash "content" ht) (get-element "content" i))
            (setf (gethash "insertTime" ht) (get-element "insertTime" i))
            (push ht hts)))
    (nreverse hts)))

;; Add
(defun add-reply (uname tid content date)
  "add reply to database."
  (db.insert *reply-col*
             ($ ($ "username" uname)
                ($ "topic-id" tid)
                ($ "content" content)
                ($ "insertTime" date))))

;; Find
(defun find-replys (query &optional option)
  "find reply from database."
  (let* ((qy (if query
                 (apply #'kv (loop for (k v) in query
                                collect (kv k v)))
                 :all) )
         (docs (docs (apply #'db.find
                            *reply-col*
                            qy
                            option)) ))
    (values docs
            (doc-count *reply-col* :sel qy))))

(defun find-sort-replys (query field asc &key (skip 0) (limit 0))
  "sort reply from database."
  (let* ((qy (if query
                 (apply #'kv (loop for (k v) in query
                                collect (kv k v)))
                 :all) )
         (docs (docs (db.sort *reply-col* qy
                             :field field :asc asc
                             :skip skip :limit limit ))))
    (values docs
            (doc-count *reply-col* :sel qy))))
