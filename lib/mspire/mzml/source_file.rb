require 'mspire/cv/paramable'
require 'mspire/mzml/list'
require 'pathname'

module Mspire
  class Mzml
    class SourceFile
      include Mspire::CV::Paramable

      DEFAULT_SOURCEFILE_ID = 'sourcefile1'

      # (required) An identifier for this file.
      attr_accessor :id
      # (required) Name of the source file, without reference to location
      # (either URI or local path).
      attr_accessor :name
      # (required) URI-formatted location where the file was retrieved.
      attr_accessor :location

      # expands the path and sets the name and location
      def self.[](path, opts={})
        self.new DEFAULT_SOURCEFILE_ID, *uri_basename_and_path(path)
      end

      # takes a filename (with a relative or expanded path) and returns the
      # uri basename and path suitable for mzml files
      def self.uri_basename_and_path(file)
        pathname = Pathname.new(file)
        dir = pathname.expand_path.dirname.to_s
        dir = '/'+dir unless (dir[0] == '/')
        [pathname.basename, 'file://'+ dir]
      end

      def initialize(id="sourcefile1", name="mspire-simulated", location='file://', opts={params: []}, &block)
        @id, @name, @location = id, name, location
        describe!(*opts[:params])
        block.call(self) if block
      end

      def to_xml(builder)
        builder.sourceFile( id: @id, name: @name, location: @location ) do |sf_n|
          super(sf_n)
        end
        builder
      end

      extend(Mspire::Mzml::List)
    end
  end
end