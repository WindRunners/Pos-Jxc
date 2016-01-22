Rails.application.routes.draw do

  resources :roles
  resources :card_bags do

  resources :feedbacks
  end
  resources :product_tickets do
    # post 'import_customers', :on => :collection
    post 'customer_add'
    post 'customer_reduce'
    post 'build_card_bag'
    post 'share_time_check', :on => :collection
    get 'share'
    post 'register'
  end

  resources :user_integrals
  resources :wines

  resources :userinfo_asks
  resources :cashes
  resources :import_bags do
    resources :import_bag_receivers, shallow: true
  end
  resources :promotion_discounts do
    get 'products/:product_id/:operat/:type' => :products, :on => :collection
  end

  post 'import_bags/:import_bag_id/import_bag_receivers/batch' => "import_bag_receivers#batch" #后台收礼人批量导入
  get 'import_bags/import_bag_receivers/down_templ' => "import_bag_receivers#down_templ" #后台收礼人批量导入down_templ
  get 'gift_bags/:import_bag_id/index' => "gift_bags#index" #后台导入礼包认领情况


  post 'import_bags/products/table/data/' => "import_bags#products_table_data"
  post 'import_bags/workflow/deal' => "import_bags#deal"
  get 'import_bags/workflow/deal_list' => "import_bags#deal_list"

  resources :delivery_users
  get 'delivery_users/:id/check' => "delivery_users#check"
  post 'delivery_users/:id/check_save' => "delivery_users#check_save"
  get 'delivery_users/:id/store_index' => "delivery_users#store_index"
  post 'delivery_users/:id/store_save' => "delivery_users#store_save"


  get 'activities/skipe_one_index/:id/:platform' => 'activities#skipe_one_index'
  get 'activities/skipe_one_search'
  get 'activities/full_reduction/:userinfo_id/:full_reduction_id/:platform' => 'activities#fullReductions'
  get 'activities/promotion_discount/:userinfo_id/:promotion_discount_id/:platform' => 'activities#promotionDiscount'
  get 'activities/coupons/:userinfo_id/:platform' => 'activities#coupons'
  get 'activities/promotions/:userinfo_id/:platform' => 'activities#promotions'
  get 'activities/discount/:userinfo_id/:platform' => 'activities#discount'

  resources :coupons do
    get :invalided
    get 'products/:product_id/:operat' => :products, :on => :collection
    get :selectProducts, :on => :collection
  end
  resources :carous do
    get 'downloadS', :on => :collection
  end


  resources :full_reductions do
    get 'products/:product_id/:operat' => :products, :on => :collection
    get 'coupons/:coupon_info/:operat' => :coupons, :on => :collection
    get 'giftProducts/:product_info/:operat' => :giftProducts, :on => :collection
  end

  resources :panic_buyings do
    get 'product_list', :on => :collection
    get 'product'
    get 'panic_table', :on => :collection

    post 'add_product'
    get 'remove_product'
  end

  resources :carousels do
    post 'upload'
    delete 'destroyAsset'
    get 'downloadAsset'
  end

  # get 'password_resets/new'
  #
  # get 'password_resets/edit'
  #
  # get 'password_resets/update'
  #
  # get 'password_resets/create'
  #

  mount RuCaptcha::Engine => "/rucaptcha"
  resources :userinfos do
    get 'audit', :on => :collection
    get 'email_active/:confirmation_token', :action => :email_active, :on => :collection

    post 'userinfo_edit'

    resources :products do
      get 'desc'

      get 'preview'
    end
  end

  get "/user_mailer/signup_confirmation", :as => "user_mailer"


  resources :statistics do
    post 'search', :on => :collection
  end
  resources :cashiers do
    post 'checkCustomer', :on => :collection
  end

  #订单相关路由
  resources :orders do
    resources :ordergoods
    post 'line_order_creat', :on => :collection
    get 'distribution_completed'
    get 'receive_order'

    get 'order_state_count', :on => :collection
    get 'orders_table_data', :on => :collection

    get 'statistic', :on => :collection
    get 'statisticData', :on => :collection
    post "wx_notify", :on => :member
    post "alipay_notify", :on => :member
    post "alipay_refund_notify", :on => :member
    post "alipay_dback_notify", :on => :member
  end


  resources :userinfo_orders do
    post 'binduserinfo', :on => :collection
    get 'getcode', :on => :collection
    get 'bind_form', :on => :collection
  end


  resources :announcements do
    get 'check'
    get 'check_out'
    post 'batch', :on => :collection
    get 'app_show'

    get 'warehouse_notice_index', :on => :collection
    get 'batch_check', :on => :collection
    get 'next_check', :on => :collection
    get 'next_check_out', :on => :collection
    get 'next_delete', :on => :collection
    post 'stow', :on => :collection
    post 'batch_delete', :on => :collection
  end

  resources :announcement_categories


  resources :pictures do
    post 'upload'
  end

  resources :categories


  devise_for :users, controllers: {
                       sessions: 'users/sessions',
                       registrations: 'users/registrations', #-----addby <dfj>
                   }


  devise_scope :user do
    get "users/sessions/password_reset", to: "users/sessions#password_reset"
    get "users/sessions/cheak_mobile", to: "users/sessions#cheak_mobile"
    get "users/send_message", to: "users/registrations#send_message"
    post "users/sessions/fix_password", to: "users/sessions#fix_password"
    post "users/mobile_sign_in", to: "users/mobile_sessions#create"
    post "users/mobile_sign_out", to: "users/mobile_sessions#destroy"
  end


  #root to: "userinfos#index"

  root to: "root#index"

  mount ElephantV1Api => '/api/v1/'

  mount Resque::Server.new, :at => "/resque"

  namespace :api do
    namespace :v1 do

      get 'products/find/:qrcode' => 'product#find'

      post 'user/register' => 'registrations#create'

      resources :products

    end
  end


  resources :products do

    get 'category_index', :on => :collection

    get 'demo', :on => :collection

    get 'demo_stress', :on => :collection

    post 'search', :on => :collection

    post 'searchByQrcode', :on => :collection

    get 'dataTablesProducts', :on => :collection

    post 'upload'

    post 'rack'

    get 'state'

    get 'page/:page', :action => :index, :on => :collection

    get 'warehouse_index', :on => :collection

    get 'statistic', :on => :collection
    get 'statisticData', :on => :collection

    get 'warehouse_show'
  end

  namespace :admin do
    post 'users/upload'
    resources :users
  end

  resources :mobile_categories


  resources :stores do
    get 'delivery_users'
    get 'add_delivery_user'
    delete 'reduce_delivery_user'
    post 'upload'
    get 'search', :on => :collection
  end


  resources :chateaus do
    get 'turn_picture'
    post 'turn_picture_add'
    delete 'turn_picture_reduce'
    post 'turn_picture_urls'
    get 'introduce_show'
    get 'chateau_mark'
    post 'chateau_mark_add'
    delete 'chateau_mark_reduce'
    get 'check'
    get 'check_out'
    get 'search', :on => :collection
    get 'wines'
    get 'workload', :on => :collection
    post 'relate_wine'
    get 'resolve_wine'
    get 'ex_pic', :on => :collection
    get 'batch_check', :on => :collection
    get 'next_check', :on => :collection
    get 'next_check_out', :on => :collection
  end
  resources :chateau_marks


  resources :chateau_comments do
  end
  post 'chateau_comments/add_comment' => 'chateau_comments#add_comment'
  post 'chateau_comments/hit' => 'chateau_comments#hit'
  resources :regions do
    get 'children'
    post 'add_children'
    delete 'reduce_children'
    post 'get_children'
  end
  resources :wines do
    post 'table', :on => :collection
    get 'turn_picture'
    post 'turn_picture_add'
    delete 'turn_picture_reduce'
    post 'turn_picture_urls'
    get 'introduce_show'
    get 'mark'
    post 'mark_add'
    delete 'mark_reduce'
    get 'check'
    get 'check_out'
    get 'search', :on => :collection
  end
  post 'ckeditor/pictures' => 'wines#upload'

  get 'share_integrals/share' => 'share_integrals#share'

  resources :share_integrals do
    post 'register'
    post 'share_time_check', :on => :collection
    resources :share_integral_records

  end




  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  get 'dashboards/index' => 'dashboards#index'
  post 'dashboards/store_order_data' => "dashboards#store_order_data"
  post 'dashboards/exposure_product_data' => "dashboards#exposure_product_data"
  post 'dashboards/sale_product_data' => "dashboards#sale_product_data"
  get 'common/create_qrcode_image' => "common#create_qrcode_image"
end
