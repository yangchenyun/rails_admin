module RailsAdmin
  module Config
    module Actions
      
      class << self
        
        def init_actions!
          @@actions ||= [
            Dashboard.new,
            Index.new,
            Show.new,
            New.new,
            Edit.new,
            Export.new,
            Delete.new,
            BulkDelete.new,
            HistoryShow.new,
            HistoryIndex.new,
            ShowInApp.new,
          ]
        end
        
        def all(scope = nil, bindings = {})
          if scope.is_a?(Hash)
            bindings = scope
            scope = :all
          end
          scope ||= :all
          init_actions!
          actions = case scope
          when :all
            @@actions
          when :root
            @@actions.select(&:root?)
          when :collection
            @@actions.select(&:collection?)
          when :bulkable
            @@actions.select(&:bulkable?)
          when :member
            @@actions.select(&:member?)
          end
          
          bindings[:controller] ? actions.map{ |action| action.with(bindings) }.select(&:visible?) : actions
        end
        
        def find custom_key, bindings = {}
          init_actions!
          action = @@actions.find{ |a| a.custom_key == custom_key }
          bindings[:controller] ? action && action.with(bindings).try(:visible?) && action : action
        end
        
        def register(name, klass = nil)
          if klass == nil && name.kind_of?(Class)
            klass = name
            name = klass.to_s.demodulize.underscore.to_sym
          end
        
          instance_eval %{
            def #{name}(&block)
              action = #{klass}.new
              action.instance_eval &block if block
              (@@actions ||= []) << action
              action
            end
          }
        end
      end
    end
  end
end

require 'rails_admin/config/actions/base'
require 'rails_admin/config/actions/dashboard'
require 'rails_admin/config/actions/index'
require 'rails_admin/config/actions/show'
require 'rails_admin/config/actions/show_in_app'
require 'rails_admin/config/actions/history_show'
require 'rails_admin/config/actions/history_index'
require 'rails_admin/config/actions/new'
require 'rails_admin/config/actions/edit'
require 'rails_admin/config/actions/export'
require 'rails_admin/config/actions/delete'
require 'rails_admin/config/actions/bulk_delete'

