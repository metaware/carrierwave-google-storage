# frozen_string_literal: true

module CarrierWave
  module Storage
    class Gcloud < Abstract
      def self.connection_cache
        @connection_cache ||= {}
      end

      def self.clear_connection_cache!
        @connection_cache = {}
      end

      def store!(file)
        GcloudFile.new(uploader, connection, uploader.store_path).tap do |gcloud_file|
          gcloud_file.store(file)
        end
      end

      def retrieve!(identifier)
        GcloudFile.new(uploader, connection, uploader.store_path(identifier))
      end

      def cache!(file)
        GcloudFile.new(uploader, connection, uploader.cache_path).tap do |gcloud_file|
          gcloud_file.store(file)
        end
      end

      def retrieve_from_cache!(identifier)
        GcloudFile.new(uploader, connection, uploader.cache_path(identifier))
      end

      def delete_dir!(path)
        # do nothing, because there's no such things as 'empty directory'
      end

      def clean_cache!(_seconds)
        raise 'use Object Lifecycle Management to clean the cache'
      end

      def connection
        @connection ||= begin
          conn_cache = self.class.connection_cache
          conn_cache[credentials] ||= ::Google::Cloud::Storage.new(
            project_id: credentials[:gcloud_project] || ENV['GCLOUD_PROJECT'],
            credentials: credentials[:gcloud_keyfile] || ENV['GCLOUD_KEYFILE']
          )
        end
      end

      def credentials
        uploader.gcloud_credentials || {}
      end
    end
  end
end
