(in-package :lisp2cnodejs.view)
(my-load "shared")

(defun login-main-content (args)
  `(div (:id "content")
        ,(bs-panel
          :style "default"
          :header `((,(bs-breadcrumb
                       '((("首页") :href "/")
                         (("登录") :class "active")))))
          :body `((;; Error | Success
                   ,(error-or-success (getf args :error)
                                      (getf args :success))
                    ;; Panel
                   ,(reg-or-login-panel
                      "/login"
                      '(("用户名" "uname" "text")
                        ("密码" "pwd" "password"))
                      `((,(bs-btn `("登录")
                                  :type "submit"
                                  :style "primary")
                          (a (:href "#") "忘记密码?")))))))))


(defun login-html-content (args)
  `(,(bs-container
      `(,(bs-row-col
          `((9 (,(login-main-content args)))
            (3 (,(main-sidebar))))
          :w '("md")))
      :fluid t)))

(defun login-page (args)
  (layout-template
   args
   :title
   (or (getf args :title) "登录")
   :links
   `(,(getf *web-links* :bs-css)
      ,(getf *web-links* :main-css))
   :head-rest
   `()
   :content
   (login-html-content args)
   :scripts
   `(,(getf *web-links* :jq-js)
      ,(getf *web-links* :bs-js))))
