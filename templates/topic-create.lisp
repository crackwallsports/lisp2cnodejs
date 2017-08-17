(in-package :lisp2cnodejs.view)
(interpol:enable-interpol-syntax)
(cl-syntax:use-syntax :interpol)  

(load "shared")

(defun create-panel (action board-data)
  `(form (:action ,action :method "post"
                  :class "form-horizontal"
                  :id "topic-create-form")
         (div (:class "form-group")
              (span () "选择板块:")
              (select (:name "tab" :id "tab-value")
                ,@(loop for i in board-data
                     and c = 1 then (1+ c)
                     collect
                       `(option (:value ,#?"tab${c}") ,i))))
         
         (div (:class "form-group")
              (input (:name "title" :type "text"
                            :id "title"
                            :class "form-control input-sm")))
         (div (:class "form-group")
              (div (:class "markdown_editor in_editor")
                   (div (:class "markdown_in_editor")
                        (textarea (:class "editor"
                                          :name "content"
                                          :id "md-editor"
                                          :cols "30"
                                          :rows "10")))))
         (div (:class "form-group editor_buttons")
              ;; (input (:class "span-primary submit-btn"
              ;;                :type "submit"
              ;;                :value "提交"))
              ,(bs-btn `("提交")
                       :type "submit"
                       :style "primary"))))

(defun create-main-content ()
  `(div (:id "content")
        ,(bs-panel
          :style "default"
          :header `((,(bs-breadcrumb
                       '((("首页") :href "/")
                         (("发表话题") :class "active")))))
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
                    ,(create-panel
                      "/topic/create"
                      '("精华" "分享")))))))

(defun create-html-content ()
  `(,(bs-container
      `(,(bs-row-col
          `((9 (,(create-main-content)))
            (3 (,(main-sidebar))))
          :w '("md")))
      :fluid t)))

(defmacro topic-create-page-mac ()
  `(html-template
    (layout-template)
    ,(merge-args
      *args*
      `(:title
        "发表话题"
        :links
        `(,(getf *web-links* :bs-css)
           ,(getf *web-links* :main-css)
           ,(getf *web-links* :md-editor-css))
        :head-rest
        `()
        :content `(,@(create-html-content))
        :scripts
        `(,(getf *web-links* :jq-js)
           ,(getf *web-links* :bs-js)
           ,(getf *web-links* :md-editor-js)
           (script ()
                   "var simplemde = new SimpleMDE({ element: document.getElementById(\"md-editor\") });"))))))

(defun topic-create-page ()
  (topic-create-page-mac))
