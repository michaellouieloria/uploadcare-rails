require "uploadcare/rails/file"

module Uploadcare
  module Rails
    module ActiveRecord
      def has_uploadcare_file attribute, options={}
  
        define_method "has_#{attribute}_as_uploadcare_file?" do
          true
        end

        define_method "has_#{attribute}_as_uploadcare_group?" do
          false
        end

        # attribute method - return file object
        # it is not the ::File but ::Rails::File
        # it has some helpers for rails enviroment
        # but it also has all the methods of Uploadcare::File so no worries.
        define_method "#{attribute}" do
          cdn_url = attributes[attribute.to_s].to_s
          
          return nil if cdn_url.empty?
          # api = UPLOADCARE_SETTINGS.api

          # binding.pry
          api = UPLOADCARE_SETTINGS.api
          file = Uploadcare::Rails::File.new api, cdn_url
          
          # file = ::Rails.cache.fetch cdn_url, expires_in: 1.minute do 
          #   api = UPLOADCARE_SETTINGS.api
          #   file = Uploadcare::Rails::File.new api, cdn_url
          # end

          # binding.pry
          # if ::Rails.cache.exist?(cdn_url)
          #   file = ::Rails.cache.read(cdn_url)
          # else
          #   api = UPLOADCARE_SETTINGS.api
          #   file = Uploadcare::Rails::File.new api, cdn_url
          # end
        end

        # before saving we checking what it is a actually file cdn url
        # or uuid. uuid will do.
        # group url or uuid should raise an erorr
        before_save "check_#{attribute}_for_uuid"

        define_method "check_#{attribute}_for_uuid" do
          url = self.attributes[attribute.to_s]
          unless url.empty?
            result = Uploadcare::Parser.parse(url)
            raise "Invalid Uploadcare file uuid" unless result.is_a?(Uploadcare::Parser::File)
          end
        end
      end
    end
  end
end

ActiveRecord::Base.extend Uploadcare::Rails::ActiveRecord