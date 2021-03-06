;; Package
(in-package :cl-user)
(defpackage lisp2cnodejs.web
  (:use :cl
        :caveman2
        :xt3.web.base
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
(interpol:enable-interpol-syntax)
(cl-syntax:use-syntax :interpol)

;; Error pages
(defmethod on-exception ((app <web>) code)
  (declare (ignore app))
  ;; (merge-pathnames #P"_errors/404.html"
  ;;                *template-directory*)
  #?"ERROR: ${code}"
  ;; (lisp-render (error-page code))
  )

;; GET /
;; (defroute "/" ()
;;   (lisp-render "index" `(:user ,(gethash :user *session*))))

(defroute "/" (&key (|tab| "all") (|page| "1"))
  (let* ((int (or (parse-integer |page|) 1))
         (page (if (> int 0) int 1))
         (count 10))
    (multiple-value-bind (topics allcount)
        (find-sort-topics (if (string/= |tab| "all") `(("tab" ,|tab|)))
                          "insertTime"
                          nil
                          :skip (* (- page 1) count)
                          :limit count)
      ;; (format nil "tab=~a page=~a pc=~a" |tab| page allcount )
      (lisp-render "index" `(:title ,(concat "首页 欢迎您"
                                             (or (gethash :user *session*)
                                                 ""))
                                    :user ,(gethash :user *session*)
                                    :topics ,(topic-docs->hts topics)
                                    :tab ,|tab|
                                    :page ,page
                                    :pcount ,(ceiling (/ (or allcount 0)
                                                         count)))))))

;; GET /logout
(defroute "/logout" ()
  (setf (gethash :user *session*) nil)
  (redirect "/"))

;; /login | /register
(defroute ("/(login)|(register)" :regexp t :method :ANY) ()
  (if (gethash :user *session*)
      (redirect "/")
      (next-route)))

;; /topic /create
(defroute ("/topic/(create)" :regexp t :method :ANY) ()
  (if (gethash :user *session*)
      (next-route)
      (redirect "/login")))

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

;; GET /topic/create
(defroute "/topic/create" ()
  (lisp-render "topic-create" `(:user ,(gethash :user *session*))))

;; POST /topic/create
(defroute ("/topic/create" :method :POST) (&key |title| |content| |tab|)
  (destructuring-bind (title content tab)
      (mapcar (lambda (str)
                (string-trim '(#\Space #\Tab #\Newline #\Return) str))
              (list |title| |content| |tab|))
    (let ((uname (gethash :user *session*)))
      (cond
        ((some (lambda (s) (string= s ""))
               (list title content tab))
         (setf (response-status *response*) 422)
         (lisp-render "topic-create" '(:error "信息不完整!"
                                       :user uname)))
        (t (add-topic uname
                      tab
                      title
                      content
                      (get-universal-time))
           (lisp-render "topic-create" '(:success "话题发表成功!"
                                         :user uname)))))))

;; GET /topic/:tid
(defroute "/topic/:tid" (&key (tid ""))
  ;; (format nil "~a" tid)
  (let ((topic (find-topic-by-id tid)))
    (multiple-value-bind (replys count)
        (find-sort-replys (if (string/= tid "") `(("topic-id" ,tid)))
                         "insertTime"
                         t)
      (lisp-render "topic-detail"
                   `(:user ,(gethash :user *session*)
                           :topic ,(first (topic-docs->hts topic))
                           :count ,count :replys ,(reply-docs->hts replys))))))

;; POST /reply/add
(defroute ("/reply/add" :method :POST) (&key (|tid| "") (|content| ""))
  (let ((con (string-trim '(#\Space #\Tab #\Newline #\Return) |content|)))
    (cond
      ((string= con "")
       (setf (response-status *response*) 422)
       ;; ? Ajax
       "信息不完整!")
      (t (add-reply (gethash :user *session*)
                    |tid|
                    con
                    (get-universal-time))
         (redirect (concat "/topic/" |tid|))))))
