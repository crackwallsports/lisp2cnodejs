(in-package :lisp2cnodejs.view)
(my-load "shared")

(interpol:enable-interpol-syntax)
(cl-syntax:use-syntax :interpol)

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
                       `(option (:value ,(concat "tab" c)) ,i))))
         
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

(defun create-main-content (args)
  `(div (:id "content")
        ,(bs-panel
          :style "default"
          :header `((,(bs-breadcrumb
                       '((("首页") :href "/")
                         (("发表话题") :class "active")))))
          :body `((;; Error | Success
                   ,(error-or-success (getf args :error)
                                      (getf args :success))
                   
                    ;; Panel
                    ,(create-panel
                      "/topic/create"
                      '("精华" "分享")))))))

(defun create-html-content (args)
  `(,(bs-container
      `(,(bs-row-col
          `((9 (,(create-main-content args)))
            (3 (,(main-sidebar))))
          :w '("md")))
      :fluid t)))

(defun topic-create-page (args)
  (layout-template
   args
   :title
   (or (getf args :title) "发表话题")
   :links
   `(,(getf *web-links* :bs-css)
      ,(getf *web-links* :main-css)
      ,(getf *web-links* :md-editor-css))
   :head-rest
   `()
   :content
   (create-html-content args)
   :scripts
   `(,(getf *web-links* :jq-js)
      ,(getf *web-links* :bs-js)
      ,(getf *web-links* :md-editor-js)
      (script ()
              "var simplemde = new SimpleMDE({ element: document.getElementById(\"md-editor\") });"))))
