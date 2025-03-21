Rails.application.routes.draw do
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

  root 'application#index'

  get 'download_stock_card_pdf/:pr_number' => 'projects#download_stock_card_pdf'
  get 'download_stock_card_pdf/:pr_number/:po_number' => 'projects#download_stock_card_pdf'
  get 'download_prs_report_pdf/:pr_number' => 'projects#download_prs_report_pdf'
  get 'download_cert_of_delivery_report_pdf/:pr_number' => 'purchase_orders#download_cert_of_delivery_report_pdf'
  get 'download_po_pdf/:id' => 'purchase_orders#download_po_pdf'
  get 'download_ris_pdf/:id' => 'req_issued_slip#download_ris_pdf'
  get 'download_items_stock_card_pdf' => 'item_masterlists#download_items_stock_card_pdf'
  get 'download_items_stock_card_on_hand_pdf' => 'item_masterlists#download_items_stock_card_on_hand_pdf'
  get 'download-saving-savings-report' => 'savings#savings_report'
  get 'download-endorsement-ceo-pdf' => 'endorsement_ceos#download_pdf'

  scope 'api', defaults: { format: 'json' } do
    get 'user_access' => 'application#user_access', as: :user_access
    post 'login' => 'user_sessions#create', as: :login
    post 'logout' => 'user_sessions#destroy', as: :logout
    get 'user_details' => 'user_sessions#get_user_details', as: :user_details

    resources :application do
      get :is_admin, on: :collection
      #get :is_spectator, on: :collection
    end

    resources :departments, only: [:index, :create]
    resources :department_divisions, only: [:index]
    resources :system_roles, only: [:index]
    resources :enroll_users, only: [:create]
    resources :supplies, only: [:index, :create]
    resources :mode_of_procurements, only: [:index, :create]

    resources :item_masterlists, only: [:index, :create, :edit, :update] do
      collection do
        get :get_item_description
        post :set_on_hand_count
      end
    end

    resources :purchase_orders, only: [:index, :create, :show, :edit, :update] do
      get :cert_of_delivery, on: :collection
      get :check_project_completion, on: :collection
      get :po_stack_card, on: :collection
    end

    resources :inspectors, only: [:index]
    resources :units, only: [:index, :create]

    resources :suppliers, only: [:index, :create, :show, :edit, :update] do
      get :get_names, on: :collection
    end

    resources :req_issued_slip, only: [:index, :create, :show, :edit, :update, :destroy] do
      collection do
        get :source_items
        get :source_savings_items
        get :autonumber
        get :get_approvers
        get :get_issuers
        get :get_receivers
        get :check_project_completion
      end
    end

    resources :savings, only: [] do
      get :per_project, on: :collection
      get :per_item, on: :collection
    end

    resources :warehousemen, only: [:index]

    resources :stocks, only: [:destroy] do
      post :validate_item, on: :collection
      get :has_dependents, on: :collection
    end

    resources :home, only: [:index]

    resources :projects, only: [:index, :create, :edit, :update] do
      collection do
        get :get_project_detail
        get :get_in_charge
        get :stock_card
        get :prs_content
        post :save_prs
        get :prs_present
        get :po_collection
        post :get_projects_pos
      end
    end

    resources :endorsements, only: [:index, :create, :show, :update] do
      collection do
        get :get_pow_data
        get :get_project_pos
        post :remove_project
        get :download_pdf
        get :is_endorsed
      end
    end


    resources :endorsement_pos, only: [:index, :create, :show, :update] do
      collection do
        get :get_project_pos
        post :unendorse_po
        post :endorse_po
        get :download_pdf
      end
    end


    resources :endorsement_ceos, only: [:index, :create, :show, :update] do
      collection do
        get :get_pow_data
        post :remove_project
        get :unendorse_ceo_projects
      end
    end

    resources :project_in_charges, only: [:index, :create] do
      get :get_designation, on: :collection
    end

    resources :stock_card, only: [:show] do
      get :filter_incomings, on: :collection
    end

    resources :change_logs, only: [:create] do
      get :get_logs, on: :collection
    end
  end


  # must be declared after api to prevent
  # format render problem.
  get "*path.html" => "application#index", :layout => 0
  get  '*path' => 'application#index'

end
