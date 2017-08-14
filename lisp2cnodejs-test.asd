(in-package :cl-user)
(defpackage lisp2cnodejs-test-asd
  (:use :cl :asdf))
(in-package :lisp2cnodejs-test-asd)

(defsystem lisp2cnodejs-test
  :author ""
  :license ""
  :depends-on (:lisp2cnodejs
               :prove)
  :components ((:module "t"
                :components
                ((:file "lisp2cnodejs"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
