(in-package :lisp2cnodejs.view)
(my-load "shared")

(defun register-main-content ()
  `(div (:id "content")
        ,(bs-panel
          :style "default"
          :header `((,(bs-breadcrumb
                       '((("首页") :href "/")
                         (("注册") :class "active")))))
          :body `((
                   ;; Error | Success
                   ,(let ((err (getf *args* :error))
                          (suc (getf *args* :success)))
                      (cond
                        (err `(div (:class "alert alert-danger")
                                   (strong () ,err)))
                        (suc `(div (:class "alert alert-success")
                                   (strong () ,suc)))
                        ;; (format nil "~A" *args*)
                        (t "")))
                    
                    ;; Panel
                    ,(reg-or-login-panel
                      "/register"
                      '(("用户名" "uname" "text")
                        ("密码" "pwd" "password")
                        ("确认密码" "repwd" "password")
                        ("电子邮箱" "email" "text"))
                      `((,(bs-btn `("注册")
                                  :type "submit"
                                  :style "primary")
                          ,(bs-btn `("重置表单")
                                   :type "reset"
                                   :style "info")))))))))


(defun register-html-content ()
  `(,(bs-container
      `(,(bs-row-col
          `((9 (,(register-main-content)))
            (3 (,(main-sidebar))))
          :w '("md")))
      :fluid t)))

(defmacro register-page-mac ()
  `(html-template
    (layout-template)
    ,(merge-args
      *args*
      `(:title
        "注册"
        :links
        `(,(getf *web-links* :bs-css)
           ,(getf *web-links* :main-css))
        :head-rest
        `()
        :content `(,@(register-html-content))
        :scripts
        `(,(getf *web-links* :jq-js)
           ,(getf *web-links* :bs-js))))))

(defun register-page ()
  (register-page-mac))
