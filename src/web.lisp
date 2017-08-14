;; Package
(in-package :cl-user)
(defpackage lisp2cnodejs.web
  (:use :cl
        :caveman2
        :lisp2cnodejs.config
        :lisp2cnodejs.view
        :lisp2cnodejs.model
        ;; :lisp2cnodejs.db
        ;; :datafly
        ;; :sxql
        )
  (:export :*web*))
(in-package :lisp2cnodejs.web)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

;; 
;; Routing rules

;; Error pages
(defmethod on-exception ((app <web>) code)
  (declare (ignore app))
  ;; (merge-pathnames #P"_errors/404.html"
  ;;                *template-directory*)
  #?"ERROR: ${code}"
  ;; (lisp-render (error-page code))
  )

;; GET /
(defroute "/" ()
  (if (gethash :user *session*)
      (format nil "<h1>欢迎 ~A</h1>" (gethash :user *session*))
      (format nil "<h1>首页</h1>")))

;; GET /logout
(defroute "/logout" ()
  (setf (gethash :user *session*) nil)
  (redirect "/"))

;; GET /*
(defroute ("/(login)|(register)" :regexp t) ()
  (if (gethash :user *session*)
      (redirect "/")
      (next-route)))

;; GET /login
(defroute "/login" ()
  (lisp-render "login" `(:user ,(gethash :user *session*))))

;; POST /login
(defroute ("/login" :method :POST) (&key |uname| |pwd|)
  (cond
    ((some (lambda (s) (string= s ""))
           (list |uname| |pwd|))
     (setf (response-status *response*) 422)
     (lisp-render "login" '(:error "用户名或密码不能为空")))
    (t (multiple-value-bind (pwdp unamep) (auth-user |uname| |pwd|)
         (cond
           (pwdp (setf (gethash :user *session*) |uname|)
                 (lisp-render "login" '(:success "登录成功"
                                        :user |uname|)))
           (unamep (setf (response-status *response*) 422)
                   (lisp-render "login" '(:error "密码错误")))
           (t (setf (response-status *response*) 422)
              (lisp-render "login" '(:error "用户名和密码错误"))))))))

;; GET /register
(defroute "/register" ()
  (lisp-render "register" `(:user ,(gethash :user *session*))))

;; POST /register
(defroute ("/register" :method :POST) (&key |uname| |pwd| |repwd| |email|)
  (cond
    ((or (some (lambda (s) (string= s ""))
               (list |uname| |pwd| |repwd| |email|))
         (string/= |pwd| |repwd|))
     (register-error "注册信息错误"))
    (t (if (find-user |uname| |email|)
           (register-error "用户名或邮箱被占用")
           (progn
             (add-user |uname| |pwd| |email|)
             (setf (response-status *response*) 200)
             (lisp-render "register" '(:success "注册成功")))))))

(defun register-error (msg)
  (setf (response-status *response*) 422)
  (lisp-render "register" `(:error ,msg)))
