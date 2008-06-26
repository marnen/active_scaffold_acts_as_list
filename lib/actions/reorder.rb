module ActiveScaffold::Actions
  module Reorder
    def self.included(base)
      base.before_filter :reorder_authorized?, :only => [:move]
      base.before_filter :reorder_add_links, :only => [:index, :table, :update_table, :row] + ActiveScaffold::Config::Reorder::MOTION_METHODS.keys
      
      as_aal_plugin_path = File.join(RAILS_ROOT, 'vendor', 'plugins', as_aal_plugin_name, 'frontends', 'default', 'views')
      
      if base.respond_to?(:generic_view_paths) && ! base.generic_view_paths.empty?
        base.generic_view_paths.insert(0, as_aal_plugin_path)
      else  
        config.inherited_view_paths << as_aal_plugin_path
      end
    end

    attr_accessor :record_for_security_method

    def self.as_aal_plugin_name
      # extract the name of the plugin as installed
      /.+vendor\/plugins\/(.+)\/lib/.match(__FILE__)
      plugin_name = $1
    end
    
    protected
    def reorder_move
      @item = active_scaffold_config.model.find(params[:id])

      method = ActiveScaffold::Config::Reorder::MOTION_METHODS[params[:action]]
      @item.insert_at unless @item.in_list?
      @item.send(method)
      do_list
      #render(:action => 'reorder_move.rjs', :layout => false)
      respond_to do |type|
        type.html do
          flash[:info] = as_('Reordered %s', @record.to_label)
          return_to_main
        end
        type.js { render(:action => 'reorder_move.rjs', :layout => false) }
        type.xml { render :xml => successful? ? "" : response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.json { render :text => successful? ? "" : response_object.to_json, :content_type => Mime::JSON, :status => response_status }
        type.yaml { render :text => successful? ? "" : response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end

    ActiveScaffold::Config::Reorder::MOTION_METHODS.keys.each do |key|
      alias_method key.to_sym, :reorder_move
      public key.to_sym
    end

    def reorder_add_links
      if reorder_enabled?
        %w{top up down bottom}.each do |motion|
          active_scaffold_config.action_links.add "reorder_#{motion}",
            :parameters => {:eval_label => "image_tag('active_scaffold/default/reorder_#{motion}.png', :size => '16x16', :alt => '#{motion.capitalize}', :title => '#{motion.capitalize}')"},
            :type => :record, :position => false, :method => :post
        end
      end
    end

    def reorder_enabled?
      active_scaffold_config.model.instance_methods.include? 'acts_as_list_class'
    end

    def reorder_authorized?
      authorized_for?(:action => :update)
    end
  end
end
