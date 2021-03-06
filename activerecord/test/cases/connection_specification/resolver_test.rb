require "cases/helper"

module ActiveRecord
  module ConnectionAdapters
    class ConnectionSpecification
      class ResolverTest < ActiveRecord::TestCase
        def resolve(spec, config={})
          Resolver.new(config).resolve(spec).config
        end

        def test_url_invalid_adapter
          assert_raises(LoadError) do
            resolve 'ridiculous://foo?encoding=utf8'
          end
        end

        # The abstract adapter is used simply to bypass the bit of code that
        # checks that the adapter file can be required in.

        def test_url_from_environment
          spec = resolve :production, 'production' => 'abstract://foo?encoding=utf8'
          assert_equal({
            adapter:  "abstract",
            host:     "foo",
            encoding: "utf8" }, spec)
        end

        def test_url_host_no_db
          spec = resolve 'abstract://foo?encoding=utf8'
          assert_equal({
            adapter:  "abstract",
            host:     "foo",
            encoding: "utf8" }, spec)
        end

        def test_url_host_db
          spec = resolve 'abstract://foo/bar?encoding=utf8'
          assert_equal({
            adapter:  "abstract",
            database: "bar",
            host:     "foo",
            encoding: "utf8" }, spec)
        end

        def test_url_port
          spec = resolve 'abstract://foo:123?encoding=utf8'
          assert_equal({
            adapter:  "abstract",
            port:     123,
            host:     "foo",
            encoding: "utf8" }, spec)
        end

        def test_encoded_password
          password = 'am@z1ng_p@ssw0rd#!'
          encoded_password = URI.encode_www_form_component(password)
          spec = resolve "abstract://foo:#{encoded_password}@localhost/bar"
          assert_equal password, spec[:password]
        end

        def test_descriptive_error_message_when_adapter_is_missing
          error = assert_raise(LoadError) do
            resolve(adapter: 'non-existing')
          end

          assert_match "Could not load 'active_record/connection_adapters/non-existing_adapter'", error.message
        end

        def test_url_host_db_for_sqlite3
          spec = resolve 'sqlite3://foo:bar@dburl:9000/foo_test'
          assert_equal('/foo_test', spec[:database])
        end

        def test_url_host_memory_db_for_sqlite3
          spec = resolve 'sqlite3://foo:bar@dburl:9000/:memory:'
          assert_equal(':memory:', spec[:database])
        end
      end
    end
  end
end
