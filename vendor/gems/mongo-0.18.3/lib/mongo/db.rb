# --
# Copyright (C) 2008-2009 10gen Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ++

require 'socket'
require 'timeout'
require 'digest/md5'
require 'thread'

module Mongo

  # A MongoDB database.
  class DB

    SYSTEM_NAMESPACE_COLLECTION = "system.namespaces"
    SYSTEM_INDEX_COLLECTION = "system.indexes"
    SYSTEM_PROFILE_COLLECTION = "system.profile"
    SYSTEM_USER_COLLECTION = "system.users"
    SYSTEM_COMMAND_COLLECTION = "$cmd"

    # Counter for generating unique request ids.
    @@current_request_id = 0

    # Strict mode enforces collection existence checks. When +true+,
    # asking for a collection that does not exist, or trying to create a
    # collection that already exists, raises an error.
    #
    # Strict mode is disabled by default, but enabled (+true+) at any time.
    attr_writer :strict

    # Returns the value of the +strict+ flag.
    def strict?; @strict; end

    # The name of the database.
    attr_reader :name

    # The Mongo::Connection instance connecting to the MongoDB server.
    attr_reader :connection

    # Instances of DB are normally obtained by calling Mongo#db.
    #
    # @param [String] db_name the database name.
    # @param [Mongo::Connection] connection a connection object pointing to MongoDB. Note
    #   that databases are usually instantiated via the Connection class. See the examples below.
    #
    # @option options [Boolean] strict (False) If true, collections must exist to be accessed and must
    #   not exist to be created. See DB#collection and DB#create_collection.
    #
    # @option options [Object, #create_pk(doc)] pk (Mongo::ObjectID) A primary key factory object,
    #   which should take a hash and return a hash which merges the original hash with any primary key
    #   fields the factory wishes to inject. (NOTE: if the object already has a primary key,
    #   the factory should not inject a new key).
    def initialize(db_name, connection, options={})
      @name       = validate_db_name(db_name)
      @connection = connection
      @strict     = options[:strict]
      @pk_factory = options[:pk]
    end

    # Authenticate with the given username and password. Note that mongod
    # must be started with the --auth option for authentication to be enabled.
    #
    # @param [String] username
    # @param [String] password
    #
    # @return [Boolean]
    def authenticate(username, password)
      doc = command(:getnonce => 1)
      raise "error retrieving nonce: #{doc}" unless ok?(doc)
      nonce = doc['nonce']

      auth = OrderedHash.new
      auth['authenticate'] = 1
      auth['user'] = username
      auth['nonce'] = nonce
      auth['key'] = Digest::MD5.hexdigest("#{nonce}#{username}#{hash_password(username, password)}")
      ok?(command(auth))
    end

    # Deauthorizes use for this database for this connection.
    #
    # @raise [MongoDBError] if logging out fails.
    #
    # @return [Boolean]
    def logout
      doc = command(:logout => 1)
      return true if ok?(doc)
      raise MongoDBError, "error logging out: #{doc.inspect}"
    end

    # Get an array of collection names in this database.
    #
    # @return [Array]
    def collection_names
      names = collections_info.collect { |doc| doc['name'] || '' }
      names = names.delete_if {|name| name.index(@name).nil? || name.index('$')}
      names.map {|name| name.sub(@name + '.', '')}
    end

    # Get an array of Collection instances, one for each collection in this database.
    #
    # @return [Array<Mongo::Collection>]
    def collections
      collection_names.map do |collection_name|
        Collection.new(self, collection_name)
      end
    end

    # Get info on system namespaces (collections). This method returns
    # a cursor which can be iterated over. For each collection, a hash
    # will be yielded containing a 'name' string and, optionally, an 'options' hash.
    #
    # @param [String] coll_name return info for the specifed collection only.
    #
    # @return [Mongo::Cursor]
    def collections_info(coll_name=nil)
      selector = {}
      selector[:name] = full_collection_name(coll_name) if coll_name
      Cursor.new(Collection.new(self, SYSTEM_NAMESPACE_COLLECTION), :selector => selector)
    end

    # Create a collection.
    #
    # new collection. If +strict+ is true, will raise an error if
    # collection +name+ already exists.
    #
    # @param [String] name the name of the new collection.
    #
    # @option options [Boolean] :capped (False) created a capped collection.
    #
    # @option options [Integer] :size (Nil) If +capped+ is +true+, specifies the maximum number of
    #   bytes for the capped collection. If +false+, specifies the number of bytes allocated
    #   for the initial extent of the collection.
    #
    # @option options [Integer] :max (Nil) If +capped+ is +true+, indicates the maximum number of records 
    #   in a capped collection.
    #
    # @raise [MongoDBError] raised under two conditions: either we're in +strict+ mode and the collection
    #   already exists or collection creation fails on the server.
    #
    # @return [Mongo::Collection]
    def create_collection(name, options={})
      # Does the collection already exist?
      if collection_names.include?(name)
        if strict?
          raise MongoDBError, "Collection #{name} already exists. Currently in strict mode."
        else
          return Collection.new(self, name)
        end
      end

      # Create a new collection.
      oh = OrderedHash.new
      oh[:create] = name
      doc = command(oh.merge(options || {}))
      ok = doc['ok']
      return Collection.new(self, name, @pk_factory) if ok.kind_of?(Numeric) && (ok.to_i == 1 || ok.to_i == 0)
      raise MongoDBError, "Error creating collection: #{doc.inspect}"
    end

    # @deprecated all the admin methods are now included in the DB class.
    def admin
      warn "DB#admin has been DEPRECATED. All the admin functions are now available in the DB class itself."
      Admin.new(self)
    end

    # Get a collection by name.
    #
    # @param [String] name the collection name.
    #
    # @raise [MongoDBError] if collection does not already exist and we're in +strict+ mode.
    #
    # @return [Mongo::Collection]
    def collection(name)
      return Collection.new(self, name, @pk_factory) if !strict? || collection_names.include?(name)
      raise MongoDBError, "Collection #{name} doesn't exist. Currently in strict mode."
    end
    alias_method :[], :collection

    # Drop a collection by +name+.
    #
    # @param [String] name
    #
    # @return [Boolean] True on success or if the collection names doesn't exist.
    def drop_collection(name)
      return true unless collection_names.include?(name)

      ok?(command(:drop => name))
    end

    # Get the error message from the most recently executed database
    # operation for this connection.
    #
    # @return [String, Nil] either the text describing the error or nil if no 
    #   error has occurred.
    def error
      doc = command(:getlasterror => 1)
      raise MongoDBError, "error retrieving last error: #{doc}" unless ok?(doc)
      doc['err']
    end

    # Get status information from the last operation on this connection.
    #
    # @return [Hash] a hash representing the status of the last db op.
    def last_status
      command(:getlasterror => 1)
    end

    # Return +true+ if an error was caused by the most recently executed
    # database operation.
    #
    # @return [Boolean]
    def error?
      error != nil
    end

    # Get the most recent error to have occured on this database.
    #
    # This command only returns errors that have occured since the last call to
    # DB#reset_error_history - returns +nil+ if there is no such error.
    #
    # @return [String, Nil] the text of the error or +nil+ if no error has occurred.
    def previous_error
      error = command(:getpreverror => 1)
      if error["err"]
        error
      else
        nil
      end
    end

    # Reset the error history of this database
    #
    # Calls to DB#previous_error will only return errors that have occurred
    # since the most recent call to this method.
    #
    # @return [Hash]
    def reset_error_history
      command(:reseterror => 1)
    end

    # @deprecated please use Collection#find to create queries.
    #
    # Returns a Cursor over the query results.
    #
    # Note that the query gets sent lazily; the cursor calls
    # Connection#send_message when needed. If the caller never requests an
    # object from the cursor, the query never gets sent.
    def query(collection, query, admin=false)
      Cursor.new(self, collection, query, admin)
    end

    # Dereference a DBRef, returning the document it points to.
    #
    # @param [Mongo::DBRef] dbref
    #
    # @return [Hash] the document indicated by the db reference.
    #
    # @see http://www.mongodb.org/display/DOCS/DB+Ref MongoDB DBRef spec.
    def dereference(dbref)
      collection(dbref.namespace).find_one("_id" => dbref.object_id)
    end

    # Evaluate a JavaScript expression in MongoDB.
    #
    # @param [String, Code] code a JavaScript expression to evaluate server-side.
    # @param [Integer, Hash] args any additional argument to be passed to the +code+ expression when 
    #   it's run on the server.
    #
    # @return [String] the return value of the function.
    def eval(code, *args)
      if not code.is_a? Code
        code = Code.new(code)
      end

      oh = OrderedHash.new
      oh[:$eval] = code
      oh[:args] = args
      doc = command(oh)
      return doc['retval'] if ok?(doc)
      raise OperationFailure, "eval failed: #{doc['errmsg']}"
    end

    # Rename a collection.
    #
    # @param [String] from original collection name.
    # @param [String] to new collection name.
    #
    # @return [True] returns +true+ on success.
    # 
    # @raise MongoDBError if there's an error renaming the collection.
    def rename_collection(from, to)
      oh = OrderedHash.new
      oh[:renameCollection] = "#{@name}.#{from}"
      oh[:to] = "#{@name}.#{to}"
      doc = command(oh, true)
      ok?(doc) || raise(MongoDBError, "Error renaming collection: #{doc.inspect}")
    end

    # Drop an index from a given collection. Normally called from
    # Collection#drop_index or Collection#drop_indexes.
    #
    # @param [String] collection_name
    # @param [String] index_name
    #
    # @return [True] returns +true+ on success.
    #
    # @raise MongoDBError if there's an error renaming the collection.
    def drop_index(collection_name, index_name)
      oh = OrderedHash.new
      oh[:deleteIndexes] = collection_name
      oh[:index] = index_name
      doc = command(oh)
      ok?(doc) || raise(MongoDBError, "Error with drop_index command: #{doc.inspect}")
    end

    # Get information on the indexes for the given collection.
    # Normally called by Collection#index_information.
    #
    # @param [String] collection_name
    #
    # @return [Hash] keys are index names and the values are lists of [key, direction] pairs
    #   defining the index.
    def index_information(collection_name)
      sel = {:ns => full_collection_name(collection_name)}
      info = {}
      Cursor.new(Collection.new(self, SYSTEM_INDEX_COLLECTION), :selector => sel).each { |index|
        info[index['name']] = index['key'].map {|k| k}
      }
      info
    end

    # Create a new index on the given collection.
    # Normally called by Collection#create_index.
    #
    # @param [String] collection_name
    # @param [String, Array] field_or_spec either either a single field name
    #   or an array of [field name, direction] pairs. Directions should be specified as
    #   Mongo::ASCENDING or Mongo::DESCENDING.
    # @param [Boolean] unique if +true+, the created index will enforce a uniqueness constraint.
    #
    # @return [String] the name of the index created.
    def create_index(collection_name, field_or_spec, unique=false)
      self.collection(collection_name).create_index(field_or_spec, unique)
    end

    # Return +true+ if the supplied +doc+ contains an 'ok' field with the value 1.
    #
    # @param [Hash] doc
    #
    # @return [Boolean]
    def ok?(doc)
      ok = doc['ok']
      ok.kind_of?(Numeric) && ok.to_i == 1
    end

    # Send a command to the database.
    #
    # Note: DB commands must start with the "command" key. For this reason,
    # any selector containing more than one key must be an OrderedHash.
    #
    # It may be of interest hat a command in MongoDB is technically a kind of query 
    # that occurs on the system command collection ($cmd).
    #
    # @param [OrderedHash, Hash] selector an OrderedHash, or a standard Hash with just one
    # key, specifying the command to be performed.
    #
    # @param [Boolean] admin If +true+, the command will be executed on the admin
    # collection.
    #
    # @param [Boolean] check_response If +true+, will raise an exception if the
    # command fails.
    #
    # @param [Socket] sock a socket to use. This is mainly for internal use.
    #
    # @return [Hash]
    def command(selector, admin=false, check_response=false, sock=nil)
      raise MongoArgumentError, "command must be given a selector" unless selector.is_a?(Hash) && !selector.empty?
      if selector.class.eql?(Hash) && selector.keys.length > 1
        raise MongoArgumentError, "DB#command requires an OrderedHash when hash contains multiple keys"
      end

      result = Cursor.new(system_command_collection, :admin => admin,
        :limit => -1, :selector => selector, :socket => sock).next_document

      if check_response && !ok?(result)
        raise OperationFailure, "Database command '#{selector.keys.first}' failed."
      else
        result
      end
    end

    # @deprecated please use DB#command instead.
    def db_command(*args)
      warn "DB#db_command has been DEPRECATED. Please use DB#command instead."
      command(args[0], args[1])
    end

    # A shortcut returning db plus dot plus collection name.
    #
    # @param [String] collection_name
    #
    # @return [String]
    def full_collection_name(collection_name)
      "#{@name}.#{collection_name}"
    end

    # The primary key factory object (or +nil+).
    #
    # @return [Object, Nil]
    def pk_factory
      @pk_factory
    end

    # Specify a primary key factory if not already set.
    #
    # @raise [MongoArgumentError] if the primary key factory has already been set.
    def pk_factory=(pk_factory)
      if @pk_factory
        raise MongoArgumentError, "Cannot change primary key factory once it's been set"
      end

      @pk_factory = pk_factory
    end

    # Return the current database profiling level. If profiling is enabled, you can
    # get the results using DB#profiling_info.
    #
    # @return [Symbol] :off, :slow_only, or :all
    def profiling_level
      oh = OrderedHash.new
      oh[:profile] = -1
      doc = command(oh)
      raise "Error with profile command: #{doc.inspect}" unless ok?(doc) && doc['was'].kind_of?(Numeric)
      case doc['was'].to_i
      when 0
        :off
      when 1
        :slow_only
      when 2
        :all
      else
        raise "Error: illegal profiling level value #{doc['was']}"
      end
    end

    # Set this database's profiling level. If profiling is enabled, you can
    # get the results using DB#profiling_info.
    #
    # @param [Symbol] level acceptable options are +:off+, +:slow_only+, or +:all+.
    def profiling_level=(level)
      oh = OrderedHash.new
      oh[:profile] = case level
                     when :off
                       0
                     when :slow_only
                       1
                     when :all
                       2
                     else
                       raise "Error: illegal profiling level value #{level}"
                     end
      doc = command(oh)
      ok?(doc) || raise(MongoDBError, "Error with profile command: #{doc.inspect}")
    end

    # Get the current profiling information.
    #
    # @return [Array] a list of documents containing profiling information.
    def profiling_info
      Cursor.new(Collection.new(self, DB::SYSTEM_PROFILE_COLLECTION), :selector => {}).to_a
    end

    # Validate a named collection.
    #
    # @param [String] name the collection name.
    #
    # @return [Hash] validation information.
    #
    # @raise [MongoDBError] if the command fails or there's a problem with the validation
    #   data, or if the collection is invalid.
    def validate_collection(name)
      doc = command(:validate => name)
      raise MongoDBError, "Error with validate command: #{doc.inspect}" unless ok?(doc)
      result = doc['result']
      raise MongoDBError, "Error with validation data: #{doc.inspect}" unless result.kind_of?(String)
      raise MongoDBError, "Error: invalid collection #{name}: #{doc.inspect}" if result =~ /\b(exception|corrupt)\b/i
      doc
    end

    private

    def hash_password(username, plaintext)
      Digest::MD5.hexdigest("#{username}:mongo:#{plaintext}")
    end

    def system_command_collection
      Collection.new(self, SYSTEM_COMMAND_COLLECTION)
    end

    def validate_db_name(db_name)
      unless [String, Symbol].include?(db_name.class)
        raise TypeError, "db_name must be a string or symbol"
      end

      [" ", ".", "$", "/", "\\"].each do |invalid_char|
        if db_name.include? invalid_char
          raise InvalidName, "database names cannot contain the character '#{invalid_char}'"
        end
      end
      raise InvalidName, "database name cannot be the empty string" if db_name.empty?
      db_name
    end
  end
end
