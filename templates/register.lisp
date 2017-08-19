(in-package :lisp2cnodejs.view)
(my-load "shared")

(defun register-main-content (args)
  `(div (:id "content")
        ,(bs-panel
          :style "default"
          :header `((,(bs-breadcrumb
                       '((("首页") :href "/")
                         (("注册") :class "active")))))
          :body `((;; Error | Success
                   ,(error-or-success (getf args :error)
                                      (getf args :success))
                    
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


(defun register-html-content (args)
  `(,(bs-container
      `(,(bs-row-col
          `((9 (,(register-main-content)))
            (3 (,(main-sidebar))))
          :w '("md")))
      :fluid t)))

(defun register-page (args)
  (layout-template
   args
   :title
   (or (getf args :title) "注册")
   :links
   `(,(getf *web-links* :bs-css)
      ,(getf *web-links* :main-css))
   :head-rest
   `()
   :content
   (register-html-content args)
   :scripts
   `(,(getf *web-links* :jq-js)
      ,(getf *web-links* :bs-js))))
