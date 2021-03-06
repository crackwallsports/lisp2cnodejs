(in-package :cl-user)
(defpackage lisp2cnodejs-asd
  (:use :cl :asdf))
(in-package :lisp2cnodejs-asd)

(defsystem lisp2cnodejs
  :version "0.1"
  :author "Xt3"
  :license ""
  :depends-on (:clack
               :lack
               :caveman2
               :envy
               :cl-ppcre
               :uiop

               ;; #?
               :cl-interpol
               :cl-syntax-interpol

               ;; Password
               :cl-pass
               
               ;; for @route annotation
               ;; :cl-syntax-annot

               ;; HTML Template
               ;; :djula
               :plump
               :parenscript
               ;; JS
               :parenscript

               ;; Markdown
               :markdown.cl

               ;; for DB
               ;; SQL
               :datafly
               :sxql
               ;; NoSQL : MongoDB
               :cl-mongo
               :cl-mongo-id
               )
  :components ((:module "src"
                :components
                ((:file "main" :depends-on ("config" "view" "db"))
                 (:file "web" :depends-on ("view" "model" "base"))
                 (:file "view" :depends-on ("config" "base" "CL3Bootstrap"))
                 (:file "model" :depends-on ("db"))
                 (:file "db" :depends-on ("config"))
                 (:file "css" :depends-on ("config" "base"))
                 (:file "js" :depends-on ("config" "base"))
                 (:file "CL3Bootstrap")
                 (:file "base")
                 (:file "config"))))
  :description ""
  :in-order-to ((test-op (load-op lisp2cnodejs-test))))
