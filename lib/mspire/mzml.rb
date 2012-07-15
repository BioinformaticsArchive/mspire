

# TODO: trim down these require statements to only include upper level
require 'mspire'
require 'builder'
require 'nokogiri'
require 'io/bookmark'
require 'zlib'

require 'core_ext/enumerable'
require 'mspire/mzml/parser'
require 'mspire/mzml/index_list'
require 'mspire/mzml/index'
require 'mspire/mzml/spectrum'
require 'mspire/mzml/chromatogram'
require 'mspire/mzml/file_description'
require 'mspire/mzml/software'
require 'mspire/mzml/scan_list'
require 'mspire/mzml/selected_ion'
require 'mspire/mzml/scan'
require 'mspire/mzml/scan_settings'
require 'mspire/mzml/processing_method'
require 'mspire/mzml/run'
require 'mspire/mzml/spectrum_list'
require 'mspire/mzml/chromatogram_list'
require 'mspire/mzml/instrument_configuration'
require 'mspire/mzml/data_processing'
require 'mspire/mzml/referenceable_param_group'
require 'mspire/mzml/cv'
require 'mspire/mzml/sample'

module Mspire
  # Reading an mzml file:
  #
  #     Mspire::Mzml.open("somefile.mzML") do |mzml|
  #       mzml.each do |spectrum|
  #         scan = spectrum.scan
  #         spectrum.mzs                  # array of m/zs
  #         spectrum.intensities          # array of intensities
  #         spectrum.peaks do |mz,intensity|
  #           puts "mz: #{mz} intensity: #{intensity}" 
  #         end
  #       end
  #     end
  #
  # Note that the mzml object supports random spectrum access (even if the
  # mzml was not indexed):
  #
  #     mzml[22]  # retrieve spectrum at index 22
  #
  # Writing an mzml file from scratch:
  #
  #     spec1 = Mspire::Mzml::Spectrum.new('scan=1', params: ['MS:1000127', ['MS:1000511', 1]]) do |spec|
  #       spec.data_arrays = [[1,2,3], [4,5,6]]
  #       spec.scan_list = Mspire::Mzml::ScanList.new do |sl|
  #         scan = Mspire::Mzml::Scan.new do |scan|
  #           # retention time of 40 seconds
  #           scan.describe! ['MS:1000016', 40.0, 'UO:0000010']
  #         end
  #         sl << scan
  #       end
  #     end
  #
  #     mzml = Mspire::Mzml.new do |mzml|
  #       mzml.id = 'the_little_example'
  #       mzml.cvs = Mspire::Mzml::CV::DEFAULT_CVS
  #       mzml.file_description = Mspire::Mzml::FileDescription.new  do |fd|
  #         fd.file_content = Mspire::Mzml::FileContent.new
  #         fd.source_files << Mspire::Mzml::SourceFile.new
  #       end
  #       default_instrument_config = Mspire::Mzml::InstrumentConfiguration.new("IC",[], params: ['MS:1000031'])
  #       mzml.instrument_configurations << default_instrument_config
  #       software = Mspire::Mzml::Software.new
  #       mzml.software_list << software
  #       default_data_processing = Mspire::Mzml::DataProcessing.new("did_nothing")
  #       mzml.data_processing_list << default_data_processing
  #       mzml.run = Mspire::Mzml::Run.new("little_run", default_instrument_config) do |run|
  #         spectrum_list = Mspire::Mzml::SpectrumList.new(default_data_processing)
  #         spectrum_list.push(spec1)
  #         run.spectrum_list = spectrum_list
  #       end
  #     end
  class Mzml
    include Enumerable  # each_spectrum

    class << self
      # read-only right now
      def open(filename, &block)
        File.open(filename) do |io|
          block.call(self.new(io))
        end
      end

      def foreach(filename, &block)
        block or return enum_for(__method__, filename)
        open(filename) do |mzml|
          mzml.each(&block)
        end
      end
    end

    module Default
      NAMESPACE = {
        :xmlns => "http://psi.hupo.org/ms/mzml",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", 
        "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema", 
      }

      VERSION = '1.1.0'
    end

    ###############################################
    # ATTRIBUTES
    ###############################################

    # (optional) an id for accessing from external files
    attr_accessor :id
   
    # (required) the Mzml document version
    attr_accessor :version

    # (optional) e.g. a PRIDE accession number
    attr_accessor :accession

    ###############################################
    # SUBELEMENTS
    ###############################################

    # (required) an array of Mspire::Mzml::CV objects
    attr_accessor :cvs

    # (required) an Mspire::Mzml::FileDescription
    attr_accessor :file_description

    # (optional) an array of CV::ReferenceableParamGroup objects
    attr_accessor :referenceable_param_groups

    # (optional) an array of Mspire::Mzml::Sample objects
    attr_accessor :samples

    # (required) an array of Mspire::Mzml::Software objects 
    attr_accessor :software_list

    # (optional) an array of Mspire::Mzml::ScanSettings objects
    attr_accessor :scan_settings_list

    # (required) an array of Mspire::Mzml::InstrumentConfiguration objects
    attr_accessor :instrument_configurations

    # (required) an array of Mspire::Mzml::DataProcessing objects
    attr_accessor :data_processing_list

    # (required) an Mspire::Mzml::Run object
    attr_accessor :run

    # the io object of the mzml file
    attr_accessor :io

    # Mspire::Mzml::IndexList object associated with the file (only expected when reading
    # mzml files at the moment)
    attr_accessor :index_list

    # xml file encoding
    attr_accessor :encoding


    # arg must be an IO object for automatic index and header parsing to
    # occur.  If arg is a hash, then attributes are set.  In addition (or
    # alternatively) a block called that yields self to setup the object.
    #
    # io must respond_to?(:size), giving the size of the io object in bytes
    # which allows seeking.  get_index_list is called to get or create the
    # index list.
    def initialize(arg=nil, &block)
      %w(cvs software_list instrument_configurations data_processing_list).each {|guy| self.send( guy + '=', [] ) }

      case arg
      when IO
        @io = arg
        begin
          @encoding = @io.bookmark(true) {|io| io.readline.match(/encoding=["'](.*?)["']/)[1] }
        rescue EOFError
          raise RuntimeError, "no encoding present in XML!  (Is this even an xml file?)"
        end
        @index_list = Mspire::Mzml::IndexList.from_io(@io)
        read_header!( get_default_data_processing_ids(@io, @index_list) )
      when Hash
        arg.each {|k,v| self.send("#{k}=", v) }
      end
      block.call(self) if block
    end

    # returns a hash keyed by :spectrum or :chromatogram that gives the id
    # (aka ref) as a string.
    def get_default_data_processing_ids(io, index_list, lookback=200)
      hash = {}
      index_list.each_pair do |name, index|
        io.bookmark do |io|
          io.pos = index[0] - lookback 
          hash[name] = io.read(lookback)[/<#{name}List.*defaultDataProcessingRef=['"](.*?)['"]/m, 1]
        end
      end
      hash
    end

    # saves ~ 3 seconds when reading a 83M mzML file to scrape off the
    # header string (even though we're just handing in an IO object to
    # Nokogiri::XML::Document.parse and we are very careful to not parse too
    # far).
    def get_header_string(io)
      chunk_size = 2**12
      loc = 0
      string = ''
      while chunk = @io.read(chunk_size)
        string << chunk
        start_looking = ((loc-20) < 0) ? 0 : (loc-20)
        break if string[start_looking..-1] =~ /<(spectrum|chromatogram)/
          loc += chunk_size
      end
      string
    end

    # list_to_default_data_processing_id is a hash keyed by :spectrum or
    # :chromatogram that gives the default data_processing_object for the
    # SpectrumList and/or the ChromatogramList.  This information is not
    # obtainable from the header string, so must be pre-obtained.
    def read_header!(list_to_default_data_processing_id)
      @io.rewind

      string = get_header_string(@io)
      doc = Nokogiri::XML.parse(string, nil, @encoding, Parser::NOBLANKS)

      doc.remove_namespaces!
      mzml_n = doc.root
      if mzml_n.name == 'indexedmzML'
        mzml_n = mzml_n.child
      end
      cv_list_n = mzml_n.child
      self.cvs = cv_list_n.children.map do |cv_n|
        Mspire::Mzml::CV.from_xml(cv_n)
      end

      # get the file description node but deal with it after getting ref_hash
      file_description_n = cv_list_n.next

      xml_n = file_description_n.next

      # a hash of referenceable_param_groups indexed by id
      ref_hash = {}

      loop do
        case xml_n.name
        when 'referenceableParamGroupList'
          self.referenceable_param_groups = xml_n.children.map do |rpg_n|
            Mspire::Mzml::ReferenceableParamGroup.from_xml(rpg_n)
          end
          ref_hash = self.referenceable_param_groups.index_by(&:id)
          # now we can set the file description because we have the ref_hash
          self.file_description = Mspire::Mzml::FileDescription.from_xml(file_description_n, ref_hash)
        when 'sampleList'
          self.samples = xml_n.children.map do |sample_n|
            Mspire::Mzml::Sample.from_xml(sample_n, ref_hash)
          end
        when 'softwareList'  # required
          self.software_list = xml_n.children.map do |software_n|
            Mspire::Mzml::Software.from_xml(software_n, ref_hash)
          end
        when 'instrumentConfigurationList'
          self.instrument_configurations = xml_n.children.map do |inst_config_n|
            Mspire::Mzml::InstrumentConfiguration.from_xml(inst_config_n, ref_hash)
          end
        when 'dataProcessingList'
          self.data_processing_list = xml_n.children.map do |data_processing_n|
            Mspire::Mzml::DataProcessing.from_xml(data_processing_n, ref_hash, self.software_list.index_by(&:id))
          end
        when 'run'
          source_files = self.file_description.source_files
          source_file_hash = (source_files.size > 0)  ?  source_files.index_by(&:id)  :  {}

          samples = self.samples || []
          sample_hash = (samples.size > 0)  ?  samples.index_by(&:id)  :  {}

          list_to_default_data_processing = {}
          list_to_default_data_processing_id.each do |key,id|
            list_to_default_data_processing[key] = self.data_processing_list.find {|dp| dp.id == id }
          end

          self.run = Mspire::Mzml::Run.from_xml(@io, xml_n, ref_hash, @index_list, self.instrument_configurations.index_by(&:id), source_file_hash, sample_hash, list_to_default_data_processing)
          break
        end
        xml_n = xml_n.next
      end
    end

    module Convenience
      def each_chromatogram(&block)
        @run.chromatogram_list.each(&block)
      end

      def each_spectrum(&block)
        @run.spectrum_list.each(&block)
      end

      alias_method :each, :each_spectrum

      # @param [Object] arg an index number (Integer) or id string (String)
      # @return [Mspire::Mzml::Spectrum] a spectrum object
      def spectrum(arg)
        run.spectrum_list[arg]
      end
      alias_method :'[]', :spectrum

      # @param [Object] arg an index number (Integer) or id string (String)
      # @return [Mspire::Mzml::Chromatogram] a spectrum object
      def chromatogram(arg)
        run.chromatogram_list[arg]
      end

      def num_chromatograms
        run.chromatogram_list.size
      end

      # returns the number of spectra
      def length
        run.spectrum_list.size
      end
      alias_method :size, :length

      # @param [Integer] scan_num the scan number 
      # @return [Mspire::Spectrum] a spectrum object, or nil if not found
      # @raise [ScanNumbersNotUnique] if scan numbers are not unique
      # @raise [ScanNumbersNotFound] if spectra exist but scan numbers were not
      #   found
      def spectrum_from_scan_num(scan_num)
        @scan_to_index ||= @index_list[0].create_scan_index
        raise ScanNumbersNotUnique if @scan_to_index == false
        raise ScanNumbersNotFound if @scan_to_index == nil
        spectrum(@scan_to_index[scan_num])
      end
    end
    include Convenience
    
    # Because mzml files are often very large, we try to avoid storing the
    # entire object tree in memory before writing.
    # 
    # takes a filename and uses builder to write to it
    # if no filename is given, returns a string
    def to_xml(filename=nil)
      # TODO: support indexed mzml files
      io = filename ? File.open(filename, 'w') : StringIO.new
      xml = Builder::XmlMarkup.new(:target => io, :indent => 2)
      xml.instruct!

      mzml_atts = Default::NAMESPACE.dup
      mzml_atts[:version] = @version || Default::VERSION
      mzml_atts[:accession] = @accession if @accession
      mzml_atts[:id] = @id if @id

      xml.mzML(mzml_atts) do |mzml_n|
        # the 'if' statements capture whether or not the list is required or not
        raise "#{self.class}#cvs must have > 0 Mspire::Mzml::CV objects" unless @cvs.size > 0 
        Mspire::Mzml::CV.list_xml(@cvs, mzml_n)
        @file_description.to_xml(mzml_n)
        if @referenceable_param_groups
          Mspire::Mzml::ReferenceableParamGroup.list_xml(@referenceable_param_groups, mzml_n)
        end
        if @samples
          Mspire::Mzml::Sample.list_xml(@samples, mzml_n)
        end
        Mspire::Mzml::Software.list_xml(@software_list, mzml_n)
        if @scan_settings_list && @scan_settings_list.size > 0
          Mspire::Mzml::ScanSettings.list_xml(@scan_settings_list, mzml_n)
        end
        icl = Mspire::Mzml::InstrumentConfiguration.list_xml(@instrument_configurations, mzml_n)
        Mspire::Mzml::DataProcessing.list_xml(@data_processing_list, mzml_n)
        @run.to_xml(mzml_n)
      end
      
      if filename
        io.close 
        self
      else
        io.string
      end
    end

    class ScanNumbersNotUnique < Exception
    end
    class ScanNumbersNotFound < Exception
    end
  end
end

