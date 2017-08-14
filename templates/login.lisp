(in-package :lisp2cnodejs.view)
(load "shared")

(defun login-main-content ()
  `(div (:id "content")
        ,(bs-panel
          :style "default"
          :header `((,(bs-breadcrumb
                       '((("首页") :href "/")
                         (("登录") :class "active")))))
          :body `((
                   ;; Error | Success
                   ,(let ((err (getf *args* :error))
                          (suc (getf *args* :success)))
                      (cond
                        (err `(div (:class "alert alert-danger")
                                   (strong () ,err)))
                        (suc `(div (:class "alert alert-success")
                                   (strong () ,suc)))
                        (t "")))
                    ;; Panel
                   ,(reg-or-login-panel
                      "/login"
                      '(("用户名" "uname" "text")
                        ("密码" "pwd" "password"))
                      `((,(bs-btn `("登录")
                                  :type "submit"
                                  :style "primary")
                          (a (:href "#") "忘记密码?")))))))))


(defun login-html-content ()
  `(,(bs-container
      `(,(bs-row-col
          `((9 (,(login-main-content)))
            (3 (,(main-sidebar))))
          :w '("md")))
      :fluid t)))

;; (defun login-js
;;   (ps))


(defmacro login-page-mac ()
  `(html-template
    (layout-template)
    ,(merge-args
      *args*
      `(:title
        "登录"
        :links
        `(,(getf *web-links* :bs-css)
           ,(getf *web-links* :main-css))
        :head-rest
        `((style ()
                 ,(->css
                   '((".navbar" (:border-radius "0")
                      (".navbar-brand" (:padding "0px 20px")
                       (img (:width "120px"
                                    :height "100%"))))
                     (".breadcrumb" (:padding 0
                                     :margin 0))))))
        :content `(,@(login-html-content))
        :scripts
        `(,(getf *web-links* :jq-js)
           ,(getf *web-links* :bs-js))))))

(defun login-page ()
  (login-page-mac))
